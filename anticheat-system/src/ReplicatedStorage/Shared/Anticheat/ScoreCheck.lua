-- ScoreCheck: server-side gate for all score requests.
-- Ball possession must be registered here by server code — never trust the client
-- to say they have the ball. ScoreCheck is the only thing that awards points.

local Config = require(game.ReplicatedStorage.Shared.Anticheat.Config)

local ScoreCheck = {}
ScoreCheck.__index = ScoreCheck

function ScoreCheck.new(flagLogger)
	return setmetatable({
		_logger    = flagLogger,
		-- { [userId] = number }   os.time() of last accepted score
		_lastScore = {},
		-- { [userId] = boolean }  server-confirmed ball possession flag
		_hasBall   = {},
	}, ScoreCheck)
end

-- BallService (or whatever owns the ball) calls this when the server confirms pickup.
function ScoreCheck:GrantPossession(player)
	self._hasBall[player.UserId] = true
end

-- Call on pass, steal, out-of-bounds, drop — anything that ends possession.
function ScoreCheck:RevokePossession(player)
	self._hasBall[player.UserId] = false
end

-- Returns true if the score is legitimate and records it; false otherwise.
-- hoopPosition must come from the server's own hoop reference, never from the client.
function ScoreCheck:ValidateScore(player, hoopPosition)
	local uid  = player.UserId
	local char = player.Character
	if not char then return false end

	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return false end

	-- Cooldown gate: prevents rapid-fire score spam.
	local now  = os.time()
	local last = self._lastScore[uid] or 0
	if (now - last) < Config.SCORE_COOLDOWN then
		return false
	end

	-- Possession gate: scoring without server-confirmed ball is definitively cheating.
	if not self._hasBall[uid] then
		self._logger:Flag(player, "ScoreCheck", "score_without_possession")
		return false
	end

	-- Proximity gate: must be near a hoop. No half-court exploits.
	local dist = (hrp.Position - hoopPosition).Magnitude
	if dist > Config.SCORE_PROXIMITY_STUDS then
		self._logger:Flag(player, "ScoreCheck",
			string.format("score_too_far dist=%.1f max=%d", dist, Config.SCORE_PROXIMITY_STUDS))
		return false
	end

	-- All gates passed — commit the score.
	self._lastScore[uid]  = now
	self._hasBall[uid]    = false -- ball leaves possession on score
	return true
end

function ScoreCheck:RemovePlayer(userId)
	self._lastScore[userId] = nil
	self._hasBall[userId]   = nil
end

return ScoreCheck
