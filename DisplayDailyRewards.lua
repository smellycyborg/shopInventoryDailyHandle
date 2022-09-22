local createDailyMoodel = require(script.CreateDailyModel)
local dailyRewardsInfo = require(script.DailyRewardsInfo)

return function(parent)
	for index, child in pairs(dailyRewardsInfo) do
		local args = {
			parent = parent, 
			name = child.name,
			reward = child.reward,
			imageId = child.imageId,
			day = index
		}

		createDailyMoodel(args)
	end
end