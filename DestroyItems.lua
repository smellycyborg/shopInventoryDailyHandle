return function(frame)
	for _, child in pairs(frame:GetDescendants()) do
		local childIsUiGrid = child:IsA("UIGridLayout")
		if childIsUiGrid then
			continue
		else
			child:Destroy()
		end
	end
end