local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Bases = workspace.TacosMap.Map.Base
local Modules = ReplicatedStorage:WaitForChild("Modules")
local PenguinData = require(Modules:WaitForChild("PenguinDatabase"))
local Manager = require(game.ServerScriptService.Data.Manager)
local ZonePlus = require(game.ReplicatedStorage.Modules.Zone)
local LobbyZone: BasePart = workspace.TacosMap.Map.LobbyZone.Zone
local lobbyZone = ZonePlus.new(LobbyZone)
local DEFAULT_SLOT_YAW_OFFSET = 0
local DEFAULT_SLOT_PITCH_OFFSET = 0
local DEFAULT_SLOT_ROLL_OFFSET = 0
local GROUND_RAY_ABOVE_SLOT = 0.25
local GROUND_RAY_DEPTH_BELOW_SLOT = 120
local GROUND_CLEARANCE = 0.02
local PENGUIN_RATE_FORMAT = "$%d/s"
local COLLECT_PAD_FORMAT = "$%d"
local MONEY_GUI_TEMPLATE_NAME = "MonePSecGui"
local IGNORE_PART_NAMES_FOR_GROUND = {
	HumanoidRootPart = true,
	RootPart = true,
}

local function normalizeName(name: string): string
	return string.lower((name or ""):gsub("%s+", ""))
end

local function canonicalPenguinName(name: string): string
	local value = normalizeName(name)
	value = value:gsub("peggy", "peng")
	value = value:gsub("pengy", "peng")
	return value
end

local function findPenguinDataByName(modelName: string)
	local target = canonicalPenguinName(modelName)
	for _, data in ipairs(PenguinData.Penguins) do
		if canonicalPenguinName(data.Name) == target then
			return data
		end
	end
	return nil
end

local function resolvePenguinRate(penguinModel: Model, penguinData): number
	if penguinData and tonumber(penguinData.MoneyPerSecond) then
		return math.max(0, tonumber(penguinData.MoneyPerSecond))
	end

	local existingRate = penguinModel:FindFirstChild("MoneyPerSecond")
	if existingRate and existingRate:IsA("NumberValue") and existingRate.Value > 0 then
		return math.max(0, existingRate.Value)
	end

	return 1
end

local function formatRateText(rate: number, isCollectPad: boolean): string
	local value = math.floor(rate + 0.5)

	if isCollectPad then
		return COLLECT_PAD_FORMAT:format(value)
	else
		return PENGUIN_RATE_FORMAT:format(value)
	end
end

local function findFirstTextLabel(root: Instance?): TextLabel?
	if not root then
		return nil
	end
	if root:IsA("TextLabel") then
		return root
	end
	for _, desc in ipairs(root:GetDescendants()) do
		if desc:IsA("TextLabel") then
			return desc
		end
	end
	return nil
end

local function findReceiveCashPart(baseFolder: Instance, slotName: string, slotRef: BasePart?): BasePart?
	local normalizedSlot = normalizeName(slotName)
	local slotDigits = slotName:match("%d+")

	--  Exact/normalized name match against slot container.
	for _, desc in ipairs(baseFolder:GetDescendants()) do
		if desc:IsA("BasePart") and desc.Name == "ReceiveCash" then
			local slotContainer = desc.Parent
			local containerName = slotContainer and slotContainer.Name or ""
			local normalizedContainer = normalizeName(containerName)
			local containerDigits = containerName:match("%d+")

			if normalizedContainer == normalizedSlot then
				return desc
			end
			if slotDigits and containerDigits and slotDigits == containerDigits then
				return desc
			end
		end
	end

	-- nearest ReceiveCash to the prompt slot part.
	if slotRef then
		local nearest: BasePart? = nil
		local nearestDist = math.huge
		for _, desc in ipairs(baseFolder:GetDescendants()) do
			if desc:IsA("BasePart") and desc.Name == "ReceiveCash" then
				local dist = (desc.Position - slotRef.Position).Magnitude
				if dist < nearestDist then
					nearestDist = dist
					nearest = desc
				end
			end
		end
		if nearest then
			return nearest
		end
	end

	return nil
end

