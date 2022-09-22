--// Modules

local ShopItems = require(script.ShopItems)
local CreateCategories = require(script.CreateCategories)
local destroyItems = require(script.DestroyItems)

local shopUiElements = game.ReplicatedStorage.ShopUiElements

--// Gui Variables

local PlayerGui = game.Players.LocalPlayer.PlayerGui
local ShopGui = PlayerGui.ShopGui

local isOpen = nil
local isOpening = false

local function createMain(kind)
	local mainFrame = shopUiElements.MainFrame:Clone()
	mainFrame.Visible = false
	mainFrame.Name = kind
	
	local textLabel = mainFrame:FindFirstChild("TextLabel")
	
	if kind == "ShopFrame" then
		textLabel.Text = "SHOP"
	else
		textLabel.Text = "INVENTORY"
	end
	
	mainFrame.Parent = ShopGui
	
	return mainFrame
end

-- init shop gui function
local function initShopGui()
	
	--// Instances
	
	local mainButtonsFrame = shopUiElements.MainButtonsFrame:Clone()
	mainButtonsFrame.Parent = ShopGui
	
	local openShopButton = mainButtonsFrame.ShopButton
	
	local openInventoryButton = mainButtonsFrame.InventoryButton
	
	local mainShopFrame = createMain("ShopFrame")
	local mainInventoryFrame = createMain("InventoryFrame")
	
	local itemsHolder = mainShopFrame.Frame:FindFirstChild("ItemsHolder")
	local categoriesHolder = mainShopFrame.Frame:FindFirstChild("CategoriesHolder")
	
	--// Functions
	
	local function onOpen(button)
		if isOpening then
			return
		end
		
		isOpening = true
		
		local mainFrame = button.Name == "InventoryButton" and mainInventoryFrame or mainShopFrame
		local otherFrame = mainFrame == mainInventoryFrame and mainShopFrame or mainInventoryFrame
		
		if otherFrame.Visible == true then
			destroyItems(otherFrame.Frame.ItemsHolder)
			destroyItems(otherFrame.Frame.CategoriesHolder)
			otherFrame.Visible = false
		end
		
		if mainFrame == mainInventoryFrame then
			openShopButton.Visible = true
		else
			openInventoryButton.Visible = true
		end
		
		mainFrame.Visible = true
		button.Visible = false
		
		CreateCategories({ holder = mainFrame.Frame.CategoriesHolder, itemsHolder = mainFrame.Frame.ItemsHolder})
		
		wait(.01)
		isOpening = false
	end
	
	local function onClose(button)
		destroyItems(button.Parent.Frame.ItemsHolder)
		button.Parent.Visible = false
		
		if button.Parent.Name == "InventoryFrame" then
			destroyItems(mainInventoryFrame.Frame.CategoriesHolder)
			openInventoryButton.Visible = true
		else
			destroyItems(categoriesHolder)
			openShopButton.Visible = true
		end
	end
	
	local function initButton(button, handler, frame)
		button.Activated:Connect(function()
			handler(button)
		end)
	end
	
	--// Bindings
	
	initButton(openShopButton, onOpen)
	initButton(openInventoryButton, onOpen)
	initButton(mainShopFrame.CloseButton, onClose)
	initButton(mainInventoryFrame.CloseButton, onClose)
	
end

initShopGui()