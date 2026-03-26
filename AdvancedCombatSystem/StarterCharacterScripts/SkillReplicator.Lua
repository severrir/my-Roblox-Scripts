-- Local Script
-- player and character
local Player = game.Players.LocalPlayer
local Character = script.Parent

-- services
local rs = game:GetService("ReplicatedStorage")
local InputService = game:GetService("UserInputService")
-- Remotes
local Server = rs.Remotes.Server
local Effect = rs.Remotes.Effect

-- modules
local Cooldown = require(rs.Replicated.Cooldown)
local Skillsets = require(rs.Replicated.Skillsets)
local Fx = require(script:WaitForChild("Fx"))

-- AvailableSets
local AvailableSets = {
	"Combat",
	"Movement",
	"TestSkillSet"
}

-- Inputs
local InputBegan = coroutine.create(function()
	InputService.InputBegan:Connect(function(UserInput, GPE)
		if GPE then return end

		local Skill, Set, Info, Input = nil, nil, nil, nil

		if UserInput.UserInputType == Enum.UserInputType.MouseButton1 then
			Input = "M1"

			if Cooldown:CheckCooldown("M1", Player) == false
				and Character:GetAttribute("Stunned") == false
				and Character:GetAttribute("Attacking") == false then

				Info = {Data = "Test"}
			end

		else
			Input = UserInput.KeyCode.Name
			Info = {Data = "Test"}
		end

		for i, v in pairs(AvailableSets) do
			if Skillsets[v] then
				if Skillsets[v][Input] then
					Skill = Skillsets[v][Input]
					Set = v
				end
			end
		end

		if Skill then
			if Cooldown:CheckCooldown(Skill.Name, Player) == false
				and Character:GetAttribute("Stunned") == false
				and Character:GetAttribute("Attacking") == false then

				Character:SetAttribute("Attacking", true)

				if Info then
					print("Fire SKILL")
					local Fire = Server:InvokeServer("Skill", nil, {Info, Skill["Name"], Set})
					Cooldown:AddCooldown(Skill.Name, Skill.Cooldown, Player)
				end

				Character:SetAttribute("Attacking", false)

			end
		end
	end)
end)


-- For Hold skills
local InputEnded = coroutine.create(function()
	InputService.InputEnded:Connect(function(Input, GPE)
		Server:InvokeServer("EndInput", Input.KeyCode.Name)
	end)
end)

coroutine.resume(InputBegan)
coroutine.resume(InputEnded)

Effect.OnClientEvent:Connect(function(...)
	local FXName, Params = unpack(...)
	print(FXName, Params)
	Fx[FXName](Player, Params)
end)
