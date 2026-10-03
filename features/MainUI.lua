--// FAIRWELL HEAVEN
--// Main UI
--// Version 2.2

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local MainUI = {
	Name = "Main UI",
	Description = "Fairwell Heaven main interface."
}

--==================================================
-- COLORS
--==================================================

local BLUE = Color3.fromRGB(27, 147, 227)
local BACKGROUND = Color3.fromRGB(6, 4, 43)
local DARK = Color3.fromRGB(8, 6, 55)
local WHITE = Color3.fromRGB(255, 255, 255)
local MUTED = Color3.fromRGB(170, 175, 195)

--==================================================
-- GAME RULES
--==================================================

local DOORS_PLACE_ID = 6516141723

local function IsDOORS()
	return game.PlaceId == DOORS_PLACE_ID
end

--==================================================
-- WINDOW SIZE
--==================================================

MainUI.TargetSize = UDim2.fromScale(0.78, 0.68)

--==================================================
-- START
--==================================================

function MainUI.Start(self, Hub)

	local Player = Players.LocalPlayer

	if not Player then
		warn("[Fairwell Heaven] LocalPlayer not found.")
		return
	end

	local PlayerGui = Player:WaitForChild("PlayerGui")

	local Gui = PlayerGui:FindFirstChild("FairwellHeaven_Main")

	if not Gui then
		warn("[Fairwell Heaven] Main window not found.")
		return
	end

	local Window = Gui:FindFirstChild("Window")

	if not Window then
		warn("[Fairwell Heaven] Loading window not found.")
		return
	end

	self.Gui = Gui
	self.Window = Window

	--==================================================
	-- DRAGGING
	--==================================================

	local Dragging = false
	local DragStart
	local StartPosition

	local function UpdateDrag(Input)

		local Delta = Input.Position - DragStart

		Window.Position = UDim2.new(
			StartPosition.X.Scale,
			StartPosition.X.Offset + Delta.X,
			StartPosition.Y.Scale,
			StartPosition.Y.Offset + Delta.Y
		)

	end

	--==================================================
	-- TITLE BAR
	--==================================================

	local TitleBar = Instance.new("Frame")

	TitleBar.Name = "TitleBar"
	TitleBar.Size = UDim2.new(1, 0, 0, 50)
	TitleBar.BackgroundColor3 = DARK
	TitleBar.BorderSizePixel = 0
	TitleBar.BackgroundTransparency = 1
	TitleBar.Active = true
	TitleBar.Parent = Window

	TitleBar.InputBegan:Connect(function(Input)

		if Input.UserInputType == Enum.UserInputType.MouseButton1
			or Input.UserInputType == Enum.UserInputType.Touch then

			Dragging = true

			DragStart = Input.Position
			StartPosition = Window.Position

			Input.Changed:Connect(function()

				if Input.UserInputState == Enum.UserInputState.End then
					Dragging = false
				end

			end)
		end

	end)

	UserInputService.InputChanged:Connect(function(Input)

		if not Dragging then
			return
		end

		if Input.UserInputType == Enum.UserInputType.MouseMovement
			or Input.UserInputType == Enum.UserInputType.Touch then

			UpdateDrag(Input)

		end

	end)

	--==================================================
	-- TITLE
	--==================================================

	local Title = Instance.new("TextLabel")

	Title.Name = "Title"
	Title.Position = UDim2.new(0, 16, 0, 0)
	Title.Size = UDim2.new(0.6, 0, 1, 0)
	Title.BackgroundTransparency = 1
	Title.Text = "FAIRWELL HEAVEN"
	Title.TextColor3 = WHITE
	Title.TextSize = 20
	Title.Font = Enum.Font.GothamBold
	Title.TextXAlignment = Enum.TextXAlignment.Left
	Title.TextTransparency = 1
	Title.Parent = TitleBar

	local Version = Instance.new("TextLabel")

	Version.Name = "Version"
	Version.AnchorPoint = Vector2.new(1, 0)
	Version.Position = UDim2.new(1, -14, 0, 0)
	Version.Size = UDim2.new(0.3, 0, 1, 0)
	Version.BackgroundTransparency = 1
	Version.Text = "v" .. tostring(Hub.Version)
	Version.TextColor3 = BLUE
	Version.TextSize = 14
	Version.Font = Enum.Font.GothamMedium
	Version.TextXAlignment = Enum.TextXAlignment.Right
	Version.TextTransparency = 1
	Version.Parent = TitleBar

	local TitleLine = Instance.new("Frame")

	TitleLine.Name = "TitleLine"
	TitleLine.Position = UDim2.new(0, 0, 1, -2)
	TitleLine.Size = UDim2.new(1, 0, 0, 2)
	TitleLine.BackgroundColor3 = BLUE
	TitleLine.BorderSizePixel = 0
	TitleLine.BackgroundTransparency = 1
	TitleLine.Parent = TitleBar

	--==================================================
	-- TAB BAR
	--==================================================

	local TabBar = Instance.new("Frame")

	TabBar.Name = "TabBar"
	TabBar.Position = UDim2.new(0, 0, 0, 50)
	TabBar.Size = UDim2.new(0, 125, 1, -50)
	TabBar.BackgroundColor3 = DARK
	TabBar.BorderSizePixel = 0
	TabBar.BackgroundTransparency = 1
	TabBar.Parent = Window

	--==================================================
	-- SCROLLING CONTENT
	--==================================================

	local Content = Instance.new("ScrollingFrame")

	Content.Name = "Content"
	Content.Position = UDim2.new(0, 125, 0, 50)
	Content.Size = UDim2.new(1, -125, 1, -50)

	Content.BackgroundColor3 = BACKGROUND
	Content.BorderSizePixel = 0
	Content.BackgroundTransparency = 1

	Content.ScrollBarThickness = 5
	Content.ScrollBarImageColor3 = BLUE
	Content.ScrollBarImageTransparency = 0.15

	Content.ScrollingDirection = Enum.ScrollingDirection.Y
	Content.CanvasSize = UDim2.new(0, 0, 0, 0)

	Content.AutomaticCanvasSize = Enum.AutomaticSize.Y

	Content.Active = true

	Content.Parent = Window

	--==================================================
	-- MAIN PAGE
	--==================================================

	local MainPage = Instance.new("Frame")

	MainPage.Name = "MainPage"
	MainPage.Size = UDim2.new(1, 0, 0, 700)
	MainPage.BackgroundTransparency = 1
	MainPage.Parent = Content

	--==================================================
	-- WELCOME
	--==================================================

	local Welcome = Instance.new("TextLabel")

	Welcome.Name = "Welcome"
	Welcome.Position = UDim2.new(0, 24, 0, 20)
	Welcome.Size = UDim2.new(1, -48, 0, 35)
	Welcome.BackgroundTransparency = 1

	Welcome.Text = "Welcome to Fairwell Heaven"
	Welcome.TextColor3 = WHITE
	Welcome.TextSize = 24
	Welcome.Font = Enum.Font.GothamBold
	Welcome.TextXAlignment = Enum.TextXAlignment.Left
	Welcome.TextTransparency = 1

	Welcome.Parent = MainPage

	local Description = Instance.new("TextLabel")

	Description.Name = "Description"
	Description.Position = UDim2.new(0, 24, 0, 55)
	Description.Size = UDim2.new(1, -48, 0, 30)
	Description.BackgroundTransparency = 1

	Description.Text = "Your feature hub is ready."
	Description.TextColor3 = MUTED
	Description.TextSize = 15
	Description.Font = Enum.Font.Gotham
	Description.TextXAlignment = Enum.TextXAlignment.Left
	Description.TextTransparency = 1

	Description.Parent = MainPage

	--==================================================
	-- STATUS PANEL
	--==================================================

	local StatusPanel = Instance.new("Frame")

	StatusPanel.Name = "StatusPanel"
	StatusPanel.Position = UDim2.new(0, 24, 0, 100)
	StatusPanel.Size = UDim2.new(1, -48, 0, 235)

	StatusPanel.BackgroundColor3 = DARK
	StatusPanel.BorderSizePixel = 0
	StatusPanel.BackgroundTransparency = 1

	StatusPanel.Parent = MainPage

	local StatusTitle = Instance.new("TextLabel")

	StatusTitle.Name = "StatusTitle"
	StatusTitle.Position = UDim2.new(0, 16, 0, 12)
	StatusTitle.Size = UDim2.new(1, -32, 0, 25)

	StatusTitle.BackgroundTransparency = 1
	StatusTitle.Text = "STATUS"
	StatusTitle.TextColor3 = BLUE
	StatusTitle.TextSize = 15
	StatusTitle.Font = Enum.Font.GothamBold
	StatusTitle.TextXAlignment = Enum.TextXAlignment.Left
	StatusTitle.TextTransparency = 1

	StatusTitle.Parent = StatusPanel

	--==================================================
	-- STATUS ROWS
	--==================================================

	local StatusRows = {}

	local function CreateStatusRow(Name, Y)

		local Label = Instance.new("TextLabel")

		Label.Name = Name .. "Label"
		Label.Position = UDim2.new(0, 16, 0, Y)
		Label.Size = UDim2.new(0.45, 0, 0, 25)

		Label.BackgroundTransparency = 1
		Label.Text = Name
		Label.TextColor3 = MUTED
		Label.TextSize = 14
		Label.Font = Enum.Font.Gotham
		Label.TextXAlignment = Enum.TextXAlignment.Left
		Label.TextTransparency = 1

		Label.Parent = StatusPanel

		local Value = Instance.new("TextLabel")

		Value.Name = Name .. "Value"
		Value.Position = UDim2.new(0.45, 0, 0, Y)
		Value.Size = UDim2.new(0.55, -16, 0, 25)

		Value.BackgroundTransparency = 1
		Value.Text = "..."
		Value.TextColor3 = WHITE
		Value.TextSize = 14
		Value.Font = Enum.Font.GothamMedium
		Value.TextXAlignment = Enum.TextXAlignment.Right
		Value.TextTransparency = 1

		Value.Parent = StatusPanel

		StatusRows[Name] = Value

		return Value
	end

	CreateStatusRow("Game", 45)
	CreateStatusRow("Place ID", 70)
	CreateStatusRow("Current Room", 95)
	CreateStatusRow("Current Door", 120)
	CreateStatusRow("Position", 145)
	CreateStatusRow("Loaded Features", 170)
	CreateStatusRow("Enabled Features", 195)

	--==================================================
	-- INITIAL STATUS
	--==================================================

	if IsDOORS() then
		StatusRows["Game"].Text = "DOORS"
	else
		StatusRows["Game"].Text = "Universal"
	end

	StatusRows["Place ID"].Text = tostring(game.PlaceId)

	--==================================================
	-- DEV PAGE
	--==================================================

	local DevPage = Instance.new("Frame")

	DevPage.Name = "DevPage"
	DevPage.Size = UDim2.new(1, 0, 0, 700)
	DevPage.BackgroundTransparency = 1
	DevPage.Visible = false

	DevPage.Parent = Content

	local DevTitle = Instance.new("TextLabel")

	DevTitle.Name = "DevTitle"
	DevTitle.Position = UDim2.new(0, 24, 0, 24)
	DevTitle.Size = UDim2.new(1, -48, 0, 40)

	DevTitle.BackgroundTransparency = 1
	DevTitle.Text = "Developer"
	DevTitle.TextColor3 = WHITE
	DevTitle.TextSize = 24
	DevTitle.Font = Enum.Font.GothamBold
	DevTitle.TextXAlignment = Enum.TextXAlignment.Left
	DevTitle.TextTransparency = 1

	DevTitle.Parent = DevPage

	local DevInfo = Instance.new("TextLabel")

	DevInfo.Name = "DevInfo"
	DevInfo.Position = UDim2.new(0, 24, 0, 72)
	DevInfo.Size = UDim2.new(1, -48, 0, 100)

	DevInfo.BackgroundTransparency = 1

	DevInfo.Text =
		"Fairwell Heaven\n"
		.. "Version: " .. tostring(Hub.Version) .. "\n"
		.. "Features: " .. tostring(Hub:GetFeatureCount())

	DevInfo.TextColor3 = MUTED
	DevInfo.TextSize = 15
	DevInfo.Font = Enum.Font.Gotham
	DevInfo.TextXAlignment = Enum.TextXAlignment.Left
	DevInfo.TextYAlignment = Enum.TextYAlignment.Top
	DevInfo.TextTransparency = 1

	DevInfo.Parent = DevPage

	--==================================================
	-- TABS
	--==================================================

	local function CreateTab(Name, Order)

		local Button = Instance.new("TextButton")

		Button.Name = Name .. "Tab"

		Button.Position =
			UDim2.new(0, 10, 0, 10 + ((Order - 1) * 48))

		Button.Size = UDim2.new(1, -20, 0, 38)

		Button.BackgroundColor3 = BACKGROUND
		Button.BorderSizePixel = 0

		Button.Text = Name:upper()
		Button.TextColor3 = MUTED
		Button.TextSize = 14
		Button.Font = Enum.Font.GothamBold

		Button.AutoButtonColor = false

		Button.BackgroundTransparency = 1
		Button.TextTransparency = 1

		Button.Parent = TabBar

		local Stroke = Instance.new("UIStroke")

		Stroke.Color = BLUE
		Stroke.Thickness = 1
		Stroke.Transparency = 1

		Stroke.Parent = Button

		return Button, Stroke
	end

	local MainButton, MainStroke =
		CreateTab("Main", 1)

	local DevButton, DevStroke =
		CreateTab("Dev", 2)

	--==================================================
	-- TAB SWITCHING
	--==================================================

	local CurrentTab

	local function SelectTab(Name)

		if Name == CurrentTab then
			return
		end

		CurrentTab = Name

		-- Reset scroll when changing tabs
		Content.CanvasPosition = Vector2.new(0, 0)

		if Name == "Main" then

			MainPage.Visible = true
			DevPage.Visible = false

			MainButton.TextColor3 = WHITE
			MainStroke.Transparency = 0

			DevButton.TextColor3 = MUTED
			DevStroke.Transparency = 1

		elseif Name == "Dev" then

			MainPage.Visible = false
			DevPage.Visible = true

			MainButton.TextColor3 = MUTED
			MainStroke.Transparency = 1

			DevButton.TextColor3 = WHITE
			DevStroke.Transparency = 0

		end

	end

	MainButton.MouseButton1Click:Connect(function()
		SelectTab("Main")
	end)

	DevButton.MouseButton1Click:Connect(function()
		SelectTab("Dev")
	end)

	SelectTab("Main")

	--==================================================
	-- REFERENCES
	--==================================================

	self.TitleBar = TitleBar
	self.Title = Title
	self.Version = Version
	self.TitleLine = TitleLine

	self.TabBar = TabBar
	self.Content = Content

	self.Welcome = Welcome
	self.Description = Description

	self.StatusPanel = StatusPanel
	self.StatusTitle = StatusTitle
	self.StatusRows = StatusRows

	self.DevTitle = DevTitle
	self.DevInfo = DevInfo

	self.MainButton = MainButton
	self.DevButton = DevButton

	--==================================================
	-- LIVE STATUS
	--==================================================

	self.StatusConnection = RunService.Heartbeat:Connect(function()

		if not self.Gui or not self.Gui.Parent then
			return
		end

		--==============================================
		-- PLAYER POSITION
		--==============================================

		local Character = Player.Character
		local Root = Character and Character:FindFirstChild("HumanoidRootPart")

		if Root then

			local Position = Root.Position

			StatusRows["Position"].Text = string.format(
				"%.1f, %.1f, %.1f",
				Position.X,
				Position.Y,
				Position.Z
			)

		else

			StatusRows["Position"].Text = "Unknown"

		end

		--==============================================
		-- FEATURE COUNTS
		--==============================================

		StatusRows["Loaded Features"].Text =
			tostring(Hub:GetFeatureCount())

		local EnabledCount = 0

		for _ in pairs(Hub.Enabled) do
			EnabledCount += 1
		end

		StatusRows["Enabled Features"].Text =
			tostring(EnabledCount)

		--==============================================
		-- DOORS ONLY
		--==============================================

		if IsDOORS() then

			local CurrentRooms =
				workspace:FindFirstChild("CurrentRooms")

			if CurrentRooms then

				local LatestRoom

				for _, Room in ipairs(CurrentRooms:GetChildren()) do

					local Number = tonumber(Room.Name)

					if Number and
						(not LatestRoom or Number > LatestRoom) then

						LatestRoom = Number
					end

				end

				if LatestRoom then

					StatusRows["Current Room"].Text =
						string.format("%03d", LatestRoom)

					StatusRows["Current Door"].Text =
						string.format("%03d", LatestRoom)

				else

					StatusRows["Current Room"].Text =
						"Unknown"

					StatusRows["Current Door"].Text =
						"Unknown"

				end

			else

				StatusRows["Current Room"].Text =
					"Unavailable"

				StatusRows["Current Door"].Text =
					"Unavailable"

			end

		else

			StatusRows["Current Room"].Text = "N/A"
			StatusRows["Current Door"].Text = "N/A"

		end

	end)

	Hub:Log("Main UI prepared.")
