--// FAIRWELL HEAVEN
--// Main UI
--// Version 2.0

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local MainUI = {
	Name = "Main UI",
	Description = "Fairwell Heaven main interface."
}

--==================================================
-- COLORS
--==================================================

local BLUE = Color3.fromRGB(27, 147, 227) -- #1B93E3
local BACKGROUND = Color3.fromRGB(6, 4, 43) -- #06042B
local DARK = Color3.fromRGB(8, 6, 55)
local WHITE = Color3.fromRGB(255, 255, 255)
local MUTED = Color3.fromRGB(170, 175, 195)

--==================================================
-- TARGET WINDOW SIZE
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

	--==================================================
	-- USE LOADING SCREEN'S WINDOW
	--==================================================

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
	-- TITLE BAR
	--==================================================

	local TitleBar = Instance.new("Frame")

	TitleBar.Name = "TitleBar"

	TitleBar.Size = UDim2.new(1, 0, 0, 50)

	TitleBar.BackgroundColor3 = DARK
	TitleBar.BorderSizePixel = 0

	TitleBar.BackgroundTransparency = 1

	TitleBar.Parent = Window

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

	--==================================================
	-- VERSION
	--==================================================

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

	--==================================================
	-- TITLE LINE
	--==================================================

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
	-- CONTENT
	--==================================================

	local Content = Instance.new("Frame")

	Content.Name = "Content"

	Content.Position = UDim2.new(0, 125, 0, 50)
	Content.Size = UDim2.new(1, -125, 1, -50)

	Content.BackgroundColor3 = BACKGROUND
	Content.BorderSizePixel = 0

	Content.BackgroundTransparency = 1

	Content.Parent = Window

	--==================================================
	-- MAIN PAGE
	--==================================================

	local MainPage = Instance.new("Frame")

	MainPage.Name = "MainPage"
	MainPage.Size = UDim2.fromScale(1, 1)

	MainPage.BackgroundTransparency = 1

	MainPage.Parent = Content

	--==================================================
	-- MAIN TITLE
	--==================================================

	local Welcome = Instance.new("TextLabel")

	Welcome.Name = "Welcome"

	Welcome.Position = UDim2.new(0, 24, 0, 24)
	Welcome.Size = UDim2.new(1, -48, 0, 40)

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

	Description.Position = UDim2.new(0, 24, 0, 72)
	Description.Size = UDim2.new(1, -48, 0, 60)

	Description.BackgroundTransparency = 1

	Description.Text =
		"Your feature hub is ready."

	Description.TextColor3 = MUTED
	Description.TextSize = 15
	Description.Font = Enum.Font.Gotham
	Description.TextXAlignment = Enum.TextXAlignment.Left

	Description.TextTransparency = 1

	Description.Parent = MainPage

	--==================================================
	-- DEV PAGE
	--==================================================

	local DevPage = Instance.new("Frame")

	DevPage.Name = "DevPage"
	DevPage.Size = UDim2.fromScale(1, 1)

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
	-- TAB CREATOR
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
	-- STORE REFERENCES
	--==================================================

	self.TitleBar = TitleBar
	self.Title = Title
	self.Version = Version
	self.TitleLine = TitleLine

	self.TabBar = TabBar
	self.Content = Content

	self.Welcome = Welcome
	self.Description = Description
	self.DevTitle = DevTitle
	self.DevInfo = DevInfo

	self.MainButton = MainButton
	self.DevButton = DevButton

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

	-- Background sections
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

	-- Text
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

	if self.Gui then
		self.Gui:Destroy()
	end

	self.Gui = nil
	self.Window = nil

end

return MainUI