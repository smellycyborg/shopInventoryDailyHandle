return function(player, item)
	local character = player.Character

	local accessory = Instance.new("Accessory")
	accessory.AttachmentForward = Vector3.new(0, 0, 1)
	accessory.AttachmentPos = Vector3.new(0, 80, 1)
	accessory.AttachmentRight = Vector3.new(-1, 0, 0)
	accessory.AttachmentUp = Vector3.new(0, 1, 0)
	accessory:SetAttribute("IsItem", "Backpack")
	accessory.Name = item
	
	local itemModel = game.ReplicatedStorage.Items:FindFirstChild(item):Clone()
	itemModel.Name = "Handle"
	itemModel.Orientation = Vector3.new(0, 0, 0)
	itemModel.Size = Vector3.new(1.986, 2.43, 0.911)
	itemModel.Parent = accessory

	local attachment = Instance.new("Attachment")
	attachment.Name = "BodyBackAttachment"
	attachment.Orientation = Vector3.new(0, 180, 5)
	attachment.Position = Vector3.new(0, 0, .6)
	attachment.Parent = itemModel

	accessory.Parent = character
end
