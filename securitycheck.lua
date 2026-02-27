-- Roblox Security Analyzer ELITE (Marketplace Edition)

local Players = game:GetService("Players")
local player = Players.LocalPlayer

local riskScore = 0
local results = {}

-------------------------------------------------
-- 등급 계산
-------------------------------------------------

local function getGrade(score)
	if score <= 15 then return "A", Color3.fromRGB(0,200,0)
	elseif score <= 30 then return "B", Color3.fromRGB(80,220,0)
	elseif score <= 60 then return "C", Color3.fromRGB(255,170,0)
	elseif score <= 90 then return "D", Color3.fromRGB(255,100,0)
	else return "F", Color3.fromRGB(255,0,0)
	end
end

-------------------------------------------------
-- 결과 추가
-------------------------------------------------

local function addResult(icon, message, defenseCode)
	table.insert(results, {
		icon = icon,
		message = message,
		defenseCode = defenseCode
	})
end

-------------------------------------------------
-- Remote 분석
-------------------------------------------------

local function analyzeRemotes()
	for _, obj in ipairs(game:GetDescendants()) do
		if obj:IsA("RemoteEvent") then
			riskScore += 20
			
			local defense = 
"RemoteEvent.OnServerEvent:Connect(function(player, value)\n" ..
"    if typeof(value) ~= 'number' then return end\n" ..
"    if value < 0 or value > 1000 then return end\n" ..
"    -- 안전 로직 실행\nend)"
			
			addResult("⚠️",
				obj.Name .. "가 존재하여 서버 입력 검증이 필요합니다.",
				defense
			)
		end
	end
end

-------------------------------------------------
-- leaderstats 분석
-------------------------------------------------

local function analyzeLeaderstats()
	if player:FindFirstChild("leaderstats") then
		riskScore += 40
		
		local defense =
"ServerScriptService Script:\n" ..
"local Players = game:GetService('Players')\n" ..
"Players.PlayerAdded:Connect(function(player)\n" ..
"    local stats = Instance.new('Folder')\n" ..
"    stats.Name = 'leaderstats'\n" ..
"    stats.Parent = player\nend)"
		
		addResult("🚨",
			"leaderstats가 클라이언트 접근 가능하여 조작 위험이 있습니다.",
			defense
		)
	end
end

-------------------------------------------------
-- GUI 생성
-------------------------------------------------

local function createGUI()

	local grade, gradeColor = getGrade(riskScore)

	local gui = Instance.new("ScreenGui", player.PlayerGui)
	gui.Name = "SecurityAnalyzerElite"

	local main = Instance.new("Frame", gui)
	main.Size = UDim2.new(0,700,0,550)
	main.Position = UDim2.new(0.5,-350,0.5,-275)
	main.BackgroundColor3 = Color3.fromRGB(18,18,25)
	
	Instance.new("UICorner", main).CornerRadius = UDim.new(0,16)

	-- 타이틀
	local title = Instance.new("TextLabel", main)
	title.Size = UDim2.new(1,0,0,50)
	title.BackgroundTransparency = 1
	title.TextScaled = true
	title.Text = "🛡️ Security Grade: "..grade.."  (Score: "..riskScore..")"
	title.TextColor3 = gradeColor

	-- 스크롤 영역
	local scroll = Instance.new("ScrollingFrame", main)
	scroll.Size = UDim2.new(0.95,0,0.75,0)
	scroll.Position = UDim2.new(0.025,0,0,70)
	scroll.CanvasSize = UDim2.new(0,0,0,#results*120)
	scroll.ScrollBarThickness = 6
	scroll.BackgroundTransparency = 1

	local layout = Instance.new("UIListLayout", scroll)
	layout.Padding = UDim.new(0,15)

	for _, item in ipairs(results) do
		
		local container = Instance.new("Frame", scroll)
		container.Size = UDim2.new(1,-10,0,100)
		container.BackgroundColor3 = Color3.fromRGB(35,35,45)
		Instance.new("UICorner", container).CornerRadius = UDim.new(0,12)

		local label = Instance.new("TextLabel", container)
		label.Size = UDim2.new(1,-20,0.5,0)
		label.Position = UDim2.new(0,10,0,5)
		label.BackgroundTransparency = 1
		label.TextWrapped = true
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.TextColor3 = Color3.fromRGB(230,230,230)
		label.Text = item.icon.." "..item.message

		-- 방어 코드 보기 버튼
		local btn = Instance.new("TextButton", container)
		btn.Size = UDim2.new(0.4,0,0,30)
		btn.Position = UDim2.new(0.05,0,1,-35)
		btn.Text = "📋 방어 코드 보기"
		btn.BackgroundColor3 = Color3.fromRGB(70,70,90)
		btn.TextColor3 = Color3.new(1,1,1)

		btn.MouseButton1Click:Connect(function()
			
			local popup = Instance.new("Frame", gui)
			popup.Size = UDim2.new(0,600,0,300)
			popup.Position = UDim2.new(0.5,-300,0.5,-150)
			popup.BackgroundColor3 = Color3.fromRGB(20,20,30)
			Instance.new("UICorner", popup).CornerRadius = UDim.new(0,12)

			local codeBox = Instance.new("TextBox", popup)
			codeBox.Size = UDim2.new(0.95,0,0.8,0)
			codeBox.Position = UDim2.new(0.025,0,0.1,0)
			codeBox.TextWrapped = false
			codeBox.ClearTextOnFocus = false
			codeBox.MultiLine = true
			codeBox.TextXAlignment = Enum.TextXAlignment.Left
			codeBox.TextYAlignment = Enum.TextYAlignment.Top
			codeBox.Text = item.defenseCode
			codeBox.TextColor3 = Color3.fromRGB(0,255,150)
			codeBox.BackgroundColor3 = Color3.fromRGB(10,10,15)

			local close = Instance.new("TextButton", popup)
			close.Size = UDim2.new(0.3,0,0,30)
			close.Position = UDim2.new(0.35,0,1,-40)
			close.Text = "닫기"
			close.BackgroundColor3 = Color3.fromRGB(80,50,50)
			close.TextColor3 = Color3.new(1,1,1)

			close.MouseButton1Click:Connect(function()
				popup:Destroy()
			end)
		end)
	end
end

-------------------------------------------------
-- 실행
-------------------------------------------------

analyzeRemotes()
analyzeLeaderstats()
createGUI()
