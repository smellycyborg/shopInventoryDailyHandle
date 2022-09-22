local Postie = game.ReplicatedStorage:WaitForChild("Postie")

local function onClick(button, args)
	-- Todo check if player is able to collect reward
	-- if player is able to get reward then call postie claim daily
	
	Postie.SingalServer("ClaimDaily", args.Name)
end

return function(args)
	local dailyModel = game.ReplicatedStorage:WaitForChild("ShopUiElements").DailyModel:Clone()
	dailyModel.ImageLabel.Image = args.imageId
	dailyModel.TextLabel.Text = args.name
	dailyModel.LayoutOrder = args.day
	dailyModel.Parent = args.parent
	
	local button = dailyModel.TextButton
	
end