end

--==================================================
-- REVEAL
--==================================================

function MainUI:Reveal()

	local FadeInfo = TweenInfo.new(
		0.4,
		Enum.EasingStyle.Quad,
		Enum.EasingDirection.Out
	)

	TweenService:Create(
		self.TitleBar,
		FadeInfo,
		{BackgroundTransparency = 0}
	):Play()

	TweenService:Create(
		self.TitleLine,
		FadeInfo,
		{BackgroundTransparency = 0}
	):Play()

	TweenService:Create(
		self.TabBar,
		FadeInfo,
		{BackgroundTransparency = 0}
	):Play()

	TweenService:Create(
		self.Content,
		FadeInfo,
		{BackgroundTransparency = 0}
	):Play()

	TweenService:Create(
		self.Title,
		FadeInfo,
		{TextTransparency = 0}
	):Play()

	TweenService:Create(
		self.Version,
		FadeInfo,
		{TextTransparency = 0}
	):Play()

	TweenService:Create(
		self.Welcome,
		FadeInfo,
		{TextTransparency = 0}
	):Play()

	TweenService:Create(
		self.Description,
		FadeInfo,
		{TextTransparency = 0}
	):Play()

	TweenService:Create(
		self.StatusPanel,
		FadeInfo,
		{BackgroundTransparency = 0}
	):Play()

	TweenService:Create(
		self.StatusTitle,
		FadeInfo,
		{TextTransparency = 0}
	):Play()

	for _, Value in pairs(self.StatusRows) do

		TweenService:Create(
			Value,
			FadeInfo,
			{TextTransparency = 0}
		):Play()

	end

	TweenService:Create(
		self.DevTitle,
		FadeInfo,
		{TextTransparency = 0}
	):Play()

	TweenService:Create(
		self.DevInfo,
		FadeInfo,
		{TextTransparency = 0}
	):Play()

	TweenService:Create(
		self.MainButton,
		FadeInfo,
		{
			BackgroundTransparency = 0,
			TextTransparency = 0
		}
	):Play()

	TweenService:Create(
		self.DevButton,
		FadeInfo,
		{
			BackgroundTransparency = 0,
			TextTransparency = 0
		}
	):Play()

end

--==================================================
-- STOP
--==================================================

function MainUI.Stop(self, Hub)

	if self.StatusConnection then
		self.StatusConnection:Disconnect()
		self.StatusConnection = nil
	end

	if self.Gui then
		self.Gui:Destroy()
	end

	self.Gui = nil
	self.Window = nil
end

return MainUI