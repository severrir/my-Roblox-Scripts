-- TeleportCheck: compares server-side HRP position tick-to-tick.
-- Respawn is exempt — RegisterSpawn() resets the baseline so spawn location
-- doesn't look like a teleport from wherever the player died.

local Config = require(game.ReplicatedStorage.Shared.Anticheat.Config)

local TeleportCheck = {}
TeleportCheck.__index = TeleportCheck

function TeleportCheck.new(flagLogger)
	return setmetatable({
		_logger  = flagLogger,
		-- { [userId] = Vector3 }  last confirmed server-side position
		_lastPos = {},
	}, TeleportCheck)
end

-- Call this after CharacterAdded fires (with a task.defer so HRP is positioned).
function TeleportCheck:RegisterSpawn(player)
	local char = player.Character
	if not char then return end

	local hrp = char:FindFirstChild("HumanoidRootPart")
	if hrp then
		self._lastPos[player.UserId] = hrp.Position
	end
end

function TeleportCheck:CheckPlayer(player)
	local char = player.Character
	if not char then return end

	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	local uid  = player.UserId
	local pos  = hrp.Position
	local last = self._lastPos[uid]

	if last then
		local delta = (pos - last).Magnitude
		if delta > Config.MAX_TELEPORT_DISTANCE then
			self._logger:Flag(player, "TeleportCheck",
				string.format("delta=%.1f max=%d", delta, Config.MAX_TELEPORT_DISTANCE))
		end
	end

	-- Always update, even after a flag — track actual position so next tick is accurate.
	self._lastPos[uid] = pos
end

function TeleportCheck:RemovePlayer(userId)
	self._lastPos[userId] = nil
end

return TeleportCheck
