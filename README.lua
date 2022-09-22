--// shop gui handler for tantrums
--  author:  chavez
-- year: 2022

--[[

	step 1:  open up shop gui
	
	step 2:  on shop gui open backpacks will show as default and categories will appear
	as buttons
	
	step 3:  on category button click items will appear for that category
	
	step 4:  on buy click item will be purchased and button will be destroyed and replaced
	with a text label

	// Documentation
	
	ShopGuiHandler - handles the shops ui and all the modules
	
	CreateCategories - creates and displays category buttons
	
	CreateCategoryItems - creates and handles category items depending on category button clicked
	
	CreateBuyModel - creates the buy model for each item.  a buy model consists of frame, imagelabel,
	text label for cost, and buy button
	
	DesroyItems - destroys all buy models in frame 
	
	
]]