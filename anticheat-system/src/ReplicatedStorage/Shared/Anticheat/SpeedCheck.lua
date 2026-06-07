-- SpeedCheck: server-reads HRP velocity every heartbeat.
-- 3 consecutive violations required before flagging — single-tick lag spikes are real.

local Config = require(game.ReplicatedStorage.Shared.Anticheat.Config)

local SpeedCheck = {}
SpeedCheck.__index = SpeedCheck

function SpeedCheck.new(flagLogger)
	return setmetatable({
		_logger  = flagLogger,
		-- { [userId] = number }  consecutive ticks above MAX_SPEED
		_streaks = {},
	}, SpeedCheck)
end

function SpeedCheck:CheckPlayer(player)
	local char = player.Character
	if not char then return end

	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	local uid   = player.UserId
	local speed = hrp.AssemblyLinearVelocity.Magnitude

	if speed > Config.MAX_SPEED then
		self._streaks[uid] = (self._streaks[uid] or 0) + 1

		if self._streaks[uid] >= Config.SPEED_VIOLATION_STREAK then
			self._logger:Flag(player, "SpeedCheck",
				string.format("speed=%.1f max=%d", speed, Config.MAX_SPEED))
			-- Reset so we flag once per burst, not every frame after threshold hit.
			self._streaks[uid] = 0
		end
	else
		-- Clean tick: forgive the streak. Lag doesn't deserve escalating punishment.
		self._streaks[uid] = 0
	end
end

function SpeedCheck:RemovePlayer(userId)
	self._streaks[userId] = nil
end

return SpeedCheck
