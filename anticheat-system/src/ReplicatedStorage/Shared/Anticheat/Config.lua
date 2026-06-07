-- Single source of truth for all anticheat thresholds.
-- Tune these in playtesting — tighten gradually so real lag doesn't trigger kicks.

return {
	-- SpeedCheck
	MAX_SPEED = 50,             -- studs/sec. Default walk ~16, sprint ~24. Padding for dash abilities.
	SPEED_VIOLATION_STREAK = 3, -- consecutive bad ticks before a flag fires. Absorbs lag bursts.

	-- TeleportCheck
	MAX_TELEPORT_DISTANCE = 40, -- studs in one heartbeat (~1/60s). Generous for rubber-banding.

	-- ScoreCheck
	SCORE_PROXIMITY_STUDS = 15, -- max distance from hoop centre when score request arrives
	SCORE_COOLDOWN = 2,         -- seconds between accepted score requests per player

	-- Flag escalation
	MAX_FLAGS = 5,              -- flags within FLAG_WINDOW that trigger a kick
	FLAG_WINDOW = 60,           -- seconds, sliding window — old flags expire automatically

	-- Discord webhook for kick notifications. Leave empty string to disable.
	DISCORD_WEBHOOK_URL = "https://discord.com/api/webhooks/1513242704929230990/QAuxbIncos33KZ4CabXskx1uaSOL3ljaTemkTbZKeQ-2mGyJWoQ6QEf6DGjJAZOEyq2L",
}
