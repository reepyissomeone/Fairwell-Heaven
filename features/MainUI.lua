--// FAIRWELL HEAVEN
--// Main UI
--// Version 2.3
--// Draggable + Scrollable + Dynamic Status

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local MainUI = {
	Name = "Main UI",
	Description = "Fairwell Heaven main interface.",

	TargetSize = UDim2.fromScale(0.78, 0.68)
}

local BLUE = Color3.fromRGB(27, 147, 227)
local BACKGROUND = Color3.fromRGB(6, 4, 43)
local PANEL = Color3.fromRGB(8, 6, 55)
local WHITE = Color3.fromRGB(255, 255, 255)
local GRAY = Color3.fromRGB(170, 175, 190)

local function Create(className, properties, parent)
	local object = Instance.new(className)

	for property, value in pairs(properties) do
		object[property] = value
	end

	object.Parent = parent

	return object
end

----------------------------------------------------------------
-- DRAGGING
----------------------------------------------------------------

local function MakeDraggable(Window, DragHandle)

	local Dragging = false
	local DragStart = nil
	local StartPosition = nil
	local DragInput = nil

	local function Update(input)

		if not Dragging then
			return
		end

		local Delta = input.Position - DragStart

		Window.Position = UDim2.new(
			StartPosition.X.Scale,
			StartPosition.X.Offset + Delta.X,
			StartPosition.Y.Scale,
			StartPosition.Y.Offset + Delta.Y
		)
	end

	DragHandle.InputBegan:Connect(function(input)

		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then

			Dragging = true
			DragStart = input.Position
			StartPosition = Window.Position

			input.Changed:Connect(function()

				if input.UserInputState == Enum.UserInputState.End then
					Dragging = false
				end

			end)
		end
	end)

	DragHandle.InputChanged:Connect(function(input)

		if input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch then

			DragInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)

		if input == DragInput then
			Update(input)
		end

	end)
end

----------------------------------------------------------------
-- SCROLLING PAGE
----------------------------------------------------------------

local function CreateScrollPage(Gui, Name)

	local Scroll = Create("ScrollingFrame", {

		Name = Name,

		Position = UDim2.fromScale(0, 0),
		Size = UDim2.fromScale(1, 1),

		BackgroundTransparency = 1,
		BorderSizePixel = 0,

		ScrollBarThickness = 6,
		ScrollBarImageColor3 = BLUE,
		ScrollBarImageTransparency = 0.15,

		ScrollingDirection = Enum.ScrollingDirection.Y,

		CanvasSize = UDim2.new(0, 0, 0, 900),

		AutomaticCanvasSize = Enum.AutomaticSize.None,

		ScrollingEnabled = true,
		Active = true,

		ElasticBehavior = Enum.ElasticBehavior.Always,

		ClipsDescendants = true,

		Visible = false

	}, Gui)

	return Scroll
end

----------------------------------------------------------------
-- START
----------------------------------------------------------------

