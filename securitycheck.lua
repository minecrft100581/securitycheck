-- ULTIMATE CLIENT SECURITY DASHBOARD
-- Single LocalScript Version

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer

--========================--
-- SECURITY CORE
--========================--

local SeverityWeight = {
	Critical = 40,
	Warning = 15,
	Info = 5
}

local SecurityScore = 100
local RemoteList = {}

local function getRank(score)
	if score >= 90 then return "S", Color3.fromRGB(0,200,83)
	elseif score >= 70 then return "A", Color3.fromRGB(100,220,0)
	elseif score >= 50 then return "B", Color3.fromRGB(255,193,7)
	elseif score >= 30 then return "C", Color3.fromRGB(255,120,0)
	else return "D", Color3.fromRGB(255,59,59)
	end
end

--========================--
-- UI SETUP
--========================--

local gui = Instance.new("ScreenGui")
gui.Name = "SecurityDashboard"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local main = Instance.new("Frame", gui)
main.Size = UDim2.fromOffset(800,520)
main.Position = UDim2.fromScale(0.5,0.5)
main.AnchorPoint = Vector2.new(0.5,0.5)
main.BackgroundColor3 = Color3.fromRGB(17,17,17)
main.Active = true
main.Draggable = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0,20)

-- Entrance Animation
main.Size = UDim2.fromOffset(0,0)
TweenService:Create(main,
	TweenInfo.new(0.4,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),
	{Size = UDim2.fromOffset(800,520)}
):Play()

--========================--
-- TOP BAR
--========================--

local topBar = Instance.new("Frame", main)
topBar.Size = UDim2.new(1,0,0,40)
topBar.BackgroundTransparency = 1

local title = Instance.new("TextLabel", topBar)
title.Size = UDim2.new(1,-100,1,0)
title.Position = UDim2.new(0,15,0,0)
title.BackgroundTransparency = 1
title.Text = "CLIENT SECURITY INTELLIGENCE"
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextColor3 = Color3.fromRGB(212,175,55)
title.TextXAlignment = Enum.TextXAlignment.Left

-- Minimize
local minimized = false
local minimizeBtn = Instance.new("TextButton", topBar)
minimizeBtn.Size = UDim2.fromOffset(30,30)
minimizeBtn.Position = UDim2.new(1,-70,0,5)
minimizeBtn.Text = "—"
minimizeBtn.BackgroundColor3 = Color3.fromRGB(212,175,55)
minimizeBtn.TextColor3 = Color3.new(0,0,0)
Instance.new("UICorner", minimizeBtn).CornerRadius = UDim.new(1,0)

-- Close
local closeBtn = Instance.new("TextButton", topBar)
closeBtn.Size = UDim2.fromOffset(30,30)
closeBtn.Position = UDim2.new(1,-35,0,5)
closeBtn.Text = "X"
closeBtn.BackgroundColor3 = Color3.fromRGB(255,59,59)
closeBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(1,0)

minimizeBtn.MouseButton1Click:Connect(function()
	if minimized then
		TweenService:Create(main,TweenInfo.new(0.3),{Size = UDim2.fromOffset(800,520)}):Play()
	else
		TweenService:Create(main,TweenInfo.new(0.3),{Size = UDim2.fromOffset(800,40)}):Play()
	end
	minimized = not minimized
end)

closeBtn.MouseButton1Click:Connect(function()
	TweenService:Create(main,TweenInfo.new(0.3),{Size = UDim2.fromOffset(0,0)}):Play()
	task.wait(0.3)
	gui:Destroy()
end)

--========================--
-- TAB SYSTEM
--========================--

local tabBar = Instance.new("Frame", main)
tabBar.Position = UDim2.new(0,0,0,40)
tabBar.Size = UDim2.new(1,0,0,40)
tabBar.BackgroundColor3 = Color3.fromRGB(20,20,20)

local function createTab(name, position)
	local btn = Instance.new("TextButton", tabBar)
	btn.Size = UDim2.fromOffset(150,40)
	btn.Position = UDim2.new(0,position,0,0)
	btn.Text = name
	btn.BackgroundTransparency = 1
	btn.TextColor3 = Color3.fromRGB(212,175,55)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 14
	return btn
end

local dashboardTab = createTab("Dashboard", 20)
local remoteTab = createTab("Remotes", 180)
local defenseTab = createTab("Defense Code", 340)

local pages = {}