local function getOrCreateRateLabel(receiveCashPart: BasePart): TextLabel
	local billboard = receiveCashPart:FindFirstChild("IncomeRateGui")
	if not billboard or not billboard:IsA("BillboardGui") then
		billboard = Instance.new("BillboardGui")
		billboard.Name = "IncomeRateGui"
		billboard.Size = UDim2.new(0, 150, 0, 36)
		billboard.StudsOffset = Vector3.new(0, 1.2, 0)
		billboard.AlwaysOnTop = true
		billboard.MaxDistance = 70
		billboard.Parent = receiveCashPart
	end
	billboard.Adornee = receiveCashPart
	billboard.Enabled = true

	-- Prefer using PadGui
	local existingPadGui = billboard:FindFirstChild("PadGui")
	if existingPadGui and existingPadGui:IsA("TextLabel") then
		return existingPadGui
	end

	local template = ReplicatedStorage:FindFirstChild(MONEY_GUI_TEMPLATE_NAME, true)
	if template then
		local templatePadGui = template:FindFirstChild("PadGui", true)
		if templatePadGui and templatePadGui:IsA("TextLabel") then
			local clonePadGui = templatePadGui:Clone()
			clonePadGui.Name = "PadGui"
			clonePadGui.Parent = billboard
			return clonePadGui
		end
	end

	local newLabel = billboard:FindFirstChild("PadGui")
	if not newLabel or not newLabel:IsA("TextLabel") then
		newLabel = Instance.new("TextLabel")
		newLabel.Name = "PadGui"
		newLabel.Size = UDim2.new(1, 0, 1, 0)
		newLabel.BackgroundTransparency = 1
		newLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
		newLabel.TextStrokeTransparency = 0.2
		newLabel.Font = Enum.Font.GothamBold
		newLabel.TextScaled = true
		newLabel.Parent = billboard
	end

	return newLabel
end

local function normalizeRateLabelVisual(label: TextLabel)
	label.Name = "PadGui"
	label.Size = UDim2.new(1, 0, 1, 0)
	label.Position = UDim2.new(0, 0, 0, 0)
	label.AnchorPoint = Vector2.new(0, 0)
	label.BackgroundTransparency = 1
	label.TextScaled = true
	if label.TextTransparency >= 0.95 then
		label.TextTransparency = 0
	end
end

local function setRateLabelVisible(label: TextLabel, visible: boolean)
	normalizeRateLabelVisual(label)
	label.Visible = visible

	local parentGui = label.Parent
	if parentGui and parentGui:IsA("LayerCollector") then
		parentGui.Enabled = true
	end
end

local function updateSlotRateGui(baseFolder: Instance, slotName: string, rate: number?, slotRef: BasePart?)
	local receiveCashPart = findReceiveCashPart(baseFolder, slotName, slotRef)
	if not receiveCashPart then
		warn("Rate GUI: ReceiveCash not found for slot", slotName, "in base", baseFolder.Name)
		return
	end

	local label = getOrCreateRateLabel(receiveCashPart)
	normalizeRateLabelVisual(label)
	local validRate = tonumber(rate) or 0
	if validRate <= 0 then
		label.Text = ""
		setRateLabelVisible(label, false)
		return
	end

	label.Text = formatRateText(validRate, true)
	setRateLabelVisible(label, true)
end

local function updateCollectPadDisplays()
	local penguinsFolder = workspace:FindFirstChild("Penguins")
	if not penguinsFolder then return end

	for _, penguinModel in ipairs(penguinsFolder:GetChildren()) do
		if not penguinModel:IsA("Model") then continue end

		local ownerPlot = penguinModel:FindFirstChild("OwnerPlot")
		local ownerSlot = penguinModel:FindFirstChild("OwnerSlot")
		local rateValue = penguinModel:FindFirstChild("MoneyPerSecond")
		local lastCollected = penguinModel:FindFirstChild("LastCollected")

		if not (ownerPlot and ownerSlot and rateValue) then
			continue
		end

		local baseFolder = Bases:FindFirstChild(tostring(ownerPlot.Value))
		if not baseFolder then continue end

		local receiveCashPart = findReceiveCashPart(baseFolder, ownerSlot.Value)
		if not receiveCashPart then continue end

		local label = getOrCreateRateLabel(receiveCashPart)

		local now = os.clock()

		if not lastCollected then
			lastCollected = Instance.new("NumberValue")
			lastCollected.Name = "LastCollected"
			lastCollected.Value = now
			lastCollected.Parent = penguinModel
		end

		local elapsed = now - lastCollected.Value
		if elapsed < 0 then elapsed = 0 end

		local amount = math.floor(rateValue.Value * elapsed)

		if amount <= 0 then
			label.Text = "$0"
		else
			label.Text = COLLECT_PAD_FORMAT:format(amount)
		end

		setRateLabelVisible(label, true)
	end
