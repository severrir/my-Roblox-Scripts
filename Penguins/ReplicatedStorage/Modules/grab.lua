-- module script 

local PenguinGrab = {}

local function getMainPart(model)
	local mainPart = model:FindFirstChild("Torso")
	if mainPart and mainPart:IsA("BasePart") then
		return mainPart
	end
	if model.PrimaryPart and model.PrimaryPart:IsA("BasePart") then
		return model.PrimaryPart
	end
	return model:FindFirstChildWhichIsA("BasePart")
end

local function getCarryOffset(model, body, customOffset)
	if customOffset then
		return customOffset
	end

	local size = model:GetExtentsSize()
	-- keep centered on X so the penguin is not carried to the sideee
	local x = 0
	local y = math.clamp((size.Y * 0.65) + 1.2, 1.2, 4)
	local z = -((size.Z * 0.5) + (body.Size.Z * 0.5) - 5.5)
	return Vector3.new(x, y, z)
end

-- weld all model parts to one root part
function PenguinGrab.WeldModel(model)
	local mainPart = getMainPart(model)
	if not mainPart then return end

	model.PrimaryPart = mainPart
	mainPart.Anchored = false

	for _, inst in ipairs(model:GetDescendants()) do
		if inst:IsA("BasePart") then
			inst.Anchored = false
			inst.CanCollide = false
			inst.Massless = true

			if inst ~= mainPart then
				local oldWeld = inst:FindFirstChild("PenguinPartWeld")
				if oldWeld then
					oldWeld:Destroy()
				end

				local weld = Instance.new("WeldConstraint")
				weld.Name = "PenguinPartWeld"
				weld.Part0 = mainPart
				weld.Part1 = inst
				weld.Parent = inst
			end
		end
	end

	return mainPart
end

-- grab and attach func
function PenguinGrab.GrabPenguin(player, model, offset)
	local character = player.Character
	if not character then return end

	local body = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
	if not body then return end

	local oldWeld = body:FindFirstChild("PlayerWeld")
	if oldWeld then
		oldWeld:Destroy()
	end

	-- main part of penguin
	local mainPart = getMainPart(model)
	if not mainPart then return end

	-- weld all the part
	PenguinGrab.WeldModel(model)

	local finalOffset = Vector3.new(0, -0.5, -1.5)
	local carryCFrame = body.CFrame * CFrame.new(finalOffset) * CFrame.Angles(0, math.rad(180), 0)
	model:PivotTo(carryCFrame)

	pcall(function()
		mainPart:SetNetworkOwner(nil)
	end)

	-- create weld
	local weld = Instance.new("Weld")
	weld.Part0 = body
	weld.Part1 = mainPart
	weld.Name = "PlayerWeld"
	weld.C0 = CFrame.new(finalOffset) * CFrame.Angles(0, math.rad(180), 0)
	weld.Parent = body

	return weld
end

-- this is for the future its when i need drop
function PenguinGrab.DropPenguin(weld)
	if weld then
		if weld.Part1 then
			weld.Part1.Anchored = false
		end
		weld:Destroy()
	end
end

return PenguinGrab
