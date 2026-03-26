-- module
local Functions = require(script.Parent.Parent.Functions)

local TestSkillSet = {
	["Slice"] = function(Player, ...)
		local Data = (...)
		print("Reached Server")
		local Character = Player.Character
		local CF = Character.HumanoidRootPart.CFrame
		Functions.FireClientWithDistance({Origin = Character.HumanoidRootPart.Position, Distance = 125, Remote = game.ReplicatedStorage.Remotes.Effect}, {"Slice", {Character = Character, CFrame = CF}})
			local Params = OverlapParams.new()
			Params.FilterType = Enum.RaycastFilterType.Blacklist
			Params.FilterDescendantsInstances = {workspace.Map, Character}
			for i = 0, 2 do
				task.spawn(function()
					local Hits = {}
					local NCF = CF * CFrame.Angles(0, math.rad(-20 + (i * 20)), 0)
					for i = 1, 15 do
						local Hitbox = workspace:GetPartBoundsInBox(NCF * CFrame.new(0, 0, i * -5), Vector3.new(2, 13, 5), Params)
						for Index, Part in pairs(Hitbox) do
							if Part.Parent:FindFirstChild("Humanoid") then
								if Hits[Part.Parent] == nil then
									Hits[Part.Parent] = true
									Part.Parent.Humanoid:TakeDamage(10)
									local Hit = game.ReplicatedStorage.Assets.VFX.TestSkillSet.Hit:Clone()
									Hit.CFrame = Part.Parent.HumanoidRootPart.CFrame
									Hit.Orientation = Vector3.new(math.random(0,180), math.random(0,180), math.random(0,180))
									Hit.Parent = workspace.FX
									Hit.Attachment.Shards:Emit(25)
									game.Debris:AddItem(Hit, 1)
								end
							end
						end
						task.wait(.033)
					end
				end)
			end
	end,
}

return TestSkillSet
