return function(button, handler, args)
	button.MouseButton1Up:Connect(function()
		handler(button, args)
	end)
end
