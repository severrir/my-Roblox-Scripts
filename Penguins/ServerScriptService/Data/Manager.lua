-- module script 
local Manager = {}

Manager.Profiles = {}

local BasicStats = {"Currency", "Rebirth", "PenguinsFound", "Gamepasses", "Codes", "Gifts", "GiftsGiven"}


function Manager:GetProfile(player)
	local timeout = 10
	local start = tick()

	while not Manager.Profiles[player] do
		if tick() - start > timeout then
			warn("Profile load timeout for", player)
			return nil
		end
		task.wait()
	end

	return Manager.Profiles[player]
end


function Manager:LoadFloors(player, floorsFolder: Folder)
	local profile = Manager:GetProfile(player)
	if profile == nil then return end

	local plotData = profile.Data.Plot
	if plotData == nil then return end

	local floorsUnlocked = plotData.Floors
	if floorsUnlocked == nil then return end

	for _, floorFolder in ipairs(floorsFolder:GetChildren()) do
		if not floorFolder:IsA("Folder") then continue end

		local floorNumber = tonumber(string.match(floorFolder.Name, "%d+"))
		if not floorNumber then continue end

		local shouldBeVisible = floorNumber <= floorsUnlocked

		for _, descendant in ipairs(floorFolder:GetDescendants()) do

			if descendant:IsA("BasePart") and not descendant:IsA("TrussPart") then
				descendant.Transparency = shouldBeVisible and 0 or 1
				descendant.CanCollide = shouldBeVisible

			elseif descendant:IsA("Decal") or descendant:IsA("Texture") then
				descendant.Transparency = shouldBeVisible and 0 or 1

			elseif descendant:IsA("SurfaceAppearance") then
				descendant.Enabled = shouldBeVisible
			end

		end
	end
end

function Manager:AddStat(player, key, value) -- Adds a basic stat to a player
	local profile = Manager.Profiles[player]
	if profile == nil then return end
	if not table.find(BasicStats, key) then warn("Not a basic stat") return end
	
	local current = profile.Data.Player[key]
	if current == nil then
		warn("Stat does not exist in profile:", key)
		return
	end
	
	if typeof(current) == "table" then
		table.insert(current, value)
	elseif typeof(current) == "number" and typeof(value) == "number" then
		profile.Data.Player[key] = math.max(0, current + value)
		
		if key == "Currency" then
			local leaderstats = player:FindFirstChild("leaderstats")
			if not leaderstats then return end
			local money = leaderstats:FindFirstChild("Money")
			if money and money:IsA("IntValue") then
				money.Value = profile.Data.Player[key]
			end
		end
		
		
	else
		warn("Invalid stat type for:", key)
	end
	
	
end

return Manager
