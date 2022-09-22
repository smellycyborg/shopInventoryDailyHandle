local Countdown = require(game.ReplicatedStorage:WaitForChild("Modules").Countdown)
local Postie = require(game.ReplicatedStorage:WaitForChild("Postie"))
local SavingModule = require(game.ServerScriptService:WaitForChild("Modules").SavingModule)

local COUNTDOWN_TIME = 300
local REWARD_COINS_AMOUNT = 5

-- turns seconds into time clock
local function secondsToClock(seconds)
	--- timer starts from epoch:0 (1 January 1970) 
	--- this allows us to litteraly just add the seconds to create a date/time x after 
	----- this means that we can just use os.date to show human readable
	return os.date("!%M:%S", seconds)
end


-- on every second of countdown
local function onTick(player, countdown)
	local timeLeft = countdown:getTimeLeft() and math.ceil(countdown:getTimeLeft()) or ""
	local convertedTime = secondsToClock(timeLeft)
	
	Postie.SignalClient("TimeRewards", player, convertedTime)
end

-- created countdown continuously
local function createCountdown(player)
	local countdown = Countdown.new()

	countdown:start(COUNTDOWN_TIME)

	countdown.tick:Connect(function()
		onTick(player, countdown)
	end)
	
	local function onFinished()
		SavingModule:IncrementValue(player, "Coins", REWARD_COINS_AMOUNT) -- add coins to player data
		createCountdown(player) -- call the function again to start countdown over
	end
	
	countdown.finished:Connect(onFinished)
end

local function onPlayerAdded(player)

	createCountdown(player)
		
end

game.Players.PlayerAdded:Connect(onPlayerAdded)