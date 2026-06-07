-- AnticheatService — drop this Script into ServerScriptService and it bootstraps everything.
-- All check modules live under ReplicatedStorage/Shared/Anticheat/.
-- Other services (e.g. BallService) call :GrantBallPossession() / :RevokeBallPossession()
-- to register server-side possession; ScoreCheck will reject any score without it.

local Players          = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService       = game:GetService("RunService")

local Shared   = ReplicatedStorage.Shared
local Knit     = require(Shared.Knit)
local AC       = Shared.Anticheat

local FlagLogger    = require(AC.FlagLogger)
local SpeedCheck    = require(AC.SpeedCheck)
local TeleportCheck = require(AC.TeleportCheck)
local ScoreCheck    = require(AC.ScoreCheck)

-- RemoteEvent used by clients to request a score. Server does all validation.
-- Creating it here ensures it exists before any client can fire it.
local function getOrCreateRemote(name)
	local existing = ReplicatedStorage:FindFirstChild(name)
	if existing then return existing end
	local re = Instance.new("RemoteEvent")
	re.Name   = name
	re.Parent = ReplicatedStorage
	return re
end

-- ── Service Definition ────────────────────────────────────────────────────────

local AnticheatService = Knit.CreateService({
	Name = "AnticheatService",
})

function AnticheatService:KnitInit()
	self._logger    = FlagLogger.new()
	self._speed     = SpeedCheck.new(self._logger)
	self._teleport  = TeleportCheck.new(self._logger)
	self._score     = ScoreCheck.new(self._logger)
	self._playerConns = {} -- { [userId] = { RBXScriptConnection, ... } }
end

function AnticheatService:KnitStart()
	local scoreRemote = getOrCreateRemote("AC_ScoreRequest")

	-- Per-frame server-side checks. Heartbeat is the right signal here because
	-- it fires after physics simulation, so HRP positions are settled.
	RunService.Heartbeat:Connect(function()
		for _, player in ipairs(Players:GetPlayers()) do
			self._speed:CheckPlayer(player)
			self._teleport:CheckPlayer(player)
		end
	end)

	-- Client fires this with no arguments; server looks up the hoop itself.
	-- Never accept position data from the client — that's the whole point.
	scoreRemote.OnServerEvent:Connect(function(player)
		local hoopPos = self:_nearestHoopPosition(player)
		if not hoopPos then return end

		local accepted = self._score:ValidateScore(player, hoopPos)
		if accepted then
			-- Hand off to whatever service owns the scoreboard.
			-- Replace this line with: ScoringService:AddPoint(player)
			print(string.format("[AC] Score accepted — player=%s", player.Name))
		end
		-- Rejected requests are silently dropped. No error message to the client.
	end)

	-- Connect first, then seed existing players to avoid a join race.
	Players.PlayerAdded:Connect(function(player)
		self:_onPlayerAdded(player)
	end)

	Players.PlayerRemoving:Connect(function(player)
		self:_onPlayerRemoving(player)
	end)

	for _, player in ipairs(Players:GetPlayers()) do
		task.spawn(self._onPlayerAdded, self, player)
	end
end

-- ── Player Lifecycle ──────────────────────────────────────────────────────────

function AnticheatService:_onPlayerAdded(player)
	local uid = player.UserId
	self._playerConns[uid] = {}

	-- Reset teleport baseline on each respawn so spawn position isn't flagged.
	local charConn = player.CharacterAdded:Connect(function()
		-- task.defer so the HRP has time to be positioned at the spawn location.
		task.defer(function()
			self._teleport:RegisterSpawn(player)
		end)
	end)

	table.insert(self._playerConns[uid], charConn)

	-- Seed baseline for players who already have a character (e.g. character auto-loads).
	if player.Character then
		task.defer(function()
			self._teleport:RegisterSpawn(player)
		end)
	end
end

function AnticheatService:_onPlayerRemoving(player)
	local uid = player.UserId

	-- Disconnect every connection we opened for this player.
	if self._playerConns[uid] then
		for _, conn in ipairs(self._playerConns[uid]) do
			conn:Disconnect()
		end
		self._playerConns[uid] = nil
	end

	self._speed:RemovePlayer(uid)
	self._teleport:RemovePlayer(uid)
	self._score:RemovePlayer(uid)
	self._logger:ClearPlayer(uid)
end

-- ── Hoop Lookup ───────────────────────────────────────────────────────────────

-- Expects a Folder named "Hoops" in Workspace with BasePart or Model children.
-- Returns the position of the nearest hoop to the player, or nil if none found.
function AnticheatService:_nearestHoopPosition(player)
	local char = player.Character
	if not char then return nil end

	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return nil end

	local hoopsFolder = workspace:FindFirstChild("Hoops")
	if not hoopsFolder then return nil end

	local nearest, nearDist = nil, math.huge

	for _, hoop in ipairs(hoopsFolder:GetChildren()) do
		local pos
		if hoop:IsA("BasePart") then
			pos = hoop.Position
		elseif hoop:IsA("Model") then
			-- PrimaryPart preferred; fall back to model pivot if none set.
			local pp = hoop.PrimaryPart
			pos = pp and pp.Position or hoop:GetPivot().Position
		end

		if pos then
			local d = (hrp.Position - pos).Magnitude
			if d < nearDist then
				nearest  = pos
				nearDist = d
			end
		end
	end

	return nearest
end

-- ── Public API for Other Services ─────────────────────────────────────────────
-- BallService calls these when the server physically confirms pickup/loss.

function AnticheatService:GrantBallPossession(player)
	self._score:GrantPossession(player)
end

function AnticheatService:RevokeBallPossession(player)
	self._score:RevokePossession(player)
end

-- ── Boot ──────────────────────────────────────────────────────────────────────

Knit.Start():catch(function(err)
	warn("[AnticheatService] Knit failed to start:", err)
end)