end

--loop to update
task.spawn(function()
	while true do
		task.wait(0.5)
		updateCollectPadDisplays()
	end
end)
local function hideAllRateGuis()
	for _, baseFolder in ipairs(Bases:GetChildren()) do
		for _, desc in ipairs(baseFolder:GetDescendants()) do
			if desc:IsA("BasePart") and desc.Name == "ReceiveCash" then
				local label = findFirstTextLabel(desc.Parent and desc.Parent:FindFirstChild("BrainrotHolder"))
					or findFirstTextLabel(desc.Parent)
					or findFirstTextLabel(desc)

				if label then
					label.Text = ""
					setRateLabelVisible(label, false)
				end
			end
		end
	end
end

local function refreshPlacedPenguinRateGuis()
	local workspacePenguins = workspace:FindFirstChild("Penguins")
	if not workspacePenguins then
		return
	end

	for _, penguinModel in ipairs(workspacePenguins:GetChildren()) do
		if not penguinModel:IsA("Model") then
			continue
		end

		local ownerPlot = penguinModel:FindFirstChild("OwnerPlot")
		local ownerSlot = penguinModel:FindFirstChild("OwnerSlot")
		local rateValue = penguinModel:FindFirstChild("MoneyPerSecond")
		if not (ownerPlot and ownerPlot:IsA("IntValue")) then
			continue
		end
		if not (ownerSlot and ownerSlot:IsA("StringValue")) then
			continue
		end

		local baseFolder = Bases:FindFirstChild(tostring(ownerPlot.Value))
		if not baseFolder then
			continue
		end

		local rate = 0
		if rateValue and rateValue:IsA("NumberValue") then
			rate = rateValue.Value
		end

		updateSlotRateGui(baseFolder, ownerSlot.Value, rate, nil)
	end
end

local function getPlacementPart(model: Model): BasePart?
	local torso = model:FindFirstChild("Torso")
	if torso and torso:IsA("BasePart") then
		return torso
	end
	if model.PrimaryPart and model.PrimaryPart:IsA("BasePart") then
		return model.PrimaryPart
	end
	return model:FindFirstChildWhichIsA("BasePart")
end

local function getFlatLook(slot: BasePart): Vector3
	local look = slot.CFrame.LookVector
	local flatLook = Vector3.new(look.X, 0, look.Z)
	if flatLook.Magnitude < 0.001 then
		local right = slot.CFrame.RightVector
		flatLook = Vector3.new(right.X, 0, right.Z)
	end
	if flatLook.Magnitude < 0.001 then
		flatLook = Vector3.new(0, 0, -1)
	end
	return flatLook.Unit
end

local function getGroundY(slot: BasePart, penguinModel: Model): number
	local slotTopY = slot.Position.Y + (slot.Size.Y * 0.5)

	local rayParams = RaycastParams.new()
	rayParams.FilterType = Enum.RaycastFilterType.Exclude
	local excludes = {penguinModel, slot}
	if slot.Parent then
		table.insert(excludes, slot.Parent)
	end
	rayParams.FilterDescendantsInstances = excludes

	-- Cast from just above this slot 
	local origin = slot.Position + Vector3.new(0, (slot.Size.Y * 0.5) + GROUND_RAY_ABOVE_SLOT, 0)
	local direction = Vector3.new(0, -(slot.Size.Y + GROUND_RAY_DEPTH_BELOW_SLOT), 0)
	local hit = workspace:Raycast(origin, direction, rayParams)

	if hit then
		return hit.Position.Y
	end

	--top surface of slot
	return slotTopY
end

