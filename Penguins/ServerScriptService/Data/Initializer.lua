-- server script btw

local ProfileStore = require(game.ServerScriptService.Data.ProfileStore)

local PROFILE_TEMPLATE = require(script.Parent.Template)
local Manager = require(script.Parent.Manager)

local Players = game:GetService("Players")

local PlayerStore = ProfileStore.New("PlayerStore1", PROFILE_TEMPLATE)




--local Profiles: {[Player]: typeof(PlayerStore:StartSessionAsync())} = {}

local function PlayerAdded(player)


	local profile = PlayerStore:StartSessionAsync(`{player.UserId}`, {
		Cancel = function()
			return player.Parent ~= Players
		end,
	})


	if profile ~= nil then

		profile:AddUserId(player.UserId) 
		profile:Reconcile() 
		
		if profile.Data.Version ~= PROFILE_TEMPLATE.Version then
			profile.Data = table.clone(PROFILE_TEMPLATE)
			profile:Reconcile()
		end
		
		profile.OnSessionEnd:Connect(function()
			Manager.Profiles[player] = nil
			player:Kick(`Profile session end - Please rejoin`)
		end)

		if player.Parent == Players then
			Manager.Profiles[player] = profile
			
			local leaderstats = player:FindFirstChild("leaderstats")
			if not leaderstats then return end
			local money = leaderstats:FindFirstChild("Money")
			if money and money:IsA("IntValue") then
				money.Value = profile.Data.Player["Currency"]
			end
			
			print(`Profile loaded for {player.DisplayName}!`)
			
		else
			
			profile:EndSession()
		end

	else
		
		player:Kick(`Profile load fail - Please rejoin`)
	end

end


for _, player in Players:GetPlayers() do
	task.spawn(PlayerAdded, player)
end

Players.PlayerAdded:Connect(PlayerAdded)

Players.PlayerRemoving:Connect(function(player)
	local profile = Manager.Profiles[player]
	if profile ~= nil then
		profile:EndSession()
	end
end)