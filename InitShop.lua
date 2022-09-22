local SavingModule = require(game.ServerScriptService.Modules.SavingModule)
local equip = require(script.Equip)
local Postie = require(game.ReplicatedStorage:WaitForChild("Postie"))

local function addShopItems(player, shopItems, itemsFolder)
	for index, value in pairs(shopItems) do
		-- checking if type is not table because of old data
		if type(value) ~= "table" then
			local itemValue = Instance.new("StringValue", player["ShopItems"].Backpacks)
			itemValue.Name = value
		end
	end
end

local function addItems(player, items, itemsFolder, category)
	for index, value in pairs(items) do
		local itemValue = Instance.new("StringValue", player["ShopItems"][category])
		itemValue.Name = value
	end
end

local function onAdded(player)
	
	--// Shop Items Handling
	local itemsFolder = Instance.new("Folder", player)
	itemsFolder.Name = "ShopItems"
	local backpacksFolder = Instance.new("Folder", itemsFolder)
	backpacksFolder.Name = "Backpacks"
	local costumesFolder = Instance.new("Folder", itemsFolder)
	costumesFolder.Name = "Costumes"
	
	local currentCoins = SavingModule:GetTable(player, "Coins")

	Postie.SignalClient('CurrentCoinsUpdaterSignal', player, currentCoins)
	
	local shopItems = SavingModule:GetValue(player, "ShopItems")
	local costumes = SavingModule:GetValue(player, "Costumes")
	local backpacks = SavingModule:GetValue(player, "Backpacks")
	
	local playerDoesNotHavePhe = next(costumes) == nil
	if playerDoesNotHavePhe then
		SavingModule:AddItem(player, "Costumes", "Phe")
		print("InitShop -> MESSAGE/Info: added phe to ", player.Name, "'s inventory..")
	else
		print("InitShop -> MESSAGE/Info: ", player.Name, " has phe in their inventory..")
	end
	
	local currentCostume = SavingModule:GetValue(player, "Costume")
	if currentCostume == "None" then
		currentCostume = "Phe"
	end
	setCostumeEquippedEvent:FireClient(player, currentCostume)
	
	addShopItems(player, shopItems, itemsFolder)
	addItems(player, costumes, itemsFolder, "Costumes")
	addItems(player, backpacks, itemsFolder, "Backpacks")
	
	--// Update Equipped
	local onAddedEquipped = SavingModule:GetValue(player, "Equipped")
	if onAddedEquipped == "None" then
		print("MESSAGE/Info:  equipped = none ") 
	else
		equip(player, onAddedEquipped)
		game.ReplicatedStorage.EventsFolder.SetIsEquippedEvent:FireClient(player, onAddedEquipped)
		game:GetService("TestService"):Warn(false, "MESSAGE/Info:  equipped" .. onAddedEquipped)
	end	
	
	player.CharacterAdded:Connect(function(character)
		local currentEquipped = SavingModule:GetValue(player, "Equipped")
		if currentEquipped ~= "None" then
			equip(player, currentEquipped)
			game.ReplicatedStorage.EventsFolder.SetIsEquippedEvent:FireClient(player, currentEquipped)
			game:GetService("TestService"):Warn(false, "MESSAGE/Info:  equipped" .. currentEquipped)
		end
	end)
end

local function findCat(name, items)
	for index, value in  pairs(items) do
		for i, v in pairs(value) do
			if i == name then
				return index
			end
		end
	end
end

local function addItemToInventory(player, info)
	local items = player:FindFirstChild("ShopItems")
	local coins = SavingModule:GetValue(player, 'Coins')
	warn(info)
	
	local category = findCat(info.name, info.items)

	local playerHasItem = items[category]:FindFirstChild(info.name)
	if playerHasItem then
		print("InitShop -> MESSAGE/Info:  ", player, " has ", info.name)
		return false
	end

	local hasEnoughCoins = coins >= info.cost
	if hasEnoughCoins then

		-- add item value to shop items
		local itemValue = Instance.new("StringValue", items[category])
		itemValue.Name = info.name
		
		SavingModule:AddItem(player, category, info.name)

		-- subtract cost from player coins
		SavingModule:IncrementValue(player, "Coins", -info.cost)

		print("MESSAGE/Info: ", player.Name, " has bought ", info.name, " and ", itemValue, " has been added to their inventory.")
		return true
	else
		return false
	end
