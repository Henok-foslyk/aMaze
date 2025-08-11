local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- RemoteEvents setup
local DifficultyChosen = ReplicatedStorage:FindFirstChild("DifficultyChosen")
if not DifficultyChosen then
	DifficultyChosen = Instance.new("RemoteEvent")
	DifficultyChosen.Name = "DifficultyChosen"
	DifficultyChosen.Parent = ReplicatedStorage
end

local MazeStarted = ReplicatedStorage:FindFirstChild("MazeStarted")
if not MazeStarted then
	MazeStarted = Instance.new("RemoteEvent")
	MazeStarted.Name = "MazeStarted"
	MazeStarted.Parent = ReplicatedStorage
end

local MazeCompleted = ReplicatedStorage:FindFirstChild("MazeCompleted")
if not MazeCompleted then
	MazeCompleted = Instance.new("RemoteEvent")
	MazeCompleted.Name = "MazeCompleted"
	MazeCompleted.Parent = ReplicatedStorage
end

local RequestRespawn = ReplicatedStorage:FindFirstChild("RequestRespawn")
if not RequestRespawn then
	RequestRespawn = Instance.new("RemoteEvent")
	RequestRespawn.Name = "RequestRespawn"
	RequestRespawn.Parent = ReplicatedStorage
end

-- New UI control RemoteEvents
local ShowMenu = ReplicatedStorage:FindFirstChild("ShowMenu")
if not ShowMenu then
	ShowMenu = Instance.new("RemoteEvent")
	ShowMenu.Name = "ShowMenu"
	ShowMenu.Parent = ReplicatedStorage
end

local HideMenu = ReplicatedStorage:FindFirstChild("HideMenu")
if not HideMenu then
	HideMenu = Instance.new("RemoteEvent")
	HideMenu.Name = "HideMenu"
	HideMenu.Parent = ReplicatedStorage
end

local wallSize = Vector3.new(4, 10, 4)
local wallColor = BrickColor.new("Really red")

local mazeFolderName = "MazeFolder"

local function createWall(pos, parent)
	local part = Instance.new("Part")
	part.Size = wallSize
	part.Anchored = true
	part.Position = pos
	part.BrickColor = wallColor
	part.CanCollide = true
	part.Parent = parent
	return part
end

local function generateMaze(width, height)
	-- Remove old maze and spawn locations
	if workspace:FindFirstChild(mazeFolderName) then
		workspace[mazeFolderName]:Destroy()
	end
	for _, obj in pairs(workspace:GetChildren()) do
		if obj:IsA("SpawnLocation") then
			obj:Destroy()
		end
	end

	local mazeFolder = Instance.new("Folder")
	mazeFolder.Name = mazeFolderName
	mazeFolder.Parent = workspace

	-- Maze grid initialization: 1=wall, 0=path
	local maze = {}
	for z = 1, height do
		maze[z] = {}
		for x = 1, width do
			maze[z][x] = 1
		end
	end

	local stack = {}

	local function shuffle(t)
		for i = #t, 2, -1 do
			local j = math.random(i)
			t[i], t[j] = t[j], t[i]
		end
	end

	local function carve(x, z)
		maze[z][x] = 0
		table.insert(stack, {x, z})

		while #stack > 0 do
			local cx, cz = table.unpack(stack[#stack])
			local directions = {
				{2, 0}, {-2, 0}, {0, 2}, {0, -2}
			}
			shuffle(directions)
			local carved = false

			for _, dir in ipairs(directions) do
				local nx, nz = cx + dir[1], cz + dir[2]
				if nx > 1 and nx < width and nz > 1 and nz < height and maze[nz][nx] == 1 then
					maze[cz + dir[2]//2][cx + dir[1]//2] = 0 -- remove wall between
					maze[nz][nx] = 0
					table.insert(stack, {nx, nz})
					carved = true
					break
				end
			end

			if not carved then
				table.remove(stack)
			end
		end
	end

	carve(2, 2)

	-- Build maze parts
	for z = 1, height do
		for x = 1, width do
			local pos = Vector3.new(x * wallSize.X, wallSize.Y / 2, z * wallSize.Z)
			if maze[z][x] == 1 then
				createWall(pos, mazeFolder)
			else
				local floor = Instance.new("Part")
				floor.Size = Vector3.new(wallSize.X, 1, wallSize.Z)
				floor.Position = Vector3.new(pos.X, 0.5, pos.Z)
				floor.Anchored = true
				floor.BrickColor = BrickColor.new("Bright green")  -- or "Medium green"
				floor.Material = Enum.Material.Grass
				floor.Parent = mazeFolder
			end
		end
	end

	-- Spawn Location inside maze at (2,2)
	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "MazeSpawn"
	spawn.Size = Vector3.new(wallSize.X * 0.8, 1, wallSize.Z * 0.8)
	spawn.Position = Vector3.new(2 * wallSize.X, wallSize.Y / 2, 2 * wallSize.Z)
	spawn.Anchored = true
	spawn.Neutral = true
	spawn.CanCollide = true
	spawn.Parent = workspace

	-- Goal at opposite corner
	local goal = Instance.new("Part")
	goal.Name = "Goal"
	goal.Size = Vector3.new(wallSize.X * 0.8, wallSize.Y, wallSize.Z * 0.8)
	goal.Position = Vector3.new((width - 1) * wallSize.X, wallSize.Y / 2, (height - 1) * wallSize.Z)
	goal.Anchored = true
	goal.BrickColor = BrickColor.new("Bright yellow")
	goal.Material = Enum.Material.Neon
	goal.Parent = mazeFolder
	goal.CanCollide = false
	
	local sandFloor = Instance.new("Part")
	sandFloor.Name = "SandFloor"
	sandFloor.Anchored = true
	sandFloor.Size = Vector3.new(width * wallSize.X + 2000, 1, height * wallSize.Z + 2000) -- a bit bigger than maze
	sandFloor.Position = Vector3.new((width * wallSize.X)/2, 0, (height * wallSize.Z)/2)
	sandFloor.BrickColor = BrickColor.new("Sand yellow")
	sandFloor.Material = Enum.Material.Sand
	sandFloor.Parent = workspace


	local debounce = {}
	goal.Touched:Connect(function(hit)
		local player = Players:GetPlayerFromCharacter(hit.Parent)
		if player and not debounce[player] then
			debounce[player] = true
			MazeCompleted:FireClient(player)
			-- Show menu on completion and hide restart
			ShowMenu:FireClient(player)
			wait(2)
			debounce[player] = nil
		end
	end)
end

-- Large sand base floor under entire maze


DifficultyChosen.OnServerEvent:Connect(function(player, difficulty)
	if difficulty == "Easy" then
		generateMaze(11, 11)
	elseif difficulty == "Medium" then
		generateMaze(21, 21)
	elseif difficulty == "Hard" then
		generateMaze(31, 31)
	else
		generateMaze(21, 21)
	end

	-- Hide menu, show restart during play
	HideMenu:FireClient(player)
	MazeStarted:FireClient(player)

	player:LoadCharacter()
end)

RequestRespawn.OnServerEvent:Connect(function(player)
	player:LoadCharacter()
	-- Show menu, hide restart on respawn (restart pressed)
	ShowMenu:FireClient(player)
end)

-- Default maze on server start
generateMaze(21, 21)
