--// FAIRWELL HEAVEN
--// Main UI
--// Version 2.5
--// Adds live DOORS information to Main > Status

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local MainUI = {
	Name = "Main UI",
	Description = "Fairwell Heaven main interface.",
	TargetSize = UDim2.fromScale(0.72, 0.78)
}

local BLUE = Color3.fromRGB(27, 147, 227)
local BACKGROUND = Color3.fromRGB(6, 4, 43)
local PANEL = Color3.fromRGB(10, 8, 55)
local WHITE = Color3.fromRGB(255, 255, 255)
local GREY = Color3.fromRGB(170, 170, 185)

local function MakeLabel(parent, name, text, size, position)
	local Label = Instance.new("TextLabel")

	Label.Name = name
	Label.Position = position
	Label.Size = size
	Label.BackgroundTransparency = 1

	Label.Text = text
	Label.TextColor3 = WHITE
	Label.TextSize = 14
	Label.Font = Enum.Font.Gotham

	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.TextYAlignment = Enum.TextYAlignment.Top

	Label.Parent = parent

	return Label
end

local function MakeSection(parent, title, y)
	local Frame = Instance.new("Frame")

	Frame.Name = title
	Frame.Position = UDim2.new(0, 0, 0, y)
	Frame.Size = UDim2.new(1, -10, 0, 28)

	Frame.BackgroundColor3 = PANEL
	Frame.BorderSizePixel = 0

	Frame.Parent = parent

	local Stroke = Instance.new("UIStroke")
	Stroke.Color = BLUE
	Stroke.Thickness = 1
	Stroke.Parent = Frame

	local Label = Instance.new("TextLabel")

	Label.Size = UDim2.new(1, -12, 1, 0)
	Label.Position = UDim2.new(0, 8, 0, 0)

	Label.BackgroundTransparency = 1
	Label.Text = title

	Label.TextColor3 = BLUE
	Label.TextSize = 14
	Label.Font = Enum.Font.GothamBold

	Label.TextXAlignment = Enum.TextXAlignment.Left

	Label.Parent = Frame

	return Frame
end

function MainUI:CreateStatus(parent)
	local Status = Instance.new("Frame")

	Status.Name = "Status"
	Status.Size = UDim2.new(1, -10, 0, 10)
	Status.BackgroundTransparency = 1
	Status.Parent = parent

	self.Status = Status

	local Y = 0

	--==================================================
	-- GENERAL
	--==================================================

	MakeSection(
		Status,
		"STATUS",
		Y
	)

	Y += 34

	self.GameLabel = MakeLabel(
		Status,
		"Game",
		"Game: Unknown",
		UDim2.new(1, -10, 0, 22),
		UDim2.new(0, 5, 0, Y)
	)

	Y += 22

	self.PlaceLabel = MakeLabel(
		Status,
		"Place",
		"Place ID: Unknown",
		UDim2.new(1, -10, 0, 22),
		UDim2.new(0, 5, 0, Y)
	)

	Y += 30

	--==================================================
	-- DOORS ROOM TRACKER
	--==================================================

	self.DoorsSection = MakeSection(
		Status,
		"DOORS • ROOM TRACKER",
		Y
	)

	Y += 34

	self.CurrentRoomLabel = MakeLabel(
		Status,
		"CurrentRoom",
		"Current Room: --",
		UDim2.new(1, -10, 0, 22),
		UDim2.new(0, 5, 0, Y)
	)

	Y += 22

	self.PreviousRoomLabel = MakeLabel(
		Status,
		"PreviousRoom",
		"Previous Room: --",
		UDim2.new(1, -10, 0, 22),
		UDim2.new(0, 5, 0, Y)
	)

	Y += 22

	self.RoomChangesLabel = MakeLabel(
		Status,
		"RoomChanges",
		"Room Changes: 0",
		UDim2.new(1, -10, 0, 22),
		UDim2.new(0, 5, 0, Y)
	)

	Y += 30

	--==================================================
	-- DOORS DOOR TRACKER
	--==================================================

	self.DoorSection = MakeSection(
		Status,
		"DOORS • DOOR TRACKER",
		Y
	)

	Y += 34

	self.CurrentDoorLabel = MakeLabel(
		Status,
		"CurrentDoor",
		"Current Door: --",
		UDim2.new(1, -10, 0, 22),
		UDim2.new(0, 5, 0, Y)
	)

	Y += 22

	self.DoorDetectedLabel = MakeLabel(
		Status,
		"DoorDetected",
		"Door Detected: NO",
		UDim2.new(1, -10, 0, 22),
		UDim2.new(0, 5, 0, Y)
	)

	Y += 22

	self.LastDoorLabel = MakeLabel(
		Status,
		"LastDoor",
		"Last Door: --",
		UDim2.new(1, -10, 0, 22),
		UDim2.new(0, 5, 0, Y)
	)

	Y += 30

	--==================================================
	-- DOORS PLAYER
	--==================================================

	self.PlayerSection = MakeSection(
		Status,
		"DOORS • PLAYER",
		Y
	)

	Y += 34

	self.PositionLabel = MakeLabel(
		Status,
		"Position",
		"Position: --",
		UDim2.new(1, -10, 0, 22),
		UDim2.new(0, 5, 0, Y)
	)

	Y += 22

	self.DistanceLabel = MakeLabel(
		Status,
		"Distance",
		"Distance to Door: --",
		UDim2.new(1, -10, 0, 22),
		UDim2.new(0, 5, 0, Y)
	)

	Y += 22

	self.RootLabel = MakeLabel(
		Status,
		"Root",
		"HumanoidRootPart: NOT FOUND",
		UDim2.new(1, -10, 0, 22),
		UDim2.new(0, 5, 0, Y)
	)

	Y += 30

	--==================================================
	-- FEATURES
	--==================================================

	self.FeaturesSection = MakeSection(
		Status,
		"FEATURES",
		Y
	)

	Y += 34

	self.LoadedLabel = MakeLabel(
		Status,
		"Loaded",
		"Loaded Features: 0",
		UDim2.new(1, -10, 0, 22),
		UDim2.new(0, 5, 0, Y)
	)

	Y += 22

	self.EnabledLabel = MakeLabel(
		Status,
		"Enabled",
		"Enabled Features: 0",
		UDim2.new(1, -10, 0, 22),
		UDim2.new(0, 5, 0, Y)
	)

	Y += 30

	-- Dynamic height
	Status.Size = UDim2.new(
		1,
		-10,
		0,
		Y
	)
