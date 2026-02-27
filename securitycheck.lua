-- CLIENT SECURITY INTELLIGENCE DASHBOARD (Safe Edition)

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer

--========================--
-- CONFIG
--========================--

local SeverityWeight = {
	Critical = 40,
	Warning = 15,
	Info = 5
}

local SecurityScore = 100
local Issues = {}
local RemoteList = {}

--========================--
-- UI SETUP
--========================--

local gui = Instance.new("ScreenGui")
gui.Name = "SecurityDashboard"
gui.Parent = player:WaitForChild("PlayerGui")

local main = Instance.new("Frame", gui)
main.Size = UDim2.fromOffset(700, 450)
main.Position = UDim2.fromScale(0.5,0.5)
main.AnchorPoint = Vector2.new(0.5,0.5)
main.BackgroundColor3 = Color3.fromRGB(17,17,17)
main.Active = true
main.Draggable = true

Instance.new("UICorner", main).CornerRadius = UDim.new(0,18)

-- Title
local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1,0,0,40)
title.BackgroundTransparency = 1
title.Text = "CLIENT SECURITY INTELLIGENCE"
title.TextColor3 = Color3.fromRGB(212,175,55)
title.Font = Enum.Font.GothamBold
title.TextSize = 18

-- Score Label
local scoreLabel = Instance.new("TextLabel", main)
scoreLabel.Position = UDim2.new(0,20,0,60)
scoreLabel.Size = UDim2.new(0,200,0,50)
scoreLabel.BackgroundTransparency = 1
scoreLabel.Font = Enum.Font.GothamBold
scoreLabel.TextSize = 32
scoreLabel.TextColor3 = Color3.fromRGB(0,200,83)
scoreLabel.Text = "Score: 100"

-- Log Frame
local logFrame = Instance.new("ScrollingFrame", main)
logFrame.Position = UDim2.new(0,250,0,60)
logFrame.Size = UDim2.new(0,420,0,250)
logFrame.BackgroundColor3 = Color3.fromRGB(25,25,25)
logFrame.CanvasSize = UDim2.new(0,0,0,0)

local layout = Instance.new("UIListLayout", logFrame)

-- Code Output
local codeBox = Instance.new("TextBox", main)
codeBox.Position = UDim2.new(0,20,0,120)
codeBox.Size = UDim2.new(0,650,0,200)
codeBox.MultiLine = true
codeBox.ClearTextOnFocus = false
codeBox.TextEditable = false
codeBox.Font = Enum.Font.Code
codeBox.TextSize = 14
codeBox.TextColor3 = Color3.fromRGB(0,200,83)
codeBox.BackgroundColor3 = Color3.fromRGB(20,20,20)

--========================--
-- LOG SYSTEM
--========================--

local function pulse()
	local t1 = TweenService:Create(main,TweenInfo.new(0.15),{Size = UDim2.fromOffset(720,470)})
	t1:Play()
	t1.Completed:Wait()
	TweenService:Create(main,TweenInfo.new(0.15),{Size = UDim2.fromOffset(700,450)}):Play()
end

local function addLog(text, severity)
	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1,-10,0,25)
	lbl.BackgroundTransparency = 1
	lbl.TextWrapped = true
	lbl.Font = Enum.Font.Gotham
	lbl.TextSize = 14
	lbl.Text = "["..severity.."] "..text
	
	if severity == "Critical" then
		lbl.TextColor3 = Color3.fromRGB(255,59,59)
	elseif severity == "Warning" then
		lbl.TextColor3 = Color3.fromRGB(255,193,7)
	else
		lbl.TextColor3 = Color3.fromRGB(0,200,83)
	end
	
	lbl.Parent = logFrame
	task.wait()
	logFrame.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y)
end

local function registerIssue(severity, text)
	SecurityScore = math.clamp(SecurityScore - SeverityWeight[severity],0,100)
	scoreLabel.Text = "Score: "..SecurityScore
	
	if SecurityScore > 70 then
		scoreLabel.TextColor3 = Color3.fromRGB(0,200,83)
	elseif SecurityScore > 40 then
		scoreLabel.TextColor3 = Color3.fromRGB(255,193,7)
	else
		scoreLabel.TextColor3 = Color3.fromRGB(255,59,59)
	end
	
	addLog(text,severity)
	pulse()
end

--========================--
-- REMOTE SCAN
--========================--

local function classify(name)
	name = string.lower(name)
	if name:find("buy") or name:find("shop") then
		return "Economy"
	elseif name:find("damage") or name:find("attack") then
		return "Combat"
	elseif name:find("admin") then
		return "Admin"
	end
	return "Generic"
end

local function scanRemotes()
	for _,obj in pairs(ReplicatedStorage:GetDescendants()) do
		if obj:IsA("RemoteEvent") then
			table.insert(RemoteList,obj.Name)
			registerIssue("Warning","Remote exposed: "..obj.Name)
		end
	end
end

--========================--
-- CUSTOM DEFENSE GENERATOR
--========================--

local function generateDefense(remoteName)
	local rType = classify(remoteName)
	local code = {}

	table.insert(code,"-- SECURE SERVER SCRIPT")
	table.insert(code,"local ReplicatedStorage = game:GetService('ReplicatedStorage')")
	table.insert(code,"local Remote = ReplicatedStorage:WaitForChild('"..remoteName.."')")
	table.insert(code,"local LastCall = {}")
	table.insert(code,"local COOLDOWN = 1")
	table.insert(code,"")
	table.insert(code,"Remote.OnServerEvent:Connect(function(player, ...)")
	table.insert(code,"	local args = {...}")
	table.insert(code,"	if LastCall[player] and tick()-LastCall[player] < COOLDOWN then return end")
	table.insert(code,"	LastCall[player] = tick()")

	if rType == "Economy" then
		table.insert(code,"	local amount = args[1]")
		table.insert(code,"	if type(amount) ~= 'number' then return end")
		table.insert(code,"	if amount < 0 then return end")
		table.insert(code,"	-- Recalculate price server-side")
	elseif rType == "Combat" then
		table.insert(code,"	local target = args[1]")
		table.insert(code,"	if not target or not target:FindFirstChild('Humanoid') then return end")
		table.insert(code,"	-- Validate distance server-side")
	elseif rType == "Admin" then
		table.insert(code,"	local Admins = {123456789}")
		table.insert(code,"	if not table.find(Admins, player.UserId) then return end")
	else
		table.insert(code,"	-- Generic validation")
		table.insert(code,"	for _,v in pairs(args) do")
		table.insert(code,"		if typeof(v)=='number' and v < -100000 then return end")
		table.insert(code,"	end")
	end

	table.insert(code,"end)")
	return table.concat(code,"\n")
end

-- Button
local genBtn = Instance.new("TextButton", main)
genBtn.Position = UDim2.new(0,20,0,350)
genBtn.Size = UDim2.new(0,200,0,30)
genBtn.Text = "Generate Defense Code"
genBtn.BackgroundColor3 = Color3.fromRGB(212,175,55)
genBtn.TextColor3 = Color3.new(0,0,0)

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
			registerIssue("Critical","Abnormal WalkSpeed detected")
		end
	end
end)

-- INIT
scanRemotes()