local function getPartBottomY(part: BasePart): number
	local half = part.Size * 0.5
	local cf = part.CFrame
	local yExtent =
		math.abs(cf.XVector.Y) * half.X +
		math.abs(cf.YVector.Y) * half.Y +
		math.abs(cf.ZVector.Y) * half.Z
	return cf.Position.Y - yExtent
end

local function shouldUsePartForGround(part: BasePart): boolean
	if IGNORE_PART_NAMES_FOR_GROUND[part.Name] then
		return false
	end
	if part.Transparency >= 0.98 then
		return false
	end
	return true
end

local function getModelBottomY(model: Model): number
	local lowest = math.huge
	local found = false

	for _, desc in ipairs(model:GetDescendants()) do
		if desc:IsA("BasePart") and shouldUsePartForGround(desc) then
			local partBottomY = getPartBottomY(desc)
			if partBottomY < lowest then
				lowest = partBottomY
			end
			found = true
		end
	end

	if found then
		return lowest
	end

	local bbCf, bbSize = model:GetBoundingBox()
	return bbCf.Position.Y - (bbSize.Y * 0.5)
end

local function placePenguinOnSlot(slot: BasePart, penguinModel: Model)
	local placementPart = getPlacementPart(penguinModel)
	if not placementPart then
		return
	end

	local flatLook = getFlatLook(slot)

	-- not raw model pivot orientation.
	local refToModel = placementPart.CFrame:ToObjectSpace(penguinModel:GetPivot())
	local desiredRef = CFrame.lookAt(slot.Position, slot.Position + flatLook, Vector3.yAxis)
		* CFrame.Angles(
			math.rad(DEFAULT_SLOT_PITCH_OFFSET),
			math.rad(DEFAULT_SLOT_YAW_OFFSET),
			math.rad(DEFAULT_SLOT_ROLL_OFFSET)
		)

	penguinModel:PivotTo(desiredRef * refToModel)

	-- Snap bottom of visible model parts onto ground below the slot.
	local bottomY = getModelBottomY(penguinModel)
	local targetBottomY = getGroundY(slot, penguinModel)
	local yFix = (targetBottomY - bottomY) + GROUND_CLEARANCE
	penguinModel:PivotTo(penguinModel:GetPivot() + Vector3.new(0, yFix, 0))
end

local PenguinId = ReplicatedStorage:FindFirstChild("PenguinId")
if not PenguinId then
	PenguinId = Instance.new("IntValue")
	PenguinId.Name = "PenguinId"
	PenguinId.Parent = ReplicatedStorage
end

local PlotHolders = ReplicatedStorage:FindFirstChild("PlotHolders")
if not PlotHolders then
	PlotHolders = Instance.new("Folder")
	PlotHolders.Name = "PlotHolders"
	PlotHolders.Parent = ReplicatedStorage
end

--propm action
local function handlePrompt(player, prompt, requiredPlot)
	local plotValue = player:FindFirstChild("PlotNumber")
	if not plotValue then return end
	if plotValue.Value ~= requiredPlot then return end

end

-- shows only ur base prompt
local function updatePrompts(player)
	local plotNumberValue = player:FindFirstChild("PlotNumber")
	if not plotNumberValue then return end
	local plotNumber = plotNumberValue.Value

	for _, base in pairs(Bases:GetChildren()) do
		local promptFolder = base:FindFirstChild("promt")
		if not promptFolder then continue end

		local enabled = tonumber(base.Name) == plotNumber
		for _, slot in pairs(promptFolder:GetChildren()) do
			local prompt = slot:FindFirstChild("ProximityPrompt")
			if prompt then
				prompt.Enabled = enabled
			end
		end
	end
end