end

local function init()
	
	local EventsFolder = Instance.new("Folder", game.ReplicatedStorage)
	EventsFolder.Name  = "EventsFolder"
	
	local onItemPurchaseEvent = Instance.new("RemoteFunction", EventsFolder)
	onItemPurchaseEvent.Name = "OnItemPurchaseEvent"
	
	local getInventoryEvent = Instance.new("RemoteFunction", EventsFolder)
	getInventoryEvent.Name = "GetInventoryEvent"
	
	local equipItemEvent = Instance.new("RemoteFunction", EventsFolder)
	equipItemEvent.Name = "EquipItemEvent"
	
	local findItemEvent = Instance.new("RemoteFunction", EventsFolder)
	findItemEvent.Name = "FindItemEvent"
	
	local handleEquipEvent = Instance.new("RemoteEvent", EventsFolder)
	handleEquipEvent.Name = "HandleEquipEvent"
	
	print(handleEquipEvent, " has been generated so should exist..........")
	
	local setIsEquippedEvent = Instance.new("RemoteEvent", EventsFolder)
	setIsEquippedEvent.Name = "SetIsEquippedEvent"
	
	local getInsigniasEvent = Instance.new("RemoteFunction", EventsFolder)
	getInsigniasEvent.Name = "GetInsigniasEvent"
	
	setCostumeEquippedEvent = Instance.new("RemoteEvent", EventsFolder)
	setCostumeEquippedEvent.Name = "SetCostumeEquippedEvent"
	
	local getCostumeEvent = Instance.new("RemoteFunction", EventsFolder)
	getCostumeEvent.Name = "GetCostumeEvent"
	
	local handleCostumeEvent = Instance.new("RemoteEvent", EventsFolder)
	handleCostumeEvent.Name = "HandleCostumeEvent"
	
	game.Players.PlayerAdded:Connect(onAdded)
	
end

init()

--// remote events and functions

local events = game.ReplicatedStorage.EventsFolder

local function getInventory(player, category)
	if category == "Insignias" then
		return SavingModule:GetValue(player, category)
	else
		local shopItems = player:FindFirstChild("ShopItems")
		if not shopItems then
			return false
		else
			return shopItems[category]
		end
	end
end

local function getInsignias(player)
	return SavingModule:GetValue(player, "Insignias")
end

local function unequip(player, item)
	local character = player.Character

	local itemModel = character:FindFirstChild(item)
	itemModel:Destroy()
end

local function onHandleEquip(player, info)
	if info.task == "Unequip" then
		unequip(player, info.item)
		SavingModule:SaveValue(player, "Equipped", "None")
	else
		if info.task == "UnequipAndEquip" then
			unequip(player, info.previous)
		end
		
		equip(player, info.item)
		SavingModule:SaveValue(player, "Equipped", info.item)
	end
end

local function onHnadleCostume(player, costume)
	SavingModule:SaveValue(player, "Costume", costume)
end

--// bindings 

events.GetInsigniasEvent.OnServerInvoke = function(player)
	return getInsignias(player)
end

events.OnItemPurchaseEvent.OnServerInvoke = function(player, data)
	return addItemToInventory(player, data)
end

events.GetInventoryEvent.OnServerInvoke = function(player, category)
	return getInventory(player, category)
end

events.FindItemEvent.OnServerInvoke = function(player, item, items)
	local category = findCat(item, items)
	if player.ShopItems[category]:FindFirstChild(item) ~= nil then
		return true
	else
		return false
	end
end

events.GetCostumeEvent.OnServerInvoke = function(player)
	return SavingModule:GetValue(player, "Costume")
end

events.HandleCostumeEvent.OnServerEvent:Connect(onHnadleCostume)
events.HandleEquipEvent.OnServerEvent:Connect(onHandleEquip)









--[[

not using 
		else
			for i, v in pairs(value) do
				local itemValue = Instance.new("StringValue", player["ShopItems"][index])
				itemValue.Name = v
			end

]]