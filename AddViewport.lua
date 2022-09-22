local tweenService = game:GetService("TweenService")

return function(item, holder)
	local isHovering = false
	local oldCFrame
	
	local viewportFrame = Instance.new("ViewportFrame")
	viewportFrame.Size = UDim2.fromScale(1, 1)
	viewportFrame.Position = UDim2.fromScale(0, -.2)
	viewportFrame.BorderSizePixel = 0
	viewportFrame.BackgroundTransparency = 1
	viewportFrame.Parent = holder

	local itemModel = game.ReplicatedStorage.Items:FindFirstChild(item)
	if not itemModel then
		return false
	end

	local itemClone = itemModel:Clone(item)

	itemClone.Position = Vector3.new(0, 1, 7)
	itemClone.Orientation = Vector3.new(0, -150, 0)
	itemClone.Parent = viewportFrame

	local viewportCamera = Instance.new("Camera")
	viewportFrame.CurrentCamera = viewportCamera
	viewportCamera.Parent = viewportFrame

	viewportCamera.CFrame = CFrame.new(Vector3.new(0, 2, 12), itemClone.Position)
	
	viewportFrame.MouseEnter:Connect(function()
		
		isHovering = true

		task.spawn(function()
			while isHovering do
				itemClone.CFrame *= CFrame.Angles(0, .1, 0)
				task.wait(.08)
			end
		end)
	end)
	
	viewportFrame.MouseLeave:Connect(function()
		isHovering = false
		itemClone.Orientation = Vector3.new(0, -150, 0)
	end)
	
	-- tweenService:Create(viewportCamera, TweenInfo.new(6), {CFrame = itemClone.Orientation:ToWorldSpace(CFrame.new(0, 2, 6) * CFrame.Angles(0, math.rad(180), 0)), Focus = itemClone.CFrame}):Play()
end
