local InsigniaInfo = require(game.ReplicatedStorage:WaitForChild("Game").Mechanics.Collectibles.InsigniaInfo)

local function getInsigniaInfo(item)
	for index, value in pairs(InsigniaInfo) do
		if index == item then
			return value
		end
	end
end

return function(args)
	local itemHolder = game.ReplicatedStorage.ShopUiElements.InsigniaModel:Clone()
	itemHolder.Name = args.item
	itemHolder.Parent = args.holder
	
	local itemInfo = getInsigniaInfo(args.item)
	
	local imageLabel = itemHolder["ImageLabel"]
	imageLabel.Image = "rbxassetid://" .. itemInfo.Decal
	
	local textLabel = itemHolder["TextLabel"]
	textLabel.Text = itemInfo.DisplayName
end
