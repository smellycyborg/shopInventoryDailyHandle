local ShopItems = require(script.Parent.ShopItems)
local InitButton = require(script.Parent.InitButton)
local addViewport = require(script.Parent.AddViewport)

local RBX = "rbxassetid://"

local onItemPurchaseEvent = game.ReplicatedStorage:WaitForChild("EventsFolder").OnItemPurchaseEvent

local function getItemData(itemName)
	for category, items in pairs(ShopItems) do
		if not items[itemName] then
			continue
		else
			return items[itemName]
		end
	end
end

local function onBuy(itemName, button)
	local itemData = getItemData(itemName)
	
	local result = onItemPurchaseEvent:InvokeServer({ cost = itemData.Cost, name = itemName, items = ShopItems })
	
	if result then
		local frame = button.Parent
		
		local ownedLabel = game.ReplicatedStorage.ShopUiElements.OwnedLabel:Clone()
		ownedLabel.Name = itemName
		ownedLabel.Text = "?"
		ownedLabel.Parent = frame
		
		frame.CostTextLabel:Destroy()
		frame.CoinIcon:Destroy()
		button:Destroy()
	end
end

local function findCat(item)
	for index, value in pairs(ShopItems) do
		for i, v in pairs(value) do
			if i == item then
				return index
			end
		end
	end
end

-- will change this to remote function
local function findItem(item)
	local player = game.Players.LocalPlayer
	
	local result = game.ReplicatedStorage.EventsFolder.FindItemEvent:InvokeServer(item, ShopItems)
	
	return result
end

local function addImage(item, holder, imageId)
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Image = "rbxassetid://" .. imageId
	imageLabel.ScaleType = Enum.ScaleType.Fit
	imageLabel.Size = UDim2.fromScale(1, .8)
	imageLabel.BackgroundTransparency = 1
	imageLabel.Parent = holder
end

return function(args)
	local item = args.item
	local holder = args.frame
	local data = args.data
	
	if item == "Phe" then
		return
	end
	
	local itemHolder = game.ReplicatedStorage.ShopUiElements.ItemHolder:Clone() -- this is going to be the back drop
	itemHolder.Name = item
	itemHolder.LayoutOrder = data.LayoutOrder
	itemHolder.Parent = holder
	
	local category = findCat(item)
	if category == "Backpacks" then
		addViewport(item, itemHolder)
	else
		addImage(item, itemHolder, data.AssetId)
	end
	
	local imageLabel = Instance.new("Frame") -- item image
	imageLabel.Size = UDim2.fromScale(1, 1)
	imageLabel.BackgroundTransparency = 1
	imageLabel.BorderSizePixel = 0
	imageLabel.Parent = itemHolder
	
	local hasItem = findItem(item)
	
	if not hasItem then
	
		local buyButton = game.ReplicatedStorage.ShopUiElements.BuyButton:Clone()
		buyButton.Name = item
		buyButton.Text = item:gsub("(%l)(%u)", "%1 %2")
		buyButton.Parent = itemHolder
		
		local coinIcon = Instance.new("ImageLabel")
		coinIcon.Name = "CoinIcon"
		coinIcon.Image = "rbxassetid://10081554053"
		coinIcon.BackgroundTransparency = 1
		coinIcon.BorderSizePixel = 0
		coinIcon.Size = UDim2.fromScale(.3, .125)
		coinIcon.ScaleType = Enum.ScaleType.Fit
		coinIcon.Parent = itemHolder
		
		local costTextLabel = Instance.new("TextLabel")
		costTextLabel.Name = "CostTextLabel"
		costTextLabel.Text = data.Cost
		costTextLabel.TextScaled = true
		costTextLabel.TextColor3 = Color3.new(1, 1, 1)
		costTextLabel.BackgroundTransparency = 1
		costTextLabel.BorderSizePixel = 0
		costTextLabel.Size = UDim2.fromScale(.5, .15)
		costTextLabel.Position = UDim2.fromScale(.25, 0)
		costTextLabel.Parent = itemHolder
		
		InitButton(buyButton, onBuy)
	else
		local ownedLabel = game.ReplicatedStorage.ShopUiElements.OwnedLabel:Clone()
		ownedLabel.Name = item
		ownedLabel.Text = "?"
		ownedLabel.Parent = itemHolder
	end
end