-- prompts connector 
for _, base in pairs(Bases:GetChildren()) do
	local plotNumber = tonumber(base.Name)
	local promptFolder = base:FindFirstChild("promt")
	if not promptFolder then continue end

	for _, slot in pairs(promptFolder:GetChildren()) do
		local capturedSlot = slot
		local capturedPlotNumber = plotNumber
		local capturedBase = base
		local prompt = capturedSlot:FindFirstChild("ProximityPrompt")
		if not prompt then continue end

		prompt.Triggered:Connect(function(player)

			print("Triggered prompt from:")
			print("Plot:", capturedPlotNumber)
			print("Slot:", capturedSlot.Name)

			handlePrompt(player, prompt, capturedPlotNumber)

			-- check if player holding penguin
			local holding = player:FindFirstChild("CurrentPenguin")
			if not holding or not holding.Value then
				print("Player not holding penguin")
				return
			end

			local penguinModel = holding.Value
			local torso = penguinModel:FindFirstChild("Torso")
			if not torso then return end

			-- destroy weld
			local character = player.Character
			if character then
				local body = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
				if body then
					local weld = body:FindFirstChild("PlayerWeld")
					if weld then
						weld:Destroy()
					end
				end
			end

			if not capturedSlot:IsA("BasePart") then
				warn("Invalid slot (not BasePart):", capturedSlot:GetFullName())
				return
			end

			-- Anchor all parts before final placement
			for _, desc in ipairs(penguinModel:GetDescendants()) do
				if desc:IsA("BasePart") then
					desc.Anchored = true
				end
			end

			-- move penguin to slot
			placePenguinOnSlot(capturedSlot, penguinModel)
			torso.Anchored = true

			-- add to inventory
			local penguinData = findPenguinDataByName(penguinModel.Name)

			if penguinData then
				PenguinData.PlayerBaseInventory:AddItem(player, penguinData)
			end

			-- Mark ownership/rate
			local ownerUserId = penguinModel:FindFirstChild("OwnerUserId")
			if not ownerUserId then
				ownerUserId = Instance.new("IntValue")
				ownerUserId.Name = "OwnerUserId"
				ownerUserId.Parent = penguinModel
			end
			ownerUserId.Value = player.UserId

			local ownerPlot = penguinModel:FindFirstChild("OwnerPlot")
			if not ownerPlot then
				ownerPlot = Instance.new("IntValue")
				ownerPlot.Name = "OwnerPlot"
				ownerPlot.Parent = penguinModel
			end
			ownerPlot.Value = capturedPlotNumber

			local ownerSlot = penguinModel:FindFirstChild("OwnerSlot")
			if not ownerSlot then
				ownerSlot = Instance.new("StringValue")
				ownerSlot.Name = "OwnerSlot"
				ownerSlot.Parent = penguinModel
			end
			ownerSlot.Value = capturedSlot.Name

			local rateValue = penguinModel:FindFirstChild("MoneyPerSecond")
			if not rateValue then
				rateValue = Instance.new("NumberValue")
				rateValue.Name = "MoneyPerSecond"
				rateValue.Parent = penguinModel
			end
			rateValue.Value = resolvePenguinRate(penguinModel, penguinData)
			updateSlotRateGui(capturedBase, capturedSlot.Name, rateValue.Value, capturedSlot)

			-- clear holding
			holding.Value = nil

			print("Placed:", penguinModel.Name)

		end)
	end
end

hideAllRateGuis()
refreshPlacedPenguinRateGuis()

--  join
Players.PlayerAdded:Connect(function(player)
	-- Plot number value
	local PlotNumber = Instance.new("IntValue")
	PlotNumber.Name = "PlotNumber"
	PlotNumber.Parent = player

	-- ensure player entry exists in PenguinData.PlayerBaseInventory.Players 
	if not PenguinData.PlayerBaseInventory.Players[player.UserId] then
		PenguinData.PlayerBaseInventory.Players[player.UserId] = { Inventory = {} }
	end

	-- assign free plot
	for i = 1, 5 do
		if not PlotHolders:FindFirstChild(tostring(i)) then
			local ClaimPlot = Instance.new("ObjectValue")
			ClaimPlot.Name = tostring(i)
			ClaimPlot.Value = player
			ClaimPlot.Parent = PlotHolders

			PlotNumber.Value = i
			break
		end
	end


	local plotFolder = Bases:FindFirstChild(tostring(PlotNumber.Value))
	local baseModel = plotFolder:FindFirstChild("Base" .. tostring(PlotNumber.Value))
	local floorsFolder = baseModel:FindFirstChild("Floors")

	Manager:LoadFloors(player, floorsFolder)


	-- teleport                          
	local function setupCharacter(character)
		if not plotFolder then return end

		local teleportPart = plotFolder:WaitForChild("teleport")
		character:PivotTo(teleportPart.CFrame)

		--updatePrompts(player)
	end

	-- if character already exists
	if player.Character then
		setupCharacter(player.Character)
	end

	-- future spawns
	player.CharacterAdded:Connect(setupCharacter)
	
	-- update sign
	local sign = plotFolder.Sign
	sign.PlayerDisplay.SurfaceGui.PlayerName.Text = player.Name .. "'s base"

	local thumbnailType = Enum.ThumbnailType.HeadShot
	local thumbnailSize = Enum.ThumbnailSize.Size420x420
	local PlayerIcon, isReady = Players:GetUserThumbnailAsync(player.UserId, thumbnailType, thumbnailSize)

	sign.PlayerDisplay.SurfaceGui.PlayerPfp.Image = PlayerIcon -- set the player's image
	sign.PlayerDisplay.SurfaceGui.Enabled = true

end)

