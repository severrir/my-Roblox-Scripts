-- module combat and movment skills are just for testing
local Skillsets = {
	["Combat"] = {
		["M1"] = {Name = "M1", Cooldown = 2, ExtraInfo = {} },
		["F"] = {Name = "Block", Cooldown = 1, ExtraInfo = {} }
	},
	["Movement"] = {
		["Q"] = {Name = "Dash", Cooldown = 1.5, ExtraInfo = { } },
		["LeftShift"] = {Name = "Sprint", Cooldown = 1, ExtraInfo = { } }
	},
	
	["TestSkillSet"] = {
		["E"] = {Name = "Slice", Cooldown = 3, ExtraInfo = { } },
	}

}
		
return Skillsets