end

function MainUI:UpdateStatus(Hub)
	if not self.Status then
		return
	end

	--==================================================
	-- GENERAL
	--==================================================

	self.GameLabel.Text =
		"Game: "
		.. tostring(Hub.Game.Name)

	self.PlaceLabel.Text =
		"Place ID: "
		.. tostring(game.PlaceId)

	--==================================================
	-- DOORS
	--==================================================

	local IsDOORS =
		Hub:IsDOORS()

	if not IsDOORS then
		self.DoorsSection.Visible = false
		self.CurrentRoomLabel.Visible = false
		self.PreviousRoomLabel.Visible = false
		self.RoomChangesLabel.Visible = false

		self.DoorSection.Visible = false
		self.CurrentDoorLabel.Visible = false
		self.DoorDetectedLabel.Visible = false
		self.LastDoorLabel.Visible = false

		self.PlayerSection.Visible = false
		self.PositionLabel.Visible = false
		self.DistanceLabel.Visible = false
		self.RootLabel.Visible = false
	else
		self.DoorsSection.Visible = true
		self.CurrentRoomLabel.Visible = true
		self.PreviousRoomLabel.Visible = true
		self.RoomChangesLabel.Visible = true

		self.DoorSection.Visible = true
		self.CurrentDoorLabel.Visible = true
		self.DoorDetectedLabel.Visible = true
		self.LastDoorLabel.Visible = true

		self.PlayerSection.Visible = true
		self.PositionLabel.Visible = true
		self.DistanceLabel.Visible = true
		self.RootLabel.Visible = true

		local Doors =
			Hub:GetService("Doors")

		local RoomTracker =
			Hub:GetFeature("DOORS Room Tracker")

		local DoorTracker =
			Hub:GetFeature("DOORS Door Tracker")

		-- ROOM

		local CurrentRoomNumber = "--"

		if RoomTracker
			and RoomTracker.CurrentRoomNumber then

			CurrentRoomNumber =
				tostring(
					RoomTracker.CurrentRoomNumber
				)
		elseif Doors
			and Doors.CurrentRoom then

			CurrentRoomNumber =
				tostring(
					Doors:GetRoomNumber(
						Doors.CurrentRoom
					)
				)
		end

		self.CurrentRoomLabel.Text =
			"Current Room: "
			.. CurrentRoomNumber

		local PreviousRoom =
			self.LastRoomNumber

		if PreviousRoom then
			self.PreviousRoomLabel.Text =
				"Previous Room: "
				.. tostring(PreviousRoom)
		else
			self.PreviousRoomLabel.Text =
				"Previous Room: --"
		end

		if self.LastDisplayedRoom
			and self.LastDisplayedRoom
				~= CurrentRoomNumber then

			self.RoomChangeCount =
				(self.RoomChangeCount or 0) + 1

			self.LastRoomNumber =
				self.LastDisplayedRoom
		end

		self.LastDisplayedRoom =
			CurrentRoomNumber

		self.RoomChangesLabel.Text =
			"Room Changes: "
			.. tostring(
				self.RoomChangeCount or 0
			)

		-- DOOR

		local CurrentDoor = nil

		if DoorTracker then
			CurrentDoor =
				DoorTracker.CurrentDoor
		end

		if not CurrentDoor and Doors then
			CurrentDoor =
				Doors.CurrentDoor
		end

		if CurrentDoor then
			self.CurrentDoorLabel.Text =
				"Current Door: "
				.. CurrentDoor:GetFullName()

			self.DoorDetectedLabel.Text =
				"Door Detected: YES"

			self.LastDoorLabel.Text =
				"Last Door: "
				.. CurrentDoor.Name
		else
			self.CurrentDoorLabel.Text =
				"Current Door: --"

			self.DoorDetectedLabel.Text =
				"Door Detected: NO"
		end

		-- PLAYER

		local Player =
			Players.LocalPlayer

		local Character =
			Player and Player.Character

		local Root =
			Character
			and Character:FindFirstChild(
				"HumanoidRootPart"
			)

		if Root then
			local Position =
				Root.Position

			self.PositionLabel.Text =
				string.format(
					"Position: %.1f, %.1f, %.1f",
					Position.X,
					Position.Y,
					Position.Z
				)

			self.RootLabel.Text =
				"HumanoidRootPart: FOUND"

			if CurrentDoor then
				local DoorPosition

				if CurrentDoor:IsA("BasePart") then
					DoorPosition =
						CurrentDoor.Position
				else
					local Part =
						CurrentDoor:FindFirstChildWhichIsA(
							"BasePart",
							true
						)

					if Part then
						DoorPosition =
							Part.Position
					end
				end

				if DoorPosition then
					local Distance =
						(
							Root.Position
							- DoorPosition
						).Magnitude

					self.DistanceLabel.Text =
						string.format(
							"Distance to Door: %.1f studs",
							Distance
						)
				else
					self.DistanceLabel.Text =
						"Distance to Door: --"
				end
			else
				self.DistanceLabel.Text =
					"Distance to Door: --"
			end
		else
			self.PositionLabel.Text =
				"Position: --"

			self.DistanceLabel.Text =
				"Distance to Door: --"

			self.RootLabel.Text =
				"HumanoidRootPart: NOT FOUND"
		end
	end

	--==================================================
	-- FEATURE COUNTS
	--==================================================

	if type(Hub.GetFeatureCount) == "function" then
		self.LoadedLabel.Text =
			"Loaded Features: "
			.. tostring(
				Hub:GetFeatureCount()
			)
	end

	local EnabledCount = 0

	if Hub.Enabled then
		for _ in pairs(Hub.Enabled) do
			EnabledCount += 1
		end
	end

	self.EnabledLabel.Text =
		"Enabled Features: "
		.. tostring(EnabledCount)
