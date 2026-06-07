-- Knit minimal implementation — covers the API surface used by this project.
-- Matches the Knit 1.x lifecycle: CreateService → Start → KnitInit → KnitStart.
-- For the full framework with Controllers, Components, and Signals:
--   https://sleitnick.github.io/Knit/

local Knit = {}
Knit.Version = "1.5.1-compat"

local _services = {}
local _started  = false

-- ── Promise ─────────────────────────────────────────────────────────────────
-- Minimal promise that supports the :andThen()/:catch() chaining Knit.Start uses.

local Promise = {}
Promise.__index = Promise

function Promise.new(executor)
	local self = setmetatable({
		_state    = "pending", -- "resolved" | "rejected"
		_value    = nil,
		_thenCbs  = {},
		_catchCbs = {},
	}, Promise)

	local function resolve(val)
		if self._state ~= "pending" then return end
		self._state = "resolved"
		self._value = val
		for _, cb in ipairs(self._thenCbs) do
			task.spawn(cb, val)
		end
	end

	local function reject(err)
		if self._state ~= "pending" then return end
		self._state = "rejected"
		self._value = err
		for _, cb in ipairs(self._catchCbs) do
			task.spawn(cb, err)
		end
	end

	local ok, err = pcall(executor, resolve, reject)
	if not ok then
		reject(err)
	end

	return self
end

function Promise:andThen(cb)
	if self._state == "resolved" then
		task.spawn(cb, self._value)
	elseif self._state == "pending" then
		table.insert(self._thenCbs, cb)
	end
	return self
end

function Promise:catch(cb)
	if self._state == "rejected" then
		task.spawn(cb, self._value)
	elseif self._state == "pending" then
		table.insert(self._catchCbs, cb)
	end
	return self
end

function Promise.resolve(val)
	return Promise.new(function(res) res(val) end)
end

function Promise.reject(err)
	return Promise.new(function(_, rej) rej(err) end)
end

-- ── Knit API ─────────────────────────────────────────────────────────────────

function Knit.CreateService(def)
	assert(not _started, "Cannot call CreateService after Knit.Start()")
	assert(type(def) == "table",           "Service definition must be a table")
	assert(type(def.Name) == "string" and #def.Name > 0, "Service must have a non-empty Name")
	assert(not _services[def.Name],        "Duplicate service name: " .. def.Name)

	local svc = {}
	for k, v in pairs(def) do
		svc[k] = v
	end
	-- Client table back-ref lets client-exposed methods reach server methods via self.Server.
	svc.Client        = def.Client or {}
	svc.Client.Server = svc

	_services[def.Name] = svc
	return svc
end

-- Returns a registered service. Only callable after Knit.Start() resolves.
function Knit.GetService(name)
	assert(_started, "Knit.GetService must be called after Knit.Start()")
	return assert(_services[name], "Unknown service: " .. tostring(name))
end

-- Runs KnitInit on every service (synchronous, ordered setup),
-- then KnitStart on every service (concurrent, each in its own thread).
function Knit.Start()
	assert(not _started, "Knit.Start() already called")

	return Promise.new(function(resolve, reject)
		_started = true

		-- Init phase: all services get a chance to wire up before anyone starts.
		local ok, err = pcall(function()
			for _, svc in pairs(_services) do
				if type(svc.KnitInit) == "function" then
					svc:KnitInit()
				end
			end
		end)
		if not ok then
			reject(err)
			return
		end

		-- Start phase: each service runs concurrently; one hanging service won't block others.
		local ok2, err2 = pcall(function()
			for _, svc in pairs(_services) do
				if type(svc.KnitStart) == "function" then
					task.spawn(svc.KnitStart, svc)
				end
			end
		end)
		if not ok2 then
			reject(err2)
			return
		end

		resolve(nil)
	end)
end

return Knit
