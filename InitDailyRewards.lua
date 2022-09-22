local SavingModule = require(game.ServerScriptService:WaitForChild("Modules").SavingModule)
local Postie = require(game.ReplicatedStorage:WaitForChild("Postie"))
local displayDailyRewards = require(script.DisplayDailyRewards)
local initButton = require(script.DisplayDailyRewards.InitButton)

-- Todo logic for day 5 giving player free backpack
-- Todo set buttons that are not the day to text labels either to claimed or days left to be ble to claim

--  coin rewards
local rewardsForStreak = {
	[1] = 100,
	[2] = 250,
	[3] = 500,
	[4] = 1000,
	[5] = 1750,
}

local BACKPACK = "GoldPack"
local TWO_DAYS = 2

local function findButton(object, streak)
	local descendants = object.Frame:GetChildren()
	
	for _, frame in pairs(descendants) do
		local isDailyModel = frame.Name == "DailyModel"
		if isDailyModel then
			local isStreak = frame.LayoutOrder == streak
			if isStreak then
				return frame.TextButton
			end
		end
	end
end

local function onPlayerAdded(player)
	
	-- ui variables
	local playerGui = player.PlayerGui
	
	local mainFrame = game.ReplicatedStorage:WaitForChild("ShopUiElements").DailyRewards:Clone()
	mainFrame.Parent = playerGui:WaitForChild("ShopGui")

	displayDailyRewards(mainFrame.Frame)
	
	-- daily reward variables 
	local date = os.date("*t")
	local dailyData
	local lastOnline
	local timeDifference

	local response, err = pcall(function()
		dailyData = SavingModule:GetValue(player, "DailyRewards")
	end)

	if response then 
		print(dailyData)
	end
	
	--  code below is for testing purposes
	--dailyData = SavingModule:ChangeData(player, "DailyRewards", { lastPlayed = date.day, lastClaimed = false, day = 1 })
	
	-- time variables
	if dailyData.lastPlayed == nil or dailyData.lastPlayed >= 32 then
		dailyData = SavingModule:ChangeData(player, "DailyRewards", { lastPlayed = date.day })
		
		print("DailyRewards -> MESSAGE/Info:  Setting DailyRewards lastPlayed because lastPlayed is nil.")
	else
		lastOnline = dailyData.lastPlayed
		timeDifference = date.day - lastOnline
		
		warn("DailyRewards -> MESSAGE/Info:  Setting last online and time difference is ", timeDifference)
	end
	
	if dailyData.day == nil then
		dailyData = SavingModule:ChangeData(player, "DailyRewards", { day = 1 })
	end
	
	-- if player has not played in the last 2 days
	if not timeDifference or timeDifference >= TWO_DAYS then
		
		warn("DailyRewards -> MESSAGE/Info:  no time difference or time difference is greater then 24 hours.")
		
		dailyData = SavingModule:ChangeData(player, "DailyRewards", { lastPlayed = date.day, day = 1, lastClaimed = false })
		
		local button = findButton(mainFrame, dailyData.day)
		Postie.SignalClient("SetDailyRewardsUi", player, { day = dailyData.day, btn = button })
		
		print("DailyRewards -> MESSAGE/Info:  this is daily data ", dailyData, ".")
		
		local streak = dailyData.day
		local reward = rewardsForStreak[streak]
		
		mainFrame.Visible = true
		
		local function postReward()
			-- make daily rewards ui invisible
			mainFrame.Visible = false
			
			-- add coins to player coins data
			SavingModule:IncrementValue(player, "Coins", reward)
			streak = streak + 1
			
			-- update last claimed so player cannot continue to claim rewards once claimed
			dailyData = SavingModule:ChangeData(player, "DailyRewards", { lastClaimed = true, day = streak, lastPlayed = date.day })
		end
		
		initButton(button, postReward, { name = button.Name })
		

	elseif timeDifference == 1 or timeDifference == 0 and dailyData.lastClaimed == false then
		
		--[[ --/ may not use below
		
			--- if player joins back and they'ved already claimed their reward do nothing
			if dailyData.lastClaimed == true and timeDifference == 0 then
				return
			end
		
		]]
		
		warn("DailyRewards -> MESSAGE/Info:  just time difference.")
		
		local button = findButton(mainFrame, dailyData.day)
		Postie.SignalClient("SetDailyRewardsUi", player, { day = dailyData.day, btn = button })

		local streak = dailyData.day
			
		local reward = rewardsForStreak[streak]

		mainFrame.Visible = true

		local function postReward()
				
			-- increases coins
			SavingModule:IncrementValue(player, "Coins", reward)
			
			-- make daily reward ui invisible
			mainFrame.Visible = false
			
			-- update streak after update player data
			streak = streak + 1
			if streak == 5 then
				
				-- give player backpack if streak is equal to day 5
				SavingModule:AddItem(player, "Backpacks", BACKPACK)
				
				streak = 1

				print("DailyRewards -> MESSAGE/Info:  streak has been set to 1.")
			end
			
			dailyData = SavingModule:ChangeData(player, "DailyRewards", { day = streak, lastPlayed = date.day, lastClaimed = true })
			
			print("DailyRewards -> MESSAGE/Info:  this is daily data ", dailyData, ".")
		end

		initButton(button, postReward, { name = button })
	end
end

game.Players.PlayerAdded:Connect(onPlayerAdded)