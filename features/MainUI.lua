--// FAIRWELL HEAVEN
--// Main UI
--// Version 1.0

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
local WHITE = Color3.fromRGB(255, 255, 255)
local DARK = Color3.fromRGB(10, 8, 55)

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

	-- Remove existing UI
	local Existing = PlayerGui:FindFirstChild("FairwellHeaven_Main")

	if Existing then
		Existing:Destroy()
	end

	--==================================================
	-- SCREEN GUI
	--==================================================

	local Gui = Instance.new("ScreenGui")

	Gui.Name = "FairwellHeaven_Main"
	Gui.ResetOnSpawn = false
	Gui.IgnoreGuiInset = true
	Gui.DisplayOrder = 100

	Gui.Parent = PlayerGui

	--==================================================
	-- MAIN WINDOW
	--==================================================

	local Window = Instance.new("Frame")

	Window.Name = "Window"
	Window.AnchorPoint = Vector2.new(0.5, 0.5)
	Window.Position = UDim2.fromScale(0.5, 0.5)
	Window.Size = UDim2.fromScale(0.78, 0.68)

	Window.BackgroundColor3 = BACKGROUND
	Window.BorderSizePixel = 0

	Window.Parent = Gui

	-- Outline
	local WindowStroke = Instance.new("UIStroke")

	WindowStroke.Color = BLUE
	WindowStroke.Thickness = 3

	WindowStroke.Parent = Window

	--==================================================
	-- TITLE BAR
	--==================================================

	local TitleBar = Instance.new("Frame")

	TitleBar.Name = "TitleBar"
	TitleBar.Size = UDim2.new(1, 0, 0, 48)

	TitleBar.BackgroundColor3 = DARK
	TitleBar.BorderSizePixel = 0

	TitleBar.Parent = Window

	-- Bottom line
	local TitleLine = Instance.new("Frame")

	TitleLine.Name = "TitleLine"
	TitleLine.Size = UDim2.new(1, 0, 0, 2)
	TitleLine.Position = UDim2.new(0, 0, 1, -2)

	TitleLine.BackgroundColor3 = BLUE
	TitleLine.BorderSizePixel = 0

	TitleLine.Parent = TitleBar

	-- Title
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

	Title.Parent = TitleBar

	-- Version
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

	Version.Parent = TitleBar

	--==================================================
	-- TAB BAR
	--==================================================

	local TabBar = Instance.new("Frame")

	TabBar.Name = "TabBar"
	TabBar.Position = UDim2.new(0, 0, 0, 48)
	TabBar.Size = UDim2.new(0, 125, 1, -48)

	TabBar.BackgroundColor3 = DARK
	TabBar.BorderSizePixel = 0

	TabBar.Parent = Window

	--==================================================
	-- CONTENT AREA
	--==================================================

	local Content = Instance.new("Frame")

	Content.Name = "Content"
	Content.Position = UDim2.new(0, 125, 0, 48)
	Content.Size = UDim2.new(1, -125, 1, -48)

	Content.BackgroundColor3 = BACKGROUND
	Content.BorderSizePixel = 0

	Content.Parent = Window

	--==================================================
	-- PAGE CREATION
	--==================================================

	local MainPage = Instance.new("Frame")

	MainPage.Name = "MainPage"
	MainPage.Size = UDim2.fromScale(1, 1)

	MainPage.BackgroundTransparency = 1

	MainPage.Parent = Content

	local DevPage = Instance.new("Frame")

	DevPage.Name = "DevPage"
	DevPage.Size = UDim2.fromScale(1, 1)

	DevPage.BackgroundTransparency = 1
	DevPage.Visible = false

	DevPage.Parent = Content

	--==================================================
	-- MAIN PAGE
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

	Welcome.Parent = MainPage

	local Description = Instance.new("TextLabel")

	Description.Name = "Description"
	Description.Position = UDim2.new(0, 24, 0, 70)
	Description.Size = UDim2.new(1, -48, 0, 60)

	Description.BackgroundTransparency = 1

	Description.Text =
		"Your feature hub is ready. More tools and features can be added here."

	Description.TextColor3 = Color3.fromRGB(180, 180, 200)
	Description.TextSize = 15
	Description.Font = Enum.Font.Gotham
	Description.TextWrapped = true
	Description.TextXAlignment = Enum.TextXAlignment.Left
	Description.TextYAlignment = Enum.TextYAlignment.Top

	Description.Parent = MainPage

	--==================================================
	-- DEV PAGE
	--==================================================

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

	DevTitle.Parent = DevPage

	local FeatureCount = Instance.new("TextLabel")

	FeatureCount.Name = "FeatureCount"
	FeatureCount.Position = UDim2.new(0, 24, 0, 75)
	FeatureCount.Size = UDim2.new(1, -48, 0, 30)

	FeatureCount.BackgroundTransparency = 1

	FeatureCount.Text =
		"Loaded Features: " .. tostring(Hub:GetFeatureCount())

	FeatureCount.TextColor3 = BLUE
	FeatureCount.TextSize = 16
	FeatureCount.Font = Enum.Font.GothamMedium
	FeatureCount.TextXAlignment = Enum.TextXAlignment.Left

	FeatureCount.Parent = DevPage

	local DebugText = Instance.new("TextLabel")

	DebugText.Name = "DebugText"
	DebugText.Position = UDim2.new(0, 24, 0, 115)
	DebugText.Size = UDim2.new(1, -48, 0, 80)

	DebugText.BackgroundTransparency = 1

	DebugText.Text =
		"Fairwell Heaven\n"
		.. "Version: " .. tostring(Hub.Version) .. "\n"
		.. "Status: Running"

	DebugText.TextColor3 = Color3.fromRGB(180, 180, 200)
	DebugText.TextSize = 15
	DebugText.Font = Enum.Font.Gotham
	DebugText.TextXAlignment = Enum.TextXAlignment.Left
	DebugText.TextYAlignment = Enum.TextYAlignment.Top

	DebugText.Parent = DevPage

	--==================================================
	-- TAB BUTTON FUNCTION
	--==================================================

	local CurrentTab = nil

	local function CreateTab(Name, Order)

		local Button = Instance.new("TextButton")

		Button.Name = Name .. "Tab"

		Button.Position = UDim2.new(0, 10, 0, 10 + ((Order - 1) * 48))
		Button.Size = UDim2.new(1, -20, 0, 38)

		Button.BackgroundColor3 = BACKGROUND
		Button.BorderSizePixel = 0

		Button.Text = Name:upper()

		Button.TextColor3 = Color3.fromRGB(180, 180, 200)
		Button.TextSize = 14
		Button.Font = Enum.Font.GothamBold

		Button.AutoButtonColor = false

		Button.Parent = TabBar

		local Stroke = Instance.new("UIStroke")

		Stroke.Color = BLUE
		Stroke.Thickness = 1
		Stroke.Transparency = 1

		Stroke.Parent = Button

		return Button, Stroke
	end

	local MainButton, MainStroke = CreateTab("Main", 1)
	local DevButton, DevStroke = CreateTab("Dev", 2)

	--==================================================
	-- TAB SWITCHING
	--==================================================

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

			DevButton.TextColor3 = Color3.fromRGB(180, 180, 200)
			DevStroke.Transparency = 1

		elseif Name == "Dev" then

			MainPage.Visible = false
			DevPage.Visible = true

			MainButton.TextColor3 = Color3.fromRGB(180, 180, 200)
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

	-- Start on Main
	SelectTab("Main")

	--==================================================
	-- STORE REFERENCES
	--==================================================

	self.Gui = Gui
	self.Window = Window

	Hub:Log("Main UI created.")

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