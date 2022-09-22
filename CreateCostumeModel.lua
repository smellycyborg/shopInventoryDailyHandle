local InitButton = require(script.Parent.InitButton)

local events = game.ReplicatedStorage:WaitForChild("EventsFolder")
local SetCostumeEquippedEvent = events.SetCostumeEquippedEvent
local HandleCostumeEvent = events.HandleCostumeEvent

--local DEFAULT_COSTUME = "Phe"

local RBX = "rbxassetid://"

local Costume

local previousBtn

local function onEvent(costume)
	Costume = costume
end

SetCostumeEquippedEvent.OnClientEvent:Connect(onEvent)

local function btnHandler(itemName, btn)
	if Costume == btn.Name then
		return
	elseif Costume ~= btn.Name then
		Costume = btn.Name
		
		HandleCostumeEvent:FireServer(Costume)
		
		previousBtn.Parent.BorderSizePixel = 0
		
		btn.Parent.BorderSizePixel = 4
		
		previousBtn = btn
	end
end

local function getCostume()
	local result = game.ReplicatedStorage.EventsFolder.GetCostumeEvent:InvokeServer()
	
	return result
end

return function(args)
	local itemName = args.item
	local holder = args.frame
	local imageId = args.imageId
	
	Costume = getCostume()

	local itemModel = game.ReplicatedStorage.ShopUiElements.CostumeModel:Clone() -- this is going to be the back drop
	itemModel.Parent = holder
	
	local textLabel = itemModel:FindFirstChild("TextLabel")
	textLabel.Text = itemName
	
	-- Todo will use profle thumbnails for each killer

	local equipButton = itemModel["ImageButton"]
	equipButton.Image = RBX .. imageId
	equipButton.Name = itemName
	
	if itemName == Costume then
		equipButton.Parent.BorderSizePixel = 4
		previousBtn = equipButton
	end

	InitButton(equipButton, btnHandler)
end