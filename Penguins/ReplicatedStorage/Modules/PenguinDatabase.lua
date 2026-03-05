-- module script 

local module = {}

-- penguins data
module.Penguins = {
	
	-- Commons
	{
		ID = 1, 
		Name = "Baby pengy", MoneyPerSecond = 100, Description = "he likes to cry",
		Location =  game.ReplicatedStorage.Penguins.Rarity.Common["Baby Pengy"].Torso, Slot = 0,
		Prompt = game.ReplicatedStorage.Penguins.Rarity.Common["Baby Pengy"].Torso.ProximityPrompt
	},
	
	{
		ID = 2,
		Name = "Pengy", MoneyPerSecond = 1, Description = "he is just a chill guy",
		Location = game.ReplicatedStorage.Penguins.Rarity.Common["Pengy"].Torso, Slot = 0
	},
	
	{
		ID = 3,
		Name = "Fat Pengy", MoneyPerSecond = 300, Description = "Hevie Fat Peggy",
		Location = game.ReplicatedStorage.Penguins.Rarity.Common["Fat peggy"].Torso, Slot = 0,
		Prompt = game.ReplicatedStorage.Penguins.Rarity.Common["Fat peggy"].Torso.ProximityPrompt
	},
	
	{
		ID = 4,
		Name = "Fisherman Pengy", MoneyPerSecond = 15, Description = "Likes Fish",
		Location = game.ReplicatedStorage.Penguins.Rarity.Common["Fisherman Pengy"].Torso, Slot = 0,
		Prompt = game.ReplicatedStorage.Penguins.Rarity.Common["Fisherman Pengy"].Torso.ProximityPrompt
	},
	
	{
		ID = 5,
		Name = "Sleepy Peggy", MoneyPerSecond = 100, Description = "he is sleeping beauty",
		Location = game.ReplicatedStorage.Penguins.Rarity.Common["Sleepy Peggy"].Torso, Slot = 0,
		Prompt = game.ReplicatedStorage.Penguins.Rarity.Common["Sleepy Peggy"].Torso.ProximityPrompt
	},
	
	{
		ID = 6, 
		Name = "Pirate peggy", MoneyPerSecond = 65, Description = "loves seal",
		Location = game.ReplicatedStorage.Penguins.Rarity.Common["Pirate Pengy"].Torso, Slot = 0,
		Prompt = game.ReplicatedStorage.Penguins.Rarity.Common["Pirate Pengy"].Torso.ProximityPrompt
	},

	{
		ID = 7, 
		Name = "ninja peggy", MoneyPerSecond = 50, Description = "he is sneaky",
		Location = game.ReplicatedStorage.Penguins.Rarity.Common["Ninja Pengy"].Torso, Slot = 0,
		Prompt = game.ReplicatedStorage.Penguins.Rarity.Common["Ninja Pengy"].Torso.ProximityPrompt
	},
	
	{
		ID = 8, 
		Name = "witch peggy", MoneyPerSecond = 50, Description = "she brooms deadly potions",
		Location = game.ReplicatedStorage.Penguins.Rarity.Common["Witch Pengy"].Torso, Slot = 0,
		Prompt = game.ReplicatedStorage.Penguins.Rarity.Common["Witch Pengy"].Torso.ProximityPrompt
	},
	
	--Ucommons
	{
		ID = 9, 
		Name = "Cold Penggy", MoneyPerSecond = 50, Description = "he is cold",
		Location = game.ReplicatedStorage.Penguins.Rarity.Uncommon["Cold Penggy"].Torso, Slot = 0,
		Prompt = game.ReplicatedStorage.Penguins.Rarity.Uncommon["Cold Penggy"].Torso.ProximityPrompt
	},
	
	{
		ID = 10, 
		Name = "Pool Peggy", MoneyPerSecond = 50, Description = "Likes swimming",
		Location = game.ReplicatedStorage.Penguins.Rarity.Uncommon["Pool Peggy"].Torso, Slot = 0,
		Prompt = game.ReplicatedStorage.Penguins.Rarity.Uncommon["Pool Peggy"].Torso.ProximityPrompt
	},
	
	{
		ID = 11, 
		Name = "Warrior Penggy", MoneyPerSecond = 50, Description = "He is the real Penguin",
		Location = game.ReplicatedStorage.Penguins.Rarity.Uncommon["Warrior Penggy"].Torso, Slot = 0,
		Prompt = game.ReplicatedStorage.Penguins.Rarity.Uncommon["Warrior Penggy"].Torso.ProximityPrompt
	},
	
	{
		ID = 12, 
		Name = "Zombie Penggy", MoneyPerSecond = 50, Description = "he loves brains",
		Location = game.ReplicatedStorage.Penguins.Rarity.Uncommon["Zombie Penggy"].Torso, Slot = 0,
		Prompt = game.ReplicatedStorage.Penguins.Rarity.Uncommon["Zombie Penggy"].Torso.ProximityPrompt
	},
	
	{
		ID = 13, 
		Name = "Astronalt penggy", MoneyPerSecond = 50, Description = "he loves to explore space",
		Location = game.ReplicatedStorage.Penguins.Rarity.Uncommon["Astronalt penggy"].Torso, Slot = 0,
		Prompt = game.ReplicatedStorage.Penguins.Rarity.Uncommon["Astronalt penggy"].Torso.ProximityPrompt
	},
	
	{
		ID = 14, 
		Name = "constracter penggy", MoneyPerSecond = 50, Description = "he loves building",
		Location = game.ReplicatedStorage.Penguins.Rarity.Uncommon["constracter penggy"].Torso, Slot = 0,
		Prompt = game.ReplicatedStorage.Penguins.Rarity.Uncommon["constracter penggy"].Torso.ProximityPrompt
	},
	
	{
		ID = 15, 
		Name = "explorer penggy", MoneyPerSecond = 50, Description = "he exploring",
		Location = game.ReplicatedStorage.Penguins.Rarity.Uncommon["explorer penggy"].Torso, Slot = 0,
		Prompt = game.ReplicatedStorage.Penguins.Rarity.Uncommon["explorer penggy"].Torso.ProximityPrompt
	},
	
	{
		ID = 16,             
		Name = "ice peggy", MoneyPerSecond = 50, Description = "Loves ice",
		Location = game.ReplicatedStorage.Penguins.Rarity.Uncommon["ice peggy"].Torso, Slot = 0,
		Prompt = game.ReplicatedStorage.Penguins.Rarity.Uncommon["ice peggy"].Torso.ProximityPrompt
	},
	
	{
		ID = 17,             
		Name = "knight penggy", MoneyPerSecond = 50, Description = "he is good at sword fights",
		Location = game.ReplicatedStorage.Penguins.Rarity.Uncommon["knight penggy"].Torso, Slot = 0,
		Prompt = game.ReplicatedStorage.Penguins.Rarity.Uncommon["knight penggy"].Torso.ProximityPrompt
	},
	
	-- rare
	
	{
		ID = 18,             
		Name = "Cop Pengy", MoneyPerSecond = 50, Description = "hate criminals",
		Location = game.ReplicatedStorage.Penguins.Rarity.Rare["Cop Pengy"].Torso, Slot = 0,
		Prompt = game.ReplicatedStorage.Penguins.Rarity.Rare["Cop Pengy"].Torso.ProximityPrompt
	},
	
	{
		ID = 19,             
		Name = "Doctor Penggy", MoneyPerSecond = 50, Description = "love saveing people",
		Location = game.ReplicatedStorage.Penguins.Rarity.Rare["Doctor Penggy"].Torso, Slot = 0,
		Prompt = game.ReplicatedStorage.Penguins.Rarity.Rare["Doctor Penggy"].Torso.ProximityPrompt
	},
	
	{
		ID = 20,             
		Name = "Rounded Penggy", MoneyPerSecond = 50, Description = "he is just round",
		Location = game.ReplicatedStorage.Penguins.Rarity.Rare["Rounded Penggy"].Torso, Slot = 0,
		Prompt = game.ReplicatedStorage.Penguins.Rarity.Rare["Rounded Penggy"].Torso.ProximityPrompt
	},
	
	{
		ID = 21,             
		Name = "SnowBorder Penggy", MoneyPerSecond = 50, Description = "loves Snowbording",
		Location = game.ReplicatedStorage.Penguins.Rarity.Rare["SnowBorder Penggy"].Torso, Slot = 0,
		Prompt = game.ReplicatedStorage.Penguins.Rarity.Rare["SnowBorder Penggy"].Torso.ProximityPrompt
	},
		

	--{
	--	ID = 22,             
	--	Name = "Vampire Penggy", MoneyPerSecond = 50, Description = "loves Blood",
	--	Location = game.ReplicatedStorage.Penguins.Rarity.Rare["Vampire Penggy"].Torso, Slot = 0,
	--	Prompt = game.ReplicatedStorage.Penguins.Rarity.Rare["Vampire Penggy"].Torso.ProximityPrompt
	--},
	
	{
		ID = 23,             
		Name = "indiana penggy", MoneyPerSecond = 50, Description = "he is indiana jones",
		Location = game.ReplicatedStorage.Penguins.Rarity.Rare["indiana penggy"].Torso, Slot = 0,
		Prompt = game.ReplicatedStorage.Penguins.Rarity.Rare["indiana penggy"].Torso.ProximityPrompt
	},
	-- Legendary
	{
		ID = 24,             
		Name = "Hammer  Penggy", MoneyPerSecond = 50, Description = "Loves Hammers",
		Location = game.ReplicatedStorage.Penguins.Rarity.Legendary["Hammer  Penggy"].Torso, Slot = 0,
		Prompt = game.ReplicatedStorage.Penguins.Rarity.Legendary["Hammer  Penggy"].Torso.ProximityPrompt
	},
	
	{
		ID = 25,             
		Name = "Skeleton Penggy", MoneyPerSecond = 50, Description = "he is a Skeleton",
		Location = game.ReplicatedStorage.Penguins.Rarity.Legendary["Skeleton Penggy"].Torso, Slot = 0,
		Prompt = game.ReplicatedStorage.Penguins.Rarity.Legendary["Skeleton Penggy"].Torso.ProximityPrompt
	},
	
	{
		ID = 26,             
		Name = "angel penggy", MoneyPerSecond = 50, Description = "he is an Angel",
		Location = game.ReplicatedStorage.Penguins.Rarity.Legendary["angel penggy"].Torso, Slot = 0,
		Prompt = game.ReplicatedStorage.Penguins.Rarity.Legendary["angel penggy"].Torso.ProximityPrompt
	},
	-- Ice Kings
	{
		ID = 27,             
		Name = "Blue Pinguin King", MoneyPerSecond = 50, Description = "Blue Pinguin King",
		Location = game.ReplicatedStorage.Penguins.Rarity["Ice King"]["Blue Pinguin King"].Torso, Slot = 0,
		Prompt = game.ReplicatedStorage.Penguins.Rarity["Ice King"]["Blue Pinguin King"].Torso.ProximityPrompt
	},
	
	{
		ID = 28,             
		Name = "Red Pinguin King", MoneyPerSecond = 50, Description = "Red Pinguin King",
		Location = game.ReplicatedStorage.Penguins.Rarity["Ice King"]["Red Pinguin King"].Torso, Slot = 0,
		Prompt = game.ReplicatedStorage.Penguins.Rarity["Ice King"]["Red Pinguin King"].Torso.ProximityPrompt
	},
	
	{
		ID = 29,             
		Name = "Ice King ", MoneyPerSecond = 50, Description = "He rules the ice",
		Location = game.ReplicatedStorage.Penguins.Rarity["Ice King"]["Ice King"].Torso, Slot = 0,
		Prompt = game.ReplicatedStorage.Penguins.Rarity["Ice King"]["Ice King"].Torso.ProximityPrompt
	},
	
	
	{
		ID = 30,             
		Name = "Ice God", MoneyPerSecond = 50, Description = "He rules the ices and kings",
		Location = game.ReplicatedStorage.Penguins.Rarity.Godly["Ice God"].Torso, Slot = 0,
		Prompt = game.ReplicatedStorage.Penguins.Rarity.Godly["Ice God"].Torso.ProximityPrompt
	},
	
	
	
}

-- base slots am gone say like dat 
module.PlayerBaseInventory = {
	Players = {} 
}

local PlayerBaseInventory = module.PlayerBaseInventory


-- creates inventory for player
function PlayerBaseInventory:CreateInventory(player)
	if not self.Players[player.UserId] then
		self.Players[player.UserId] = {
			UserId = player.UserId,
			Inventory = {}
		}
		print("Created new inventory for", player.Name)
	end
end 

-- this is for adding items to the inventory
function PlayerBaseInventory:AddItem(player, item)
	if not self.Players[player.UserId] then
		self:CreateInventory(player)
	end

	local inventory = self.Players[player.UserId].Inventory

	table.insert(inventory, item)

	print(("Item '%s' has been added to %s's inventory."):format(item.Name or "Unknown", player.Name))
end

function module:GetPenguinByID(id)
	for _, penguin in ipairs(self.Penguins) do
		if penguin.ID == id then
			return penguin
		end
	end
end

return module