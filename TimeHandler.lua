local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local MazeStarted = ReplicatedStorage:WaitForChild("MazeStarted")
local MazeCompleted = ReplicatedStorage:WaitForChild("MazeCompleted")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local timerUI = script.Parent  -- Assuming this script is inside TimerUI ScreenGui

-- Create timer label if missing
local timerLabel = timerUI:FindFirstChild("TimerLabel")
if not timerLabel then
	timerLabel = Instance.new("TextLabel")
	timerLabel.Name = "TimerLabel"
	timerLabel.Size = UDim2.new(0, 180, 0, 40)
	timerLabel.Position = UDim2.new(0, 10, 1, -50) -- bottom-left corner, 50px from bottom
	timerLabel.BackgroundTransparency = 0.5
	timerLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	timerLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	timerLabel.TextScaled = true
	timerLabel.Font = Enum.Font.SourceSansBold
	timerLabel.Text = "Time: 0s"
	timerLabel.Parent = timerUI
end

-- Create congrats message label if missing
local msgLabel = timerUI:FindFirstChild("MsgLabel")
if not msgLabel then
	msgLabel = Instance.new("TextLabel")
	msgLabel.Name = "MsgLabel"
	msgLabel.Size = UDim2.new(0, 300, 0, 60)
	msgLabel.Position = UDim2.new(0.5, -150, 0.1, 0) -- centered horizontally, 10% from top
	msgLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	msgLabel.BackgroundTransparency = 0.6
	msgLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	msgLabel.TextScaled = true
	msgLabel.Font = Enum.Font.SourceSansBold
	msgLabel.Visible = false
	msgLabel.Parent = timerUI
end

local running = false
local startTime = 0

local function startTimer()
	startTime = tick()
	running = true
	msgLabel.Visible = false
	timerLabel.Text = "Time: 0s"
end

MazeStarted.OnClientEvent:Connect(function()
	startTimer()
end)

MazeCompleted.OnClientEvent:Connect(function()
	if running then
		running = false
		local elapsed = math.floor(tick() - startTime)
		timerLabel.Text = "Time: " .. elapsed .. "s"
		msgLabel.Text = "🎉 You finished in " .. elapsed .. " seconds! 🎉"
		msgLabel.Visible = true
	end
end)

-- Start timer on initial load (for default maze)
startTimer()

-- Update timer every second while running
task.spawn(function()
	while true do
		if running then
			local elapsed = math.floor(tick() - startTime)
			timerLabel.Text = "Time: " .. elapsed .. "s"
		end
		task.wait(1)
	end
end)
