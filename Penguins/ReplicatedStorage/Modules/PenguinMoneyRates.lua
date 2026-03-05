-- module script
-- just change the numbers the billboard script reads from here on its own

local PenguinRates = {

	-- in studs
	viewDistance = 60,

	-- Commons
	["Baby pengy"] = { rate = 100, offset = 7 },
	["Pengy"] = { rate = 1, offset = 7 },
	["Fat Pengy"] = { rate = 300, offset = 7 },
	["Fisherman Pengy"] = { rate = 15, offset = 7 },
	["Sleepy Peggy"] = { rate = 100, offset = 7 },
	["Pirate peggy"] = { rate = 65, offset = 7 },
	["ninja peggy"] = { rate = 50, offset = 7 },
	["witch peggy"] = { rate = 50, offset = 7 },

	-- Uncommon
	["Cold Penggy"] = { rate = 50, offset = 7 },
	["Pool Peggy"] = { rate = 50, offset = 7 },
	["Warrior Penggy"] = { rate = 50, offset = 7 },
	["Zombie Penggy"] = { rate = 50, offset = 7 },
	["Astronalt penggy"] = { rate = 50, offset = 7 },
	["constracter penggy"] = { rate = 50, offset = 7 },
	["explorer penggy"] = { rate = 50, offset = 7 },
	["ice peggy"] = { rate = 50, offset = 7 },
	["knight penggy"] = { rate = 50, offset = 7 },

	-- Rare
	["Cop Pengy"] = { rate = 50, offset = 7 },
	["Doctor Penggy"] = { rate = 50, offset = 7 },
	["Rounded Penggy"] = { rate = 50, offset = 7 },
	["SnowBorder Penggy"] = { rate = 50, offset = 7 },
	["indiana penggy"] = { rate = 50, offset = 7 },

	-- Legendary
	["Hammer  Penggy"] = { rate = 50, offset = 7 },
	["Skeleton Penggy"] = { rate = 50, offset = 7 },
	["angel penggy"] = { rate = 50, offset = 7 },

	-- Ice Kings
	["Blue Pinguin King"] = { rate = 50, offset = 7 },
	["Red Pinguin King"] = { rate = 50, offset = 7 },
	["Ice King "] = { rate = 50, offset = 7 },

	-- Godly
	["Ice God"] = { rate = 50, offset = 7 },

	-- fallback
	["__default"] = { rate = 1, offset = 7 },
} -- ALL PENGUINS HAVE BEEN ADDED I THINK LOL

return PenguinRates