-- when a player leaves, free their claim so others can get it later
Players.PlayerRemoving:Connect(function(player)
	-- find and remove 
	for _, claim in pairs(PlotHolders:GetChildren()) do
		if claim.Value == player then
			claim:Destroy()
		end
	end
end)



-- touch cooldown
local TOUCH_COOLDOWN = 0.75
local lastTouch = {}



-- finds penguin slot
local function findPenguinBySlot(plotNumber, slotName)
	local penguinsFolder = workspace:FindFirstChild("Penguins")
	if not penguinsFolder then return nil end

	local slotNumber = tostring(slotName):match("%d+")
	if not slotNumber then return nil end

	for _, model in ipairs(penguinsFolder:GetChildren()) do
		if model:IsA("Model") then
			local ownerPlot = model:FindFirstChild("OwnerPlot")
			local ownerSlot = model:FindFirstChild("OwnerSlot")

			if ownerPlot and ownerSlot then
				local ownerNumber = tostring(ownerSlot.Value):match("%d+")

				if ownerPlot.Value == plotNumber and "P" .. ownerNumber == "P"..slotNumber then
					return model
				end
			end
		end
	end

	return nil
end



-- connectReceivePart Func
local function connectReceivePart(receivePart, plotNumber)
	local slotName = receivePart.Parent.Name

	receivePart.Touched:Connect(function(hit)
		local character = hit.Parent
		if not character then return end

		local player = Players:GetPlayerFromCharacter(character)
		if not player then return end

		local plotValue = player:FindFirstChild("PlotNumber")
		if not plotValue or plotValue.Value ~= plotNumber then
			return
		end

		local penguinModel = findPenguinBySlot(plotNumber, slotName)
		if not penguinModel then return end

		local rate = penguinModel:FindFirstChild("MoneyPerSecond")
		if not rate or rate.Value <= 0 then return end
		
		if lastTouch[player] ~= nil then return end
		
		local lastCollected = penguinModel:FindFirstChild("LastCollected")
		if not lastCollected then
			lastCollected = Instance.new("NumberValue")
			lastCollected.Name = "LastCollected"
			lastCollected.Value = os.clock()
			lastCollected.Parent = penguinModel
			return
		end

		local now = os.clock()
		local elapsed = now - lastCollected.Value
		if elapsed <= 0 then return end

		local amount = math.floor(rate.Value * elapsed)
		if amount <= 0 then return end

		lastCollected.Value = now
		
		
		lastTouch[player] = true
		task.delay(TOUCH_COOLDOWN, function() lastTouch[player] = nil end)
		Manager:AddStat(player, "Currency", amount)
	end)
end



-- loops through every base folder inside "Bases"
for _, baseFolder in ipairs(Bases:GetChildren()) do
	local plotNumber = tonumber(baseFolder.Name)
	if not plotNumber then continue end

	local baseModel = baseFolder:FindFirstChild("Base" .. baseFolder.Name)
	if not baseModel then continue end

	local floors = baseModel:FindFirstChild("Floors")
	if not floors then continue end

	for _, floor in ipairs(floors:GetChildren()) do
		local podiumFolder = floor:FindFirstChild("Podeium")
		if not podiumFolder then continue end

		for _, podium in ipairs(podiumFolder:GetChildren()) do
			local receive = podium:FindFirstChild("ReceiveCash")
			if receive and receive:IsA("BasePart") then
				connectReceivePart(receive, plotNumber)
			end
		end
	end

end
