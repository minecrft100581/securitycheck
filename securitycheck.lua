--// Advanced Local Security Scanner (Single LocalScript)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

--================ UI 생성 =================--

local gui = Instance.new("ScreenGui")
gui.Name = "SecurityScannerUI"
gui.ResetOnSpawn = false
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 650, 0, 450)
main.Position = UDim2.new(0.5, -325, 0.5, -225)
main.BackgroundColor3 = Color3.fromRGB(20,20,25)
main.BorderSizePixel = 0
main.Parent = gui
main.Active = true
main.Draggable = true

local corner = Instance.new("UICorner", main)
corner.CornerRadius = UDim.new(0,12)

-- TopBar
local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1,0,0,40)
topBar.BackgroundColor3 = Color3.fromRGB(30,30,40)
topBar.Parent = main

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,1,0)
title.BackgroundTransparency = 1
title.Text = "Advanced Local Security Analyzer"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.Parent = topBar

--================ 탭 버튼 영역 =================--

local tabBar = Instance.new("Frame")
tabBar.Size = UDim2.new(1,0,0,35)
tabBar.Position = UDim2.new(0,0,0,40)
tabBar.BackgroundColor3 = Color3.fromRGB(25,25,35)
tabBar.Parent = main

local pages = Instance.new("Frame")
pages.Size = UDim2.new(1,0,1,-75)
pages.Position = UDim2.new(0,0,0,75)
pages.BackgroundTransparency = 1
pages.Parent = main

--================ Dashboard Page =================--

local dashboard = Instance.new("Frame")
dashboard.Size = UDim2.new(1,0,1,0)
dashboard.BackgroundTransparency = 1
dashboard.Parent = pages

local startButton = Instance.new("TextButton")
startButton.Size = UDim2.new(0,200,0,50)
startButton.Position = UDim2.new(0.5,-100,0.5,-25)
startButton.Text = "검사 시작"
startButton.BackgroundColor3 = Color3.fromRGB(0,170,255)
startButton.TextColor3 = Color3.new(1,1,1)
startButton.Font = Enum.Font.GothamBold
startButton.TextSize = 16
startButton.Parent = dashboard

Instance.new("UICorner", startButton).CornerRadius = UDim.new(0,10)

-- 보안등급 시각화 바
local gradeBar = Instance.new("Frame")
gradeBar.Size = UDim2.new(0,300,0,25)
gradeBar.Position = UDim2.new(0.5,-150,0.7,0)
gradeBar.BackgroundColor3 = Color3.fromRGB(60,60,70)
gradeBar.Parent = dashboard
Instance.new("UICorner", gradeBar).CornerRadius = UDim.new(0,8)

local gradeFill = Instance.new("Frame")
gradeFill.Size = UDim2.new(0,0,1,0)
gradeFill.BackgroundColor3 = Color3.fromRGB(0,255,100)
gradeFill.Parent = gradeBar
Instance.new("UICorner", gradeFill).CornerRadius = UDim.new(0,8)

-- Dashboard 탭 버튼
local dashboardTab = Instance.new("TextButton")
dashboardTab.Size = UDim2.new(0,120,1,0)
dashboardTab.Text = "Dashboard"
dashboardTab.BackgroundColor3 = Color3.fromRGB(40,40,55)
dashboardTab.TextColor3 = Color3.new(1,1,1)
dashboardTab.Parent = tabBar

--================ 스캔 로직 =================--

local function runScan()
    local score = 100
    local resultText = "🔎 검사 결과:\n\n"

    -- 예시 검사 1: RemoteEvent 노출 확인
    for _,v in pairs(game:GetDescendants()) do
        if v:IsA("RemoteEvent") then
            score -= 2
            resultText ..= "- RemoteEvent 발견: "..v.Name.."\n"
        end
    end

    -- 예시 검사 2: 로컬 환경 감시
    if getgenv then
        score -= 10
        resultText ..= "- getgenv 접근 가능\n"
    end

    -- 등급 계산
    score = math.clamp(score,0,100)

    gradeFill:TweenSize(
        UDim2.new(score/100,0,1,0),
        Enum.EasingDirection.Out,
        Enum.EasingStyle.Quad,
        0.5,
        true
    )

    if score > 70 then
        gradeFill.BackgroundColor3 = Color3.fromRGB(0,255,100)
    elseif score > 40 then
        gradeFill.BackgroundColor3 = Color3.fromRGB(255,170,0)
    else
        gradeFill.BackgroundColor3 = Color3.fromRGB(255,0,0)
    end

    return resultText
end

--================ 결과 탭 생성 =================--

local function createResultTab(resultText)

    local resultPage = Instance.new("Frame")
    resultPage.Size = UDim2.new(1,0,1,0)
    resultPage.BackgroundTransparency = 1
    resultPage.Visible = false
    resultPage.Parent = pages

    local resultBox = Instance.new("TextLabel")
    resultBox.Size = UDim2.new(1,-20,1,-20)
    resultBox.Position = UDim2.new(0,10,0,10)
    resultBox.BackgroundColor3 = Color3.fromRGB(30,30,40)
    resultBox.TextColor3 = Color3.new(1,1,1)
    resultBox.Font = Enum.Font.Code
    resultBox.TextSize = 14
    resultBox.TextWrapped = true
    resultBox.TextYAlignment = Enum.TextYAlignment.Top
    resultBox.Text = resultText
    resultBox.Parent = resultPage
    Instance.new("UICorner", resultBox).CornerRadius = UDim.new(0,10)

    local resultTab = Instance.new("TextButton")
    resultTab.Size = UDim2.new(0,120,1,0)
    resultTab.Position = UDim2.new(0,120,0,0)
    resultTab.Text = "검사 결과"
    resultTab.BackgroundColor3 = Color3.fromRGB(40,40,55)
    resultTab.TextColor3 = Color3.new(1,1,1)
    resultTab.Parent = tabBar

    resultTab.MouseButton1Click:Connect(function()
        dashboard.Visible = false
        resultPage.Visible = true
    end)

    dashboardTab.MouseButton1Click:Connect(function()
        dashboard.Visible = true
        resultPage.Visible = false
    end)
end

--================ 버튼 이벤트 =================--

startButton.MouseButton1Click:Connect(function()
    local results = runScan()
    createResultTab(results)
end)
