local InitButton = require(script.Parent.InitButton)
local addViewport = require(script.Parent.AddViewport)

local events = game.ReplicatedStorage:WaitForChild("EventsFolder")
local HandleEquipEvent = events.HandleEquipEvent

local isEquipped = "None"
local previousButton

local function findPrevButton(button)
	local frame = game.Players.LocalPlayer.PlayerGui.ShopGui.InventoryFrame
	for _, child in pairs(frame:GetDescendants()) do
		if child:IsA("TextButton") and child.Name == button.Name then
			return child
		end
	end
end

local function onButtonInit(itemName, button)
	if isEquipped ~= "None" and button.Name ~= isEquipped then
		isEquipped = button.Name
		previousButton.Text = previousButton.Name:gsub("(%l)(%u)", "%1 %2")
		previousButton.BackgroundColor3 = Color3.new(0.207843, 0.764706, 1)
		
		button.Text = "Unequip"
		button.BackgroundColor3 = Color3.new(1, 0.435294, 0.435294)
		
		HandleEquipEvent:FireServer({
			previous = previousButton.Name,
			item = button.Name,
			task = "UnequipAndEquip"
		})
	
	elseif isEquipped == button.Name then
		isEquipped = "None"
		button.Text = button.Name:gsub("(%l)(%u)", "%1 %2")
		button.BackgroundColor3 = Color3.new(0.207843, 0.764706, 1)
		
		-- takes off item from player's character
		HandleEquipEvent:FireServer({item = button.Name, task = "Unequip"})
		
	elseif isEquipped == "None" then
		isEquipped = button.Name
		button.Text = "Unequip"
		button.BackgroundColor3 = Color3.new(1, 0.435294, 0.435294)
		
		HandleEquipEvent:FireServer({item = button.Name, task = "Equip"})
	end
	previousButton = findPrevButton(button)
end

game.ReplicatedStorage.EventsFolder.SetIsEquippedEvent.OnClientEvent:Connect(function(item)
	isEquipped = item
end)

return function(args)
	local itemName = args.item
	local holder = args.frame
	
	local itemHolder = game.ReplicatedStorage.ShopUiElements.ItemHolder:Clone() -- this is going to be the back drop
	itemHolder.Name = itemName
	itemHolder.Parent = holder
	
	addViewport(itemName, itemHolder)
	
	local equipButton = game.ReplicatedStorage.ShopUiElements.BuyButton:Clone()
	equipButton.Name = itemName
	
	if isEquipped == itemName or game.Players.LocalPlayer.Character:FindFirstChild(itemName) then
		isEquipped = itemName
		equipButton.Text = "Unequip"
		equipButton.BackgroundColor3 = Color3.new(1, 0.435294, 0.435294)
		previousButton = equipButton
	else
		equipButton.Text = itemName:gsub("(%l)(%u)", "%1 %2")
	end
	
	equipButton.Parent = itemHolder
	
	InitButton(equipButton, onButtonInit)
end