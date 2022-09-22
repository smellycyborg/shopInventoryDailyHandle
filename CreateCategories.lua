local InsigniaInfo = require(game.ReplicatedStorage:WaitForChild("Game").Mechanics.Collectibles.InsigniaInfo)
local ShopItems = require(script.Parent.ShopItems)
local InitButton = require(script.Parent.InitButton)
local destroyItems = require(script.Parent.DestroyItems)
local CreateBuyModel = require(script.Parent.CreateBuyModel)
local ShopItems = require(script.Parent.ShopItems)

-- modules that handle creating items per inventory category
local InventoryModules = {
	Backpacks = require(script.Parent.CreateBackpackModel),
	Costumes = require(script.Parent.CreateCostumeModel),
	Insignias = require(script.Parent.CreateInsigniaModel)
}

local isUp = "Backpacks"
local isClicked = false

local function getInsigniaInfo(item)
	for index, value in pairs(InsigniaInfo) do
		if index.Name == item then
			return value
		end
	end
end

-- finds item in shopitems data by name
local function findItem(name)
	for index, value in pairs(ShopItems) do
		for i, v in pairs(value) do
			if i == name then
				return v.AssetId
			end
		end
	end
end

-- creates items for shop
local function CreateShopItems(args)
	local length = 0

	for name, data in pairs(args.object) do
		local isAssetId = name == "assetId"
		if isAssetId then
			continue
		else
			args.handler({ 
				item = name, 
				frame = args.frame, 
				data = data 
			})
			length+=1
		end
	end
	return length
end

-- creates items for inventory
local function CreateInventoryItems(args, isInsignias)
	local length = 0

	for index, value in pairs(args.object) do
		if not isInsignias then
			local assetId = findItem(value.Name)
			
			if args.frame:FindFirstChild(value.Name) then
				continue
			end

			args.handler({ item = value.Name, frame = args.frame, imageId = assetId })
			length+=1
		else
			if args.frame:FindFirstChild(index) then
				continue
			end
			
			args.handler({item = index, holder = args.frame})
			length+=1
		end
	end

	return length
end

-- hndles scrolling frame properties
local function setFrameProps(frame, bool, int)
	frame.ScrollingEnabled = bool
	frame.ScrollBarImageTransparency = int
end

-- create items per category name
local function CreateCategoryItems(frame, btnName)
	local length
	local categoryName = not btnName and "Backpacks" or tostring(btnName)

	if categoryName == "Collectibles" then
		categoryName = "Insignias"
	end

	frame.CanvasPosition = Vector2.new(0, 0)

	local isShop = frame.Parent.Parent.Name == "ShopFrame"
	if isShop then
		if frame.Parent.Parent:FindFirstChild("ComingSoon") then
			frame.Parent.Parent["ComingSoon"]:Destroy()
		end

		length = CreateShopItems({
			frame = frame,
			object = ShopItems[categoryName], 
			handler = CreateBuyModel 
		})
	else
		local isInventory = frame.Parent.Parent.Name == "InventoryFrame"
		if isInventory then
			if not InventoryModules[categoryName] then
				local comingSoonLabel = game.ReplicatedStorage.ShopUiElements.ComingSoon:Clone()
				comingSoonLabel.Parent = frame.Parent.Parent

				warn("MESSAGE/Info:  The function for ", tostring(categoryName), " does not exist yet..")
			else
				if frame.Parent.Parent:FindFirstChild("ComingSoon") then
					frame.Parent.Parent["ComingSoon"]:Destroy()
				end

				local inventory = game.ReplicatedStorage.EventsFolder.GetInventoryEvent:InvokeServer(categoryName)
				local isInsignias = true
				local inventoryChildren
				if categoryName ~= "Insignias" then
					inventoryChildren = inventory:GetChildren()
					isInsignias = false
				end

				length = CreateInventoryItems({
					frame = frame,
					object = categoryName == "Insignias" and inventory or inventoryChildren,
					handler = InventoryModules[categoryName]
				}, isInsignias)
			end
		end
	end

	if length <= 4 then
		setFrameProps(frame, false, 1)
	else
		setFrameProps(frame, true, 0)
	end

	return true
end

local function categoryButtonHandler(btnName, button)
	if isClicked then
		return
	else
		if isUp == btnName then
			return
		end

		if btnName ~= isUp then
			local frame = button:FindFirstAncestor("ShopFrame") or button:FindFirstAncestor("InventoryFrame")
			isClicked = true
			isUp = btnName
			destroyItems(frame.Frame.ItemsHolder)
			local result = CreateCategoryItems(frame.Frame.ItemsHolder, btnName)
			
			if result then
				isClicked = false
			end
		end
	end
end

local function GetItemCategories(ignore)
	local categories = {}

	for category, _ in pairs(ShopItems) do
		if category ~= ignore then
			table.insert(categories, category)
		end
	end

	return categories
end

local function CreateCategoryButton(categoryName, holder)
	local CategoryHolder = holder:FindFirstChild("CategoryHolder")

	local categoryButton = game.ReplicatedStorage.ShopUiElements.CategoryButton:Clone()
	
	if categoryName == "Collectibles" then
		categoryButton.Name = "Insignias"
	else
		categoryButton.Name = categoryName
	end
	
	categoryButton.Text = categoryName == "Costumes" and "Tantrums" or categoryName
	categoryButton.Parent = holder

	InitButton(categoryButton, categoryButtonHandler)
end

return function(args)
	if isClicked then
		return
	end
	
	isClicked = true
	
	isUp = "Backpacks"
	
	local categories = GetItemCategories()

	for index, category in pairs(categories) do
		local assetId = tostring("rbxassetid://".. ShopItems[category].assetId)  -- if there needs to be a image forcategory button 
		
		CreateCategoryButton(category, args.holder)
	end
	
	if args.holder.Parent.Parent.Name == "InventoryFrame" then
		CreateCategoryButton("Collectibles", args.holder)
	end
	
	local result = CreateCategoryItems(args.itemsHolder)
	
	if result then
		isClicked = false
	end
end

