local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DifficultyChosen = ReplicatedStorage:WaitForChild("DifficultyChosen")
local MazeCompleted = ReplicatedStorage:WaitForChild("MazeCompleted")

local menuFrame = script.Parent:WaitForChild("MenuFrame")
menuFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
menuFrame.BackgroundTransparency = 0 -- ensure visible background

-- Add padding inside menuFrame so buttons don't touch edges
local padding = menuFrame:FindFirstChildOfClass("UIPadding")
if not padding then
	padding = Instance.new("UIPadding")
	padding.PaddingTop = UDim.new(0, 12)
	padding.PaddingBottom = UDim.new(0, 12)
	padding.PaddingLeft = UDim.new(0, 12)
	padding.PaddingRight = UDim.new(0, 12)
	padding.Parent = menuFrame
end

local layout = menuFrame:FindFirstChildOfClass("UIListLayout")
if not layout then
	local newLayout = Instance.new("UIListLayout")
	newLayout.SortOrder = Enum.SortOrder.LayoutOrder
	newLayout.Padding = UDim.new(0, 12) -- space between buttons
	newLayout.Parent = menuFrame
end

menuFrame.Size = UDim2.new(0, 204, 0, 168)

local easyButton = menuFrame:WaitForChild("EasyButton")
local mediumButton = menuFrame:WaitForChild("MediumButton")
local hardButton = menuFrame:WaitForChild("HardButton")

local function styleButton(button, text, bgColor)
	button.Text = text
	button.BackgroundColor3 = bgColor
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.Font = Enum.Font.SourceSansBold
	button.TextScaled = true
	button.BackgroundTransparency = 0
	button.Size = UDim2.new(0, 180, 0, 40)
	button.LayoutOrder = 0
end

styleButton(easyButton, "Easy", Color3.fromRGB(50, 150, 50))
styleButton(mediumButton, "Medium", Color3.fromRGB(255, 165, 0))
styleButton(hardButton, "Hard", Color3.fromRGB(200, 50, 50))

local function showMenu()
	menuFrame.Visible = true
end

local function hideMenu()
	menuFrame.Visible = false
end

easyButton.MouseButton1Click:Connect(function()
	hideMenu()
	DifficultyChosen:FireServer("Easy")
end)

mediumButton.MouseButton1Click:Connect(function()
	hideMenu()
	DifficultyChosen:FireServer("Medium")
end)

hardButton.MouseButton1Click:Connect(function()
	hideMenu()
	DifficultyChosen:FireServer("Hard")
end)

MazeCompleted.OnClientEvent:Connect(function()
	wait(3)
	showMenu()
end)

showMenu()