local function createPage()
	local page = Instance.new("Frame", main)
	page.Position = UDim2.new(0,0,0,80)
	page.Size = UDim2.new(1,0,1,-80)
	page.BackgroundTransparency = 1
	page.Visible = false
	return page
end

pages.Dashboard = createPage()
pages.Remotes = createPage()
pages.Defense = createPage()

local function switchTab(name)
	for k,v in pairs(pages) do
		v.Visible = false
	end
	pages[name].Visible = true
end

dashboardTab.MouseButton1Click:Connect(function() switchTab("Dashboard") end)
remoteTab.MouseButton1Click:Connect(function() switchTab("Remotes") end)
defenseTab.MouseButton1Click:Connect(function() switchTab("Defense") end)

switchTab("Dashboard")

--========================--
-- DASHBOARD PAGE
--========================--

local scoreLabel = Instance.new("TextLabel", pages.Dashboard)
scoreLabel.Size = UDim2.new(0,300,0,80)
scoreLabel.Position = UDim2.new(0.5,-150,0.3,0)
scoreLabel.BackgroundTransparency = 1
scoreLabel.Font = Enum.Font.GothamBold
scoreLabel.TextSize = 40

local function updateScore()
	local rank, color = getRank(SecurityScore)
	scoreLabel.Text = "Score: "..SecurityScore.." ("..rank..")"
	scoreLabel.TextColor3 = color
end

updateScore()

--========================--
-- REMOTE SCAN PAGE
--========================--

local remoteListFrame = Instance.new("ScrollingFrame", pages.Remotes)
remoteListFrame.Size = UDim2.new(0.8,0,0.8,0)
remoteListFrame.Position = UDim2.new(0.1,0,0.1,0)
remoteListFrame.BackgroundColor3 = Color3.fromRGB(25,25,25)
Instance.new("UICorner", remoteListFrame).CornerRadius = UDim.new(0,12)

local layout = Instance.new("UIListLayout", remoteListFrame)

local function registerIssue(severity, text)
	SecurityScore = math.clamp(SecurityScore - SeverityWeight[severity],0,100)
	updateScore()
end

local function scanRemotes()
	for _,obj in pairs(ReplicatedStorage:GetDescendants()) do
		if obj:IsA("RemoteEvent") then
			table.insert(RemoteList,obj.Name)
			local lbl = Instance.new("TextLabel")
			lbl.Size = UDim2.new(1,-10,0,30)
			lbl.BackgroundTransparency = 1
			lbl.Text = obj.Name
			lbl.TextColor3 = Color3.fromRGB(255,193,7)
			lbl.Parent = remoteListFrame
			registerIssue("Warning","Remote exposed")
		end
	end
	task.wait()
	remoteListFrame.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y)
end

scanRemotes()

--========================--
-- DEFENSE CODE PAGE
--========================--

local codeBox = Instance.new("TextBox", pages.Defense)
codeBox.Size = UDim2.new(0.9,0,0.7,0)
codeBox.Position = UDim2.new(0.05,0,0.1,0)
codeBox.MultiLine = true
codeBox.TextEditable = false
codeBox.Font = Enum.Font.Code
codeBox.TextSize = 14
codeBox.TextColor3 = Color3.fromRGB(0,200,83)
codeBox.BackgroundColor3 = Color3.fromRGB(20,20,20)
Instance.new("UICorner", codeBox).CornerRadius = UDim.new(0,12)

local function generateDefense(remoteName)
	return "-- Secure Server Template for "..remoteName.."\n-- Add validation logic server-side."
end

local genBtn = Instance.new("TextButton", pages.Defense)
genBtn.Size = UDim2.fromOffset(200,40)
genBtn.Position = UDim2.new(0.5,-100,0.85,0)
genBtn.Text = "Generate Code"
genBtn.BackgroundColor3 = Color3.fromRGB(212,175,55)
genBtn.TextColor3 = Color3.new(0,0,0)
Instance.new("UICorner", genBtn).CornerRadius = UDim.new(1,0)

genBtn.MouseButton1Click:Connect(function()
	if #RemoteList > 0 then
		codeBox.Text = generateDefense(RemoteList[1])
	end
end)

--========================--
-- RUNTIME MONITOR
--========================--

RunService.Heartbeat:Connect(function()
	local char = player.Character
	if char and char:FindFirstChild("Humanoid") then
		if char.Humanoid.WalkSpeed > 25 then
			registerIssue("Critical","Speed anomaly")
		end
	end
end)