function MainUI.Start(self, Hub)

	local Player = Players.LocalPlayer

	if not Player then
		warn("[Fairwell Heaven] LocalPlayer not found.")
		return
	end

	local PlayerGui = Player:WaitForChild("PlayerGui")

	-- Loading Screen creates this.
	local Gui = PlayerGui:FindFirstChild("FairwellHeaven_Main")

	if not Gui then
		warn("[Fairwell Heaven] Main GUI was not found.")
		return
	end

	local Window = Gui:FindFirstChild("Window")

	if not Window then
		warn("[Fairwell Heaven] Loading window was not found.")
		return
	end

	self.Gui = Gui
	self.Window = Window

	----------------------------------------------------------------
	-- TITLE BAR
	----------------------------------------------------------------

	local TitleBar = Create("Frame", {

		Name = "TitleBar",

		Position = UDim2.fromScale(0, 0),
		Size = UDim2.new(1, 0, 0, 48),

		BackgroundColor3 = PANEL,
		BorderSizePixel = 0,

		ZIndex = 10

	}, Window)

	-- Dedicated drag handle.
	-- This makes mobile dragging much more reliable.
	local DragHandle = Create("TextButton", {

		Name = "DragHandle",

		Position = UDim2.fromScale(0, 0),
		Size = UDim2.fromScale(1, 1),

		BackgroundTransparency = 1,
		BorderSizePixel = 0,

		Text = "",

		AutoButtonColor = false,

		Active = true,

		ZIndex = 20

	}, TitleBar)

	local Title = Create("TextLabel", {

		Name = "Title",

		Position = UDim2.new(0, 14, 0, 4),
		Size = UDim2.new(0.6, 0, 0, 23),

		BackgroundTransparency = 1,

		Text = "FAIRWELL HEAVEN",

		TextColor3 = WHITE,

		TextSize = 18,
		Font = Enum.Font.GothamBold,

		TextXAlignment = Enum.TextXAlignment.Left,

		ZIndex = 15

	}, TitleBar)

	local Version = Create("TextLabel", {

		Name = "Version",

		Position = UDim2.new(0, 14, 0, 27),
		Size = UDim2.new(0.6, 0, 0, 15),

		BackgroundTransparency = 1,

		Text = "v2.3",

		TextColor3 = BLUE,

		TextSize = 11,
		Font = Enum.Font.GothamBold,

		TextXAlignment = Enum.TextXAlignment.Left,

		ZIndex = 15

	}, TitleBar)

	----------------------------------------------------------------
	-- TABS
	----------------------------------------------------------------

	local TabBar = Create("Frame", {

		Name = "TabBar",

		Position = UDim2.new(0, 0, 0, 48),
		Size = UDim2.new(1, 0, 0, 40),

		BackgroundColor3 = BACKGROUND,
		BorderSizePixel = 0,

		ZIndex = 9

	}, Window)

	local MainTab = Create("TextButton", {

		Name = "MainTab",

		Position = UDim2.new(0, 10, 0, 6),
		Size = UDim2.new(0, 100, 0, 28),

		BackgroundColor3 = BLUE,
		BorderSizePixel = 0,

		Text = "MAIN",

		TextColor3 = WHITE,
		TextSize = 13,

		Font = Enum.Font.GothamBold,

		AutoButtonColor = false,

		ZIndex = 10

	}, TabBar)

	local DevTab = Create("TextButton", {

		Name = "DevTab",

		Position = UDim2.new(0, 116, 0, 6),
		Size = UDim2.new(0, 100, 0, 28),

		BackgroundColor3 = PANEL,
		BorderSizePixel = 0,

		Text = "DEV",

		TextColor3 = GRAY,
		TextSize = 13,

		Font = Enum.Font.GothamBold,

		AutoButtonColor = false,

		ZIndex = 10

	}, TabBar)

	----------------------------------------------------------------
	-- CONTENT CONTAINER
	----------------------------------------------------------------

	local Content = Create("Frame", {

		Name = "Content",

		Position = UDim2.new(0, 0, 0, 88),
		Size = UDim2.new(1, 0, 1, -88),

		BackgroundTransparency = 1,

		ClipsDescendants = true

	}, Window)

	----------------------------------------------------------------
	-- MAIN SCROLL
	----------------------------------------------------------------

	local MainScroll = CreateScrollPage(
		Content,
		"MainScroll"
	)

	MainScroll.Visible = true

	----------------------------------------------------------------
	-- DEV SCROLL
	----------------------------------------------------------------

	local DevScroll = CreateScrollPage(
		Content,
		"DevScroll"
	)

	----------------------------------------------------------------
	-- MAIN PAGE
	----------------------------------------------------------------

	local MainPage = Create("Frame", {

		Name = "MainPage",

		Position = UDim2.new(0, 12, 0, 12),
		Size = UDim2.new(1, -30, 0, 850),

		BackgroundTransparency = 1

	}, MainScroll)

	----------------------------------------------------------------
	-- WELCOME
	----------------------------------------------------------------

	local Welcome = Create("TextLabel", {

		Name = "Welcome",

		Position = UDim2.new(0, 0, 0, 0),
		Size = UDim2.new(1, 0, 0, 45),

		BackgroundTransparency = 1,

		Text = "WELCOME TO FAIRWELL HEAVEN",

		TextColor3 = WHITE,

		TextSize = 24,
		Font = Enum.Font.GothamBold,

		TextXAlignment = Enum.TextXAlignment.Left

	}, MainPage)

	local Description = Create("TextLabel", {

		Name = "Description",

		Position = UDim2.new(0, 0, 0, 48),
		Size = UDim2.new(1, 0, 0, 45),

		BackgroundTransparency = 1,

		Text = "Your modular Roblox feature hub.",

		TextColor3 = GRAY,

		TextSize = 14,
		Font = Enum.Font.Gotham,

		TextXAlignment = Enum.TextXAlignment.Left

	}, MainPage)

	----------------------------------------------------------------
	-- STATUS PANEL
	----------------------------------------------------------------

	local StatusPanel = Create("Frame", {

		Name = "StatusPanel",

		Position = UDim2.new(0, 0, 0, 110),
		Size = UDim2.new(1, 0, 0, 270),

		BackgroundColor3 = PANEL,
		BorderSizePixel = 0

	}, MainPage)

	local StatusStroke = Create("UIStroke", {

		Color = BLUE,
		Thickness = 2

	}, StatusPanel)

	local StatusTitle = Create("TextLabel", {

		Name = "StatusTitle",

		Position = UDim2.new(0, 14, 0, 12),
		Size = UDim2.new(1, -28, 0, 30),

		BackgroundTransparency = 1,

		Text = "SYSTEM STATUS",

		TextColor3 = WHITE,

		TextSize = 18,
		Font = Enum.Font.GothamBold,

		TextXAlignment = Enum.TextXAlignment.Left

	}, StatusPanel)

	local Status = {}

	local StatusNames = {
		"Game",
		"Place ID",
		"Current Room",
		"Current Door",
		"Position",
		"Loaded Features",
		"Enabled Features"
	}

	for Index, Name in ipairs(StatusNames) do

		local Row = Create("Frame", {

			Name = Name .. "Row",

			Position = UDim2.new(
				0,
				14,
				0,
				45 + ((Index - 1) * 30)
			),

			Size = UDim2.new(1, -28, 0, 25),

			BackgroundTransparency = 1

		}, StatusPanel)

		local Label = Create("TextLabel", {

			Position = UDim2.new(0, 0, 0, 0),
			Size = UDim2.new(0.38, 0, 1, 0),

			BackgroundTransparency = 1,

			Text = Name,

			TextColor3 = GRAY,

			TextSize = 13,
			Font = Enum.Font.GothamBold,

			TextXAlignment = Enum.TextXAlignment.Left

		}, Row)

		local Value = Create("TextLabel", {

			Position = UDim2.new(0.38, 0, 0, 0),
			Size = UDim2.new(0.62, 0, 1, 0),

			BackgroundTransparency = 1,

			Text = "Loading...",

			TextColor3 = WHITE,

			TextSize = 13,
			Font = Enum.Font.Gotham,

			TextXAlignment = Enum.TextXAlignment.Right,

			TextTruncate = Enum.TextTruncate.AtEnd

		}, Row)

		Status[Name] = Value
	end

	----------------------------------------------------------------
	-- FEATURES PANEL
	----------------------------------------------------------------

	local FeaturePanel = Create("Frame", {

		Name = "FeaturePanel",

		Position = UDim2.new(0, 0, 0, 400),
		Size = UDim2.new(1, 0, 0, 300),

		BackgroundColor3 = PANEL,
		BorderSizePixel = 0

	}, MainPage)

	local FeatureStroke = Create("UIStroke", {

		Color = BLUE,
		Thickness = 2

	}, FeaturePanel)

	local FeatureTitle = Create("TextLabel", {

		Position = UDim2.new(0, 14, 0, 12),
		Size = UDim2.new(1, -28, 0, 30),

		BackgroundTransparency = 1,

		Text = "FEATURES",

		TextColor3 = WHITE,

		TextSize = 18,
		Font = Enum.Font.GothamBold,

		TextXAlignment = Enum.TextXAlignment.Left

	}, FeaturePanel)

	local FeatureList = Create("TextLabel", {

		Position = UDim2.new(0, 14, 0, 50),
		Size = UDim2.new(1, -28, 0, 230),

		BackgroundTransparency = 1,

		Text = "Loading features...",

		TextColor3 = GRAY,

		TextSize = 14,
		Font = Enum.Font.Gotham,

		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,

		TextWrapped = true

	}, FeaturePanel)

	----------------------------------------------------------------
	-- DEV PAGE
	----------------------------------------------------------------

	local DevPage = Create("Frame", {

		Name = "DevPage",

		Position = UDim2.new(0, 12, 0, 12),
		Size = UDim2.new(1, -30, 0, 850),

		BackgroundTransparency = 1

	}, DevScroll)

	local DevTitle = Create("TextLabel", {

		Position = UDim2.new(0, 0, 0, 0),
		Size = UDim2.new(1, 0, 0, 45),

		BackgroundTransparency = 1,

		Text = "DEVELOPMENT",

		TextColor3 = WHITE,

		TextSize = 24,
		Font = Enum.Font.GothamBold,

		TextXAlignment = Enum.TextXAlignment.Left

	}, DevPage)

	local DevDescription = Create("TextLabel", {

		Position = UDim2.new(0, 0, 0, 48),
		Size = UDim2.new(1, 0, 0, 45),

		BackgroundTransparency = 1,

		Text = "Development tools and feature testing.",

		TextColor3 = GRAY,

		TextSize = 14,
		Font = Enum.Font.Gotham,

		TextXAlignment = Enum.TextXAlignment.Left

	}, DevPage)

	local DevPanel = Create("Frame", {

		Position = UDim2.new(0, 0, 0, 110),
		Size = UDim2.new(1, 0, 0, 400),

		BackgroundColor3 = PANEL,
		BorderSizePixel = 0

	}, DevPage)

	Create("UIStroke", {

		Color = BLUE,
		Thickness = 2

	}, DevPanel)

	local DevText = Create("TextLabel", {

		Position = UDim2.new(0, 16, 0, 16),
		Size = UDim2.new(1, -32, 0, 350),

		BackgroundTransparency = 1,

		Text =
			"DEVELOPER WORKSPACE\n\n"
			.. "This area is reserved for building and testing "
			.. "Fairwell Heaven features.\n\n"
			.. "New features can be added without replacing "
			.. "the main loader.",

		TextColor3 = GRAY,

		TextSize = 15,
		Font = Enum.Font.Gotham,

		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,

		TextWrapped = true

	}, DevPanel)

	----------------------------------------------------------------
	-- TAB SYSTEM
	----------------------------------------------------------------

	local function ShowMain()

		MainScroll.Visible = true
		DevScroll.Visible = false

		MainTab.BackgroundColor3 = BLUE
		MainTab.TextColor3 = WHITE

		DevTab.BackgroundColor3 = PANEL
		DevTab.TextColor3 = GRAY

	end

	local function ShowDev()

		MainScroll.Visible = false
		DevScroll.Visible = true

		MainTab.BackgroundColor3 = PANEL
		MainTab.TextColor3 = GRAY

		DevTab.BackgroundColor3 = BLUE
		DevTab.TextColor3 = WHITE

	end

	MainTab.MouseButton1Click:Connect(ShowMain)
	DevTab.MouseButton1Click:Connect(ShowDev)

	----------------------------------------------------------------
	-- FEATURE LIST
	----------------------------------------------------------------

	local function UpdateFeatureList()

		local Lines = {}

		for Name, Feature in pairs(Hub.Features) do

			local State

			if Hub:IsEnabled(Name) then
				State = "[ ENABLED ]"
			else
				State = "[ DISABLED ]"
			end

			table.insert(
				Lines,
				State .. "  " .. tostring(Name)
			)
		end

		table.sort(Lines)

		if #Lines == 0 then
			FeatureList.Text = "No features loaded."
		else
			FeatureList.Text = table.concat(Lines, "\n")
		end

	end

	----------------------------------------------------------------
	-- DYNAMIC STATUS
	----------------------------------------------------------------

	local function GetCurrentRoom()

		local Workspace = game:GetService("Workspace")
		local CurrentRooms = Workspace:FindFirstChild("CurrentRooms")

		if not CurrentRooms then
			return "N/A"
		end

		local Highest = nil

		for _, Room in ipairs(CurrentRooms:GetChildren()) do

			local Number = tonumber(Room.Name)

			if Number then

				if not Highest or Number > Highest then
					Highest = Number
				end

			end
		end

		if Highest then
			return tostring(Highest)
		end

		return "N/A"
	end

	local function UpdateStatus()

		local PlaceId = game.PlaceId

		local GameName = "Unknown"

		pcall(function()
			GameName = game:GetService("MarketplaceService")
				:GetProductInfo(PlaceId)
				.Name
		end)

		Status["Game"].Text = GameName
		Status["Place ID"].Text = tostring(PlaceId)

		-- DOORS room detection.
		local IsDoors = workspace:FindFirstChild("CurrentRooms") ~= nil

		if IsDoors then

			local Room = GetCurrentRoom()

			Status["Current Room"].Text = Room

			-- Keep this truthful rather than guessing a door number.
			Status["Current Door"].Text = Room ~= "N/A"
				and "Room " .. Room
				or "N/A"

		else

			Status["Current Room"].Text = "N/A"
			Status["Current Door"].Text = "N/A"

		end

		local Character = Player.Character
		local Root = Character
			and Character:FindFirstChild("HumanoidRootPart")

		if Root then

			local Position = Root.Position

			Status["Position"].Text = string.format(
				"%.1f, %.1f, %.1f",
				Position.X,
				Position.Y,
				Position.Z
			)

		else

			Status["Position"].Text = "N/A"

		end

		local Loaded = 0
		local Enabled = 0

		for _ in pairs(Hub.Features) do
			Loaded += 1
		end

		for _ in pairs(Hub.Enabled) do
			Enabled += 1
		end

		Status["Loaded Features"].Text = tostring(Loaded)
		Status["Enabled Features"].Text = tostring(Enabled)

	end

	----------------------------------------------------------------
	-- DRAGGING
	----------------------------------------------------------------

	MakeDraggable(
		Window,
		DragHandle
	)

	----------------------------------------------------------------
	-- STORE REFERENCES
	----------------------------------------------------------------

	self.MainScroll = MainScroll
	self.DevScroll = DevScroll

	self.MainPage = MainPage
	self.DevPage = DevPage

	self.Status = Status

	self.UpdateStatus = UpdateStatus

	self.UpdateFeatureList = UpdateFeatureList

	self.ShowMain = ShowMain
	self.ShowDev = ShowDev

	----------------------------------------------------------------
	-- LIVE UPDATE
	----------------------------------------------------------------

	self.StatusConnection = RunService.RenderStepped:Connect(
		function()

			if not self.Gui
				or not self.Gui.Parent then

				return
			end

			UpdateStatus()

		end
	)

	UpdateFeatureList()
	UpdateStatus()

	Hub:Log("Main UI created.")

end

----------------------------------------------------------------
-- REVEAL
----------------------------------------------------------------

function MainUI:Reveal()

	if not self.Window then
		return
	end

	if self.Revealed then
		return
	end

	self.Revealed = true

	local MainScroll = self.MainScroll
	local DevScroll = self.DevScroll

	if MainScroll then
		MainScroll.Visible = true
	end

	if DevScroll then
		DevScroll.Visible = false
	end

	-- Start slightly transparent.
	if MainScroll then
		MainScroll.Visible = true
	end

	if DevScroll then
		DevScroll.Visible = false
	end

end

----------------------------------------------------------------
-- STOP
----------------------------------------------------------------

function MainUI.Stop(self, Hub)

	self.Revealed = false

	if self.StatusConnection then

		self.StatusConnection:Disconnect()
		self.StatusConnection = nil

	end

end

return MainUI