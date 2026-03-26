-- Module This file Should be in Fx file but in git hub you cant do that soo
local TS = game:GetService("TweenService")
local RS = game:GetService("RunService")
local RParams = RaycastParams.new()
RParams.FilterType = Enum.RaycastFilterType.Whitelist
RParams.FilterDescendantsInstances = {workspace.Map}

local module = {
	["Slice"] = function(Player, Params)
		local character = Player.Character or Player.CharacterAdded:Wait()


		for i = 0,2 do

			local Slice = game.ReplicatedStorage.Assets.VFX.TestSkillSet.Slice:Clone()
			Slice.CFrame = Params.Character.HumanoidRootPart.CFrame * CFrame.Angles(math.rad(90), 0, math.rad(70 + (i * 20)))
			Slice.Parent = workspace.FX
			TS:Create(Slice, TweenInfo.new(.5), {Transparency = 1}):Play()
			local Start = tick()
			local LastRock = tick()
			game.Debris:AddItem(Slice, 2)
			local Connection

			task.delay(0.5, function()
				if Slice and Slice.Parent then
					Slice.Dots.Enabled = false
					Slice.Shards.Enabled = false
					Slice.Wisp.Enabled = false
					Slice.Wisp2.Enabled = false
				end
				if Connection then
					Connection:Disconnect()
				end
			end)
			Connection = RS.RenderStepped:Connect(function(DT)
				if not Slice or not Slice.Parent then
					Connection:Disconnect()
					return
				end
				local Result = workspace:Raycast(
					Slice.Trail5.WorldPosition + Vector3.new(0, 12, 0),
					Vector3.new(0, -12, 0),
					RParams
				)
				if Result then
					Slice.TrailGreen.Enabled = true
					Slice.TrailBlack.Enabled = true
					Slice.Trail.Position = Vector3.new(-4.8, .4, Slice.Position.Y - Result.Position.Y - .01)
					Slice.Trail2.Position = Vector3.new(-4.8, -.4, Slice.Position.Y - Result.Position.Y - .01)
					Slice.Trail3.Position = Vector3.new(-4.8, .4, Slice.Position.Y - Result.Position.Y - .005)
					Slice.Trail4.Position = Vector3.new(-4.8, -.4, Slice.Position.Y - Result.Position.Y - .005)
				else
					Slice.TrailGreen.Enabled = false
					Slice.TrailBlack.Enabled = false
				end
				Slice.CFrame = Slice.CFrame * CFrame.new(-150 * DT, 0, 0)
				if tick() - LastRock > .001 then
					LastRock = tick()
					local RockResult = workspace:Raycast(
						Vector3.new(Slice.Trail.WorldPosition.X, Slice.Position.Y, Slice.Trail.WorldPosition.Z),
						Vector3.new(0, -6, 0),
						RParams
					)
					if RockResult then
						local Rock = game.ReplicatedStorage.Assets.VFX.TestSkillSet.Rock:Clone()
						Rock.CFrame =
							CFrame.new(RockResult.Position)
							* CFrame.new(math.random(-20,20)/10, -3, math.random(-20,20)/10)
							* CFrame.Angles(
								math.rad(math.random(-20,20)/10),
								math.rad(math.random(-20,20)/10),
								math.rad(math.random(-20,20)/10)
							)
						Rock.Size = Vector3.new(
							math.random(10,30)/10,
							math.random(10,30)/10,
							math.random(10,30)/10
						)
						Rock.Parent = workspace.FX
						Rock.Material = RockResult.Material
						Rock.Color = RockResult.Instance.Color
						TS:Create(Rock, TweenInfo.new(.2), {
							CFrame = Rock.CFrame * CFrame.new(0, math.random(25,35)/10, 0)
								* CFrame.Angles(
									math.rad(math.random(0,180)),
									math.rad(math.random(0,180)),
									math.rad(math.random(0,180))
								)
						}):Play()
						task.delay(1, function()
							TS:Create(Rock, TweenInfo.new(.5), {
								Position = Rock.Position - Vector3.new(0, 3, 0),
								Orientation = Vector3.new(
									math.random(0,180),
									math.random(0,180),
									math.random(0,180)
								)
							}):Play()
						end)
						game.Debris:AddItem(Rock, 2)
					end
				end
			end)
		end
	end,
}
return module
