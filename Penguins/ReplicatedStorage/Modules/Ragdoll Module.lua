-- module scripttt

local module = {}

local remote = game.ReplicatedStorage.Events.Ragdoll
local players = game:GetService("Players")

function module.Ragdoll(char : CharacterMesh)
	local humanoid : Humanoid = char:WaitForChild("Humanoid")
	if humanoid:GetState() == Enum.HumanoidStateType.Physics and humanoid.Health > 0 then
		return
	end
	
	char:SetAttribute("Ragdoll", true)
	humanoid.BreakJointsOnDeath = false
	
	for index, joint in pairs(char:GetDescendants()) do
		if joint:IsA("Motor6D") then
			if not remote then return end
			local socket = Instance.new("BallSocketConstraint")
			local a1 = Instance.new("Attachment")
			local a2 = Instance.new("Attachment")
			a1.Parent = joint.Part0
			a2.Parent = joint.Part1
			socket.Parent = joint.Parent
			local plr = game.Players:GetPlayerFromCharacter(char)
			remote:FireClient(plr, nil, "manualM")
			socket.Attachment0 = a1
			socket.Attachment1 = a2
			a1.CFrame = joint.C0
			a2.CFrame = joint.C1
			socket.LimitsEnabled = true

			if joint.Name == "Root" then
				socket:Destroy()
				local hinge = Instance.new("HingeConstraint")
				hinge.Parent = joint.Parent
				hinge.Attachment0 = a1
				hinge.Attachment1 = a2
				hinge.LimitsEnabled = true
			end
			
			if joint.Name == "Neck" then
				socket:Destroy()
				local hinge = Instance.new("HingeConstraint")
				hinge.Parent = joint.Parent
				hinge.Attachment0 = a1
				hinge.Attachment1 = a2
				hinge.LimitsEnabled = true
			end
			socket.TwistLimitsEnabled = true
			joint.Enabled = false
		end
	end
end

function module.NpcRagdoll(char : Model, sec : number) -- npcc
	local humanoid : Humanoid = char and char.Humanoid
	local root = humanoid and humanoid.RootPart
	humanoid.BreakJointsOnDeath = false
	if humanoid:GetState() ~= Enum.HumanoidStateType.Physics then
		for index, joint in pairs(char:GetDescendants()) do
			if joint:IsA("Motor6D") then
				local socket = Instance.new("BallSocketConstraint")
				local a1 = Instance.new("Attachment")
				local a2 = Instance.new("Attachment")
				a1.Parent = joint.Part0
				a2.Parent = joint.Part1
				socket.Parent = joint.Parent
				socket.Attachment0 = a1
				socket.Attachment1 = a2
				a1.CFrame = joint.C0
				a2.CFrame = joint.C1
				socket.LimitsEnabled = true
				socket.TwistLimitsEnabled = true
				humanoid.PlatformStand = true
				if joint.Name == "Root" then
					socket:Destroy()
					local hinge = Instance.new("HingeConstraint")
					hinge.Parent = joint.Parent
					hinge.Attachment0 = a1
					hinge.Attachment1 = a2
					hinge.LimitsEnabled = true
				end
				if joint.Name == "Neck" then
					socket:Destroy()
					local hinge = Instance.new("HingeConstraint")
					hinge.Parent = joint.Parent
					hinge.Attachment0 = a1
					hinge.Attachment1 = a2
					hinge.LimitsEnabled = true
				end
				humanoid:ChangeState(Enum.HumanoidStateType.Physics)
				joint.Enabled = false
			end
		end
		task.wait(sec)

		for index, joint in pairs(char:GetDescendants()) do
			if joint:IsA("Motor6D") then
				local socket = joint.Parent:FindFirstChild("BallSocketConstraint") or joint.Parent:FindFirstChild("HingeConstraint")
				local a1 = joint.Part0:FindFirstChild("Attachment")
				local a2 = joint.Part1:FindFirstChild("Attachment")
				socket:Destroy()
				a1:Destroy()
				a2:Destroy()
				humanoid.PlatformStand = false
				humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
				joint.Enabled = true
			end
		end
	end
end
function module.TimedRagdoll(char : Model, sec : number) -- uhh
	local humanoid = char:WaitForChild("Humanoid")
	humanoid.BreakJointsOnDeath = false

	if not remote then return end
	local plr = game.Players:GetPlayerFromCharacter(char)
	remote:FireClient(plr, "Make", sec)
	if humanoid:GetState() ~= Enum.HumanoidStateType.Physics then
		char:SetAttribute("Ragdoll", true)
		for index, joint in pairs(char:GetDescendants()) do
			if joint:IsA("Motor6D") then
				local socket = Instance.new("BallSocketConstraint")
				local a1 = Instance.new("Attachment")
				local a2 = Instance.new("Attachment")
				a1.Parent = joint.Part0
				a2.Parent = joint.Part1
				socket.Parent = joint.Parent
				socket.Attachment0 = a1
				socket.Attachment1 = a2
				a1.CFrame = joint.C0
				a2.CFrame = joint.C1
				socket.LimitsEnabled = true
				socket.TwistLimitsEnabled = true
				if joint.Name == "Root" then
					socket:Destroy()
					local hinge = Instance.new("HingeConstraint")
					hinge.Parent = joint.Parent
					hinge.Attachment0 = a1
					hinge.Attachment1 = a2
					hinge.LimitsEnabled = true
				end
				if joint.Name == "Neck" then
					socket:Destroy()
					local hinge = Instance.new("HingeConstraint")
					hinge.Parent = joint.Parent
					hinge.Attachment0 = a1
					hinge.Attachment1 = a2
					hinge.LimitsEnabled = true
				end
				joint.Enabled = false
			end
		end
		
		task.wait(sec)
		
		local plr = game.Players:GetPlayerFromCharacter(char)
		if plr then
			remote:FireClient(plr, "Destroy", sec)
		end
		
		if char.Humanoid.Health <= 0 then return end
		char:SetAttribute("Ragdoll", false)
		for index, joint in pairs(char:GetDescendants()) do
			if joint:IsA("Motor6D") then
				local socket = joint.Parent:FindFirstChild("BallSocketConstraint") or joint.Parent:FindFirstChild("HingeConstraint")
				local a1 = joint.Part0:FindFirstChild("Attachment")
				local a2 = joint.Part1:FindFirstChild("Attachment")
				socket:Destroy()
				a1:Destroy()
				a2:Destroy()
				joint.Enabled = true
			end
		end
	end
end

function module.Unragdoll(char : CharacterMesh) -- again, the character
	for index, joint in pairs(char:GetDescendants()) do
		if joint:IsA("Motor6D") then
			if not remote then return end
			local humanoid = char:WaitForChild("Humanoid")
			local socket = joint.Parent:FindFirstChild("BallSocketConstraint") or joint.Parent:FindFirstChild("HingeConstraint")
			local a1 = joint.Part0:FindFirstChild("Attachment")
			local a2 = joint.Part1:FindFirstChild("Attachment")
			socket:Destroy()
			a1:Destroy()
			a2:Destroy()
			local plr = game.Players:GetPlayerFromCharacter(char)
			remote:FireClient(plr, nil, "manualD")
			joint.Enabled = true
		end
	end
	char:SetAttribute("Ragdoll", false)
end

return module


