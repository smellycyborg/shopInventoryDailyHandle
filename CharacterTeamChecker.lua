local Postie = require(game.ReplicatedStorage:WaitForChild("Postie"))

local DEFAULT_SPEED = 16
local DOWNED_SPEED = 2
local SLIMED_SPEED = 10

local function checkAttribute(attributeName, player)
	if not player:GetAttribute(attributeName) or player:GetAttribute(attributeName) == false then
		return false
	else
		return true
	end
end

local function onPropertyChanged(player)
	
	if player.Team.Name == "Killer" then
		Postie.SignalClient("HandleProne", player, false)
	else
		Postie.SignalClient("HandleProne", player, true)
	end
	
end

local function changeSpeedAndProne(player, bool, speed)
	Postie.SignalClient("HandleProne", player, bool)
	player.Character.Humanoid.WalkSpeed = speed
	print("MESSAGE/Info:  ", player.Name, " prone has been set to ", bool, ".")
end

local function onPlayerAdded(player)
	
	player:GetPropertyChangedSignal("Team"):Connect(function()
		onPropertyChanged(player)
	end)
	
	player:GetAttributeChangedSignal("DownedSlow"):Connect(function()
		if checkAttribute("DownedSlow", player) then
			changeSpeedAndProne(player, false, DOWNED_SPEED)
		else
			changeSpeedAndProne(player, true, DEFAULT_SPEED)
		end
	end)
	
	player:GetAttributeChangedSignal("SlimeSlowed"):Connect(function() 
		if not checkAttribute("DownedSlow", player)  then
			if checkAttribute("SlimeSlowed", player) then
				changeSpeedAndProne(player, false, SLIMED_SPEED)
			else
				changeSpeedAndProne(player, true, DEFAULT_SPEED)
			end
		end
	end)
	
end

local function init()
	
	game.Players.PlayerAdded:Connect(onPlayerAdded)
	
end

init()