end

--======================================================
-- MAIN UI
--======================================================

function MainUI.Start(self, Hub)
	self.Hub = Hub

	local Player =
		Players.LocalPlayer

	if not Player then
		warn(
			"[Fairwell Heaven] LocalPlayer not found."
		)
		return
	end

	local PlayerGui =
		Player:WaitForChild("PlayerGui")

	local Old =
		PlayerGui:FindFirstChild(
			"FairwellHeaven_Main"
		)

	if Old then
		Old:Destroy()
	end

	local Gui =
		Instance.new("ScreenGui")

	Gui.Name =
		"FairwellHeaven_Main"

	Gui.ResetOnSpawn = false
	Gui.IgnoreGuiInset = true
	Gui.DisplayOrder = 999999

	Gui.Parent =
		PlayerGui

	--==================================================
	-- WINDOW
	--==================================================

	local Window =
		Instance.new("Frame")

	Window.Name = "Window"

	Window.AnchorPoint =
		Vector2.new(0.5, 0.5)

	Window.Position =
		UDim2.fromScale(0.5, 0.5)

	Window.Size =
		self.TargetSize

	Window.BackgroundColor3 =
		BACKGROUND

	Window.BorderSizePixel = 0
	Window.ClipsDescendants = true

	Window.Parent = Gui

	local Outline =
		Instance.new("UIStroke")

	Outline.Color = BLUE
	Outline.Thickness = 3
	Outline.Parent = Window

	--==================================================
	-- TITLE BAR
	--==================================================

	local TitleBar =
		Instance.new("Frame")

	TitleBar.Name =
		"TitleBar"

	TitleBar.Size =
		UDim2.new(1, 0, 0, 48)

	TitleBar.BackgroundColor3 =
		PANEL

	TitleBar.BorderSizePixel = 0
	TitleBar.ZIndex = 20

	TitleBar.Parent =
		Window

	local Title =
		Instance.new("TextLabel")

	Title.Size =
		UDim2.new(1, -90, 0, 25)

	Title.Position =
		UDim2.new(0, 12, 0, 5)

	Title.BackgroundTransparency = 1

	Title.Text =
		"HACKER HEAVEN"

	Title.TextColor3 =
		WHITE

	Title.TextSize = 17
	Title.Font = Enum.Font.GothamBold

	Title.TextXAlignment =
		Enum.TextXAlignment.Left

	Title.ZIndex = 22

	Title.Parent =
		TitleBar

	local Version =
		Instance.new("TextLabel")

	Version.Size =
		UDim2.new(1, -90, 0, 16)

	Version.Position =
		UDim2.new(0, 12, 0, 28)

	Version.BackgroundTransparency = 1

	Version.Text =
		"FAIRWELL HEAVEN • v2.5"

	Version.TextColor3 =
		GREY

	Version.TextSize = 10
	Version.Font = Enum.Font.Gotham

	Version.TextXAlignment =
		Enum.TextXAlignment.Left

	Version.ZIndex = 22

	Version.Parent =
		TitleBar

	--==================================================
	-- COLLAPSE BUTTON
	--==================================================

	local ToggleButton =
		Instance.new("TextButton")

	ToggleButton.Name =
		"Collapse"

	ToggleButton.Size =
		UDim2.fromOffset(38, 32)

	ToggleButton.Position =
		UDim2.new(1, -46, 0, 8)

	ToggleButton.BackgroundTransparency = 1

	ToggleButton.Text = "−"

	ToggleButton.TextColor3 =
		WHITE

	ToggleButton.TextSize = 25
	ToggleButton.Font = Enum.Font.GothamBold

	ToggleButton.ZIndex = 30

	ToggleButton.Parent =
		TitleBar

	--==================================================
	-- DRAG HANDLE
	--==================================================

	local DragHandle =
		Instance.new("TextButton")

	DragHandle.Name =
		"DragHandle"

	DragHandle.Size =
		UDim2.new(1, -55, 1, 0)

	DragHandle.BackgroundTransparency = 1
	DragHandle.Text = ""

	DragHandle.ZIndex = 21

	DragHandle.Parent =
		TitleBar

	--==================================================
	-- TABS
	--==================================================

	local Tabs =
		Instance.new("Frame")

	Tabs.Name = "Tabs"

	Tabs.Position =
		UDim2.new(0, 0, 0, 48)

	Tabs.Size =
		UDim2.new(1, 0, 0, 38)

	Tabs.BackgroundColor3 =
		BACKGROUND

	Tabs.BorderSizePixel = 0
	Tabs.ZIndex = 15

	Tabs.Parent =
		Window

	local MainTab =
		Instance.new("TextButton")

	MainTab.Size =
		UDim2.new(0.5, 0, 1, 0)

	MainTab.BackgroundTransparency = 1

	MainTab.Text = "MAIN"

	MainTab.TextColor3 =
		BLUE

	MainTab.TextSize = 13
	MainTab.Font = Enum.Font.GothamBold

	MainTab.ZIndex = 16

	MainTab.Parent =
		Tabs

	local DevTab =
		Instance.new("TextButton")

	DevTab.Position =
		UDim2.new(0.5, 0, 0, 0)

	DevTab.Size =
		UDim2.new(0.5, 0, 1, 0)

	DevTab.BackgroundTransparency = 1

	DevTab.Text = "DEV"

	DevTab.TextColor3 =
		GREY

	DevTab.TextSize = 13
	DevTab.Font = Enum.Font.GothamBold

	DevTab.ZIndex = 16

	DevTab.Parent =
		Tabs

	--==================================================
	-- CONTENT
	--==================================================

	local Content =
		Instance.new("Frame")

	Content.Name =
		"Content"

	Content.Position =
		UDim2.new(0, 0, 0, 86)

	Content.Size =
		UDim2.new(1, 0, 1, -86)

	Content.BackgroundTransparency = 1

	Content.Parent =
		Window

	local MainScroll =
		Instance.new("ScrollingFrame")

	MainScroll.Name =
		"MainScroll"

	MainScroll.Position =
		UDim2.new(0, 8, 0, 8)

	MainScroll.Size =
		UDim2.new(1, -16, 1, -16)

	MainScroll.BackgroundTransparency = 1

	MainScroll.BorderSizePixel = 0

	MainScroll.ScrollBarThickness = 4
	MainScroll.CanvasSize =
		UDim2.new(0, 0, 0, 0)

	MainScroll.AutomaticCanvasSize =
		Enum.AutomaticSize.Y

	MainScroll.Parent =
		Content

	self:CreateStatus(MainScroll)

	--==================================================
	-- DEV PAGE
	--==================================================

	local DevScroll =
		Instance.new("ScrollingFrame")

	DevScroll.Name =
		"DevScroll"

	DevScroll.Position =
		UDim2.new(0, 8, 0, 8)

	DevScroll.Size =
		UDim2.new(1, -16, 1, -16)

	DevScroll.BackgroundTransparency = 1
	DevScroll.BorderSizePixel = 0

	DevScroll.ScrollBarThickness = 4

	DevScroll.AutomaticCanvasSize =
		Enum.AutomaticSize.Y

	DevScroll.Visible = false

	DevScroll.Parent =
		Content

	local DevTitle =
		MakeLabel(
			DevScroll,
			"DevTitle",
			"DEVELOPMENT WORKSPACE",
			UDim2.new(1, -10, 0, 30),
			UDim2.new(0, 5, 0, 5)
		)

	DevTitle.TextColor3 = BLUE
	DevTitle.Font = Enum.Font.GothamBold
	DevTitle.TextSize = 16

	local DevInfo =
		MakeLabel(
			DevScroll,
			"DevInfo",
			"Development tools and future feature testing will appear here.",
			UDim2.new(1, -10, 0, 60),
			UDim2.new(0, 5, 0, 42)
		)

	DevInfo.TextWrapped = true

	--==================================================
	-- TAB SWITCHING
	--==================================================

	MainTab.MouseButton1Click:Connect(function()
		MainScroll.Visible = true
		DevScroll.Visible = false

		MainTab.TextColor3 = BLUE
		DevTab.TextColor3 = GREY
	end)

	DevTab.MouseButton1Click:Connect(function()
		MainScroll.Visible = false
		DevScroll.Visible = true

		MainTab.TextColor3 = GREY
		DevTab.TextColor3 = BLUE
	end)

	--==================================================
	-- DRAGGING
	--==================================================

	local Dragging = false
	local DragStart
	local StartPosition

	DragHandle.InputBegan:Connect(function(Input)
		if self.Collapsed then
			return
		end

		if Input.UserInputType ==
			Enum.UserInputType.MouseButton1
			or Input.UserInputType ==
			Enum.UserInputType.Touch then

			Dragging = true
			DragStart = Input.Position
			StartPosition = Window.Position
		end
	end)

	DragHandle.InputEnded:Connect(function(Input)
		if Input.UserInputType ==
			Enum.UserInputType.MouseButton1
			or Input.UserInputType ==
			Enum.UserInputType.Touch then

			Dragging = false

			local Settings = Hub:GetService("Settings")

			if Settings then

				local Position = Window.Position

				Settings:Set(
					"Window",
					{
						Position = {
							XScale = Position.X.Scale,
							XOffset = Position.X.Offset,
							YScale = Position.Y.Scale,
							YOffset = Position.Y.Offset
						},
						Collapsed = self.Collapsed == true
					},
					true
				)

			end

		end
	end)

	UserInputService.InputChanged:Connect(function(Input)
		if not Dragging then
			return
		end

		if Input.UserInputType ~=
			Enum.UserInputType.MouseMovement
			and Input.UserInputType ~=
			Enum.UserInputType.Touch then
			return
		end

		local Delta =
			Input.Position - DragStart

		Window.Position =
			UDim2.new(
				StartPosition.X.Scale,
				StartPosition.X.Offset + Delta.X,
				StartPosition.Y.Scale,
				StartPosition.Y.Offset + Delta.Y
			)
	end)

	--==================================================
	-- COLLAPSE
	--==================================================

	self.Collapsed = false
	self.ExpandedSize = self.TargetSize
	self.ExpandedPosition =
		UDim2.fromScale(0.5, 0.5)

	ToggleButton.MouseButton1Click:Connect(function()
		if self.Collapsed then
			self.Collapsed = false

			ToggleButton.Text = "−"

			local Tween =
				TweenService:Create(
					Window,
					TweenInfo.new(
						0.35,
						Enum.EasingStyle.Quint,
						Enum.EasingDirection.Out
					),
					{
						Size =
							self.ExpandedSize,

						Position =
							self.ExpandedPosition
					}
				)

			Tween:Play()
		else
			self.ExpandedSize =
				Window.Size

			self.ExpandedPosition =
				Window.Position

			self.Collapsed = true

			ToggleButton.Text = "+"

			local Tween =
				TweenService:Create(
					Window,
					TweenInfo.new(
						0.35,
						Enum.EasingStyle.Quint,
						Enum.EasingDirection.Out
					),
					{
						Size =
							UDim2.fromOffset(
								270,
								48
							),

						Position =
							UDim2.new(
								0.5,
								0,
								1,
								-12
							)
					}
				)

			Tween:Play()

			local Settings = Hub:GetService("Settings")

			if Settings then
				local Position = Window.Position

				Settings:Set(
					"Window",
					{
						Position = {
							XScale = Position.X.Scale,
							XOffset = Position.X.Offset,
							YScale = Position.Y.Scale,
							YOffset = Position.Y.Offset
						},
						Collapsed = self.Collapsed == true
					},
					true
				)
			end
		end
	end)

	--==================================================
	-- LIVE STATUS
	--==================================================

	self.StatusConnection =
		RunService.Heartbeat:Connect(function()
			if not Gui.Parent then
				return
			end

			if self.StatusTimer
				and os.clock() - self.StatusTimer < 0.25 then
				return
			end

			self.StatusTimer = os.clock()

			self:UpdateStatus(Hub)
		end)

	self.Gui = Gui
	self.Window = Window

	--------------------------------------------------
	-- RESTORE PERSISTENT WINDOW SETTINGS
	--------------------------------------------------

	local Settings = Hub:GetService("Settings")

	if Settings then

		local WindowSettings =
			Settings:Get("Window", {})

		local SavedPosition =
			WindowSettings.Position

		if type(SavedPosition) == "table" then

			Window.Position =
				UDim2.new(
					tonumber(SavedPosition.XScale) or 0.5,
					tonumber(SavedPosition.XOffset) or 0,
					tonumber(SavedPosition.YScale) or 0.5,
					tonumber(SavedPosition.YOffset) or 0
				)

			self.ExpandedPosition =
				Window.Position

		end

		if WindowSettings.Collapsed == true then

			self.Collapsed = true
			ToggleButton.Text = "+"

			Window.Size =
				UDim2.fromOffset(
					270,
					48
				)

			Window.Position =
				UDim2.new(
					0.5,
					0,
					1,
					-12
				)

		end

	end

	Hub:Log(
		"Main UI v2.5 initialized."
	)
end

function MainUI:Reveal()
	if not self.Gui or not self.Gui.Parent then
		return
	end

	self.Gui.Enabled = true
end

function MainUI.Stop(self)

	local Hub = self.Hub

	if Hub then
		local Settings = Hub:GetService("Settings")

		if Settings then
			local Position =
				self.Window
				and self.Window.Position

			if Position then
				Settings:Set(
					"Window",
					{
						Position = {
							XScale = Position.X.Scale,
							XOffset = Position.X.Offset,
							YScale = Position.Y.Scale,
							YOffset = Position.Y.Offset
						},
						Collapsed = self.Collapsed == true
					},
					true
				)
			end
		end
	end

	if self.StatusConnection then
		self.StatusConnection:Disconnect()
		self.StatusConnection = nil
	end

	if self.Gui then
		self.Gui:Destroy()
		self.Gui = nil
	end

	self.Status = nil
end

return MainUI