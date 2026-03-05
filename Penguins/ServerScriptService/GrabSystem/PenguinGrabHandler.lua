-- server script

local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PenguinGrab = require(ReplicatedStorage.Modules.grab)

local WorkspacePenguins = Workspace:WaitForChild("Penguins")

-- prevents double connecting the same penguin
local connectedPenguins = {}

local function setupPenguin(penguin)
	if connectedPenguins[penguin] then return end
	connectedPenguins[penguin] = true

	local torso = penguin:FindFirstChild("Torso")
	if not torso then return end

	local prompt = torso:FindFirstChild("ProximityPrompt")
	if not prompt then return end

	prompt.Triggered:Connect(function(player)

		if not prompt.Enabled then return end
		prompt.Enabled = false

		print("Grabbed:", penguin.Name)

		-- weld penguin to player
		PenguinGrab.GrabPenguin(player, penguin)

		-- store which penguin player is holding
		local holding = player:FindFirstChild("CurrentPenguin")
		if not holding then
			holding = Instance.new("ObjectValue")
			holding.Name = "CurrentPenguin"
			holding.Parent = player
		end

		holding.Value = penguin
	end)
end

-- connect already existing penguins
for _, penguin in ipairs(WorkspacePenguins:GetChildren()) do
	setupPenguin(penguin)
end

-- connect future spawned penguins
WorkspacePenguins.ChildAdded:Connect(setupPenguin)