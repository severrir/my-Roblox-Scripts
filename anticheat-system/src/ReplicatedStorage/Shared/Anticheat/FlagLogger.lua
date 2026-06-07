-- FlagLogger: sliding-window flag accumulator with Discord webhook on kick.
-- Each check module calls :Flag() — this decides when enough is enough.

local HttpService = game:GetService("HttpService")

local Config = require(game.ReplicatedStorage.Shared.Anticheat.Config)

local FlagLogger = {}
FlagLogger.__index = FlagLogger

function FlagLogger.new()
	return setmetatable({
		-- { [userId] = { {time=number, check=string, detail=string}, ... } }
		_flags  = {},
		-- players already kicked — blocks duplicate webhooks during disconnect delay
		_kicked = {},
	}, FlagLogger)
end

-- Remove entries older than FLAG_WINDOW from a player's flag list in-place.
local function pruneWindow(list)
	local cutoff = os.time() - Config.FLAG_WINDOW
	local i = 1
	while i <= #list do
		if list[i].time < cutoff then
			table.remove(list, i)
		else
			i += 1
		end
	end
end

local function sendWebhook(playerName, userId, checkName, flagCount)
	local url = Config.DISCORD_WEBHOOK_URL
	if url == "" or url:find("YOUR_WEBHOOK") then return end

	local body = HttpService:JSONEncode({
		embeds = {
			{
				title = "Player Kicked — Anticheat",
				color = 15158332, -- red
				fields = {
					{ name = "Player",    value = playerName,               inline = true  },
					{ name = "UserId",    value = tostring(userId),          inline = true  },
					{ name = "Check",     value = checkName,                 inline = true  },
					{ name = "Flags",     value = tostring(flagCount) .. " in window", inline = true  },
					{ name = "Server",    value = game.JobId,                inline = false },
					{ name = "Timestamp", value = tostring(os.time()),        inline = true  },
				},
				footer = { text = "Basketball Anticheat" },
			},
		},
	})

	-- pcall so a failed request never crashes the anticheat, but print everything
	-- so we can see exactly what Discord rejected and why.
	local ok, result = pcall(function()
		return HttpService:RequestAsync({
			Url     = url,
			Method  = "POST",
			Headers = { ["Content-Type"] = "application/json" },
			Body    = body,
		})
	end)

	if not ok then
		-- result is the error string when pcall catches an exception
		warn("[AC] Webhook pcall error:", result)
	else
		-- result is the HttpResponse dict: { Success, StatusCode, StatusMessage, Body, Headers }
		print(string.format("[AC] Webhook status=%d msg=%s success=%s body=%s",
			result.StatusCode,
			tostring(result.StatusMessage),
			tostring(result.Success),
			tostring(result.Body)
		))
		if not result.Success then
			warn("[AC] Webhook rejected — check URL, permissions, or payload above")
		end
	end
end

function FlagLogger:Flag(player, checkName, detail)
	local uid = player.UserId

	-- Already kicked — ignore every flag until PlayerRemoving cleans up.
	if self._kicked[uid] then return end

	if not self._flags[uid] then
		self._flags[uid] = {}
	end

	table.insert(self._flags[uid], {
		time   = os.time(),
		check  = checkName,
		detail = detail or "",
	})

	pruneWindow(self._flags[uid])

	local count = #self._flags[uid]

	-- Structured format so logs are grep-friendly in the dev console.
	print(string.format("[AC] FLAG uid=%d check=%s detail=%s count=%d/%d",
		uid, checkName, tostring(detail), count, Config.MAX_FLAGS))

	if count >= Config.MAX_FLAGS then
		self._kicked[uid] = true
		self._flags[uid]  = nil

		local name = player.Name
		sendWebhook(name, uid, checkName, count)

		pcall(function()
			player:Kick("Kicked by anticheat. If this is an error, contact support.")
		end)
	end
end

function FlagLogger:ClearPlayer(userId)
	self._flags[userId]  = nil
	self._kicked[userId] = nil
end

return FlagLogger
