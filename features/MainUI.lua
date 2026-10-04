--// FAIRWELL HEAVEN
--// Main UI
--// Version 3.9
--// Adds live DOORS information to Main > Status

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ContentProvider = game:GetService("ContentProvider")

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
		UDim2.new(1, -190, 0, 25)

	Title.Position =
		UDim2.new(0, 100, 0, 5)

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
		UDim2.new(1, -190, 0, 16)

	Version.Position =
		UDim2.new(0, 100, 0, 28)

	Version.BackgroundTransparency = 1

	Version.Text =
		"FAIRWELL HEAVEN • v3.9"

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
	-- UNLOAD BUTTON
	--==================================================

	local UnloadButton = Instance.new("TextButton")
	UnloadButton.Name = "Unload"
	UnloadButton.Size = UDim2.fromOffset(38, 32)
	UnloadButton.Position = UDim2.new(1, -88, 0, 8)
	UnloadButton.BackgroundColor3 = Color3.fromRGB(100, 25, 45)
	UnloadButton.BackgroundTransparency = 0.15
	UnloadButton.BorderSizePixel = 0
	UnloadButton.Text = "×"
	UnloadButton.TextColor3 = WHITE
	UnloadButton.TextSize = 20
	UnloadButton.Font = Enum.Font.GothamBold
	UnloadButton.ZIndex = 30
	UnloadButton.Parent = TitleBar

	local UnloadCorner = Instance.new("UICorner")
	UnloadCorner.CornerRadius = UDim.new(0, 6)
	UnloadCorner.Parent = UnloadButton

	local UnloadStroke = Instance.new("UIStroke")
	UnloadStroke.Color = Color3.fromRGB(220, 70, 95)
	UnloadStroke.Thickness = 1
	UnloadStroke.Parent = UnloadButton

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

	UnloadButton.MouseButton1Click:Connect(function()
		if self.Hub and type(self.Hub.Shutdown) == "function" then
			self.Hub:Notify(
				"FAIRWELL HEAVEN",
				"Unloading hub...",
				"WARNING",
				1.5
			)
			task.delay(0.15, function()
				if self.Hub and type(self.Hub.Shutdown) == "function" then
					self.Hub:Shutdown()
				end
			end)
		end
	end)

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
		UDim2.new(1/4, 0, 1, 0)

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
		UDim2.new(1/4, 0, 0, 0)

	DevTab.Size =
		UDim2.new(1/4, 0, 1, 0)

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
	-- FAIRWELL CHAT TAB
	--==================================================

	local ChatTab = Instance.new("TextButton")
	ChatTab.Name = "FairwellChatTab"
	ChatTab.Position = UDim2.new(1/2, 0, 0, 0)
	ChatTab.Size = UDim2.new(1/4, 0, 1, 0)
	ChatTab.BackgroundTransparency = 1
	ChatTab.Text = "FAIRWELL CHAT"
	ChatTab.TextColor3 = GREY
	ChatTab.TextSize = 11
	ChatTab.Font = Enum.Font.GothamBold
	ChatTab.ZIndex = 16
	ChatTab.Parent = Tabs

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
	-- FAIRWELL CHAT PAGE
	--==================================================

	local ChatScroll = Instance.new("ScrollingFrame")
	ChatScroll.Name = "FairwellChat"
	ChatScroll.Position = UDim2.new(0, 8, 0, 8)
	ChatScroll.Size = UDim2.new(1, -16, 1, -16)
	ChatScroll.BackgroundTransparency = 1
	ChatScroll.BorderSizePixel = 0
	ChatScroll.ScrollBarThickness = 4
	ChatScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	ChatScroll.Visible = false
	ChatScroll.Parent = Content

	local ChatTitle = MakeLabel(ChatScroll, "ChatTitle", "FAIRWELL CHAT", UDim2.new(1, -10, 0, 30), UDim2.new(0, 5, 0, 5))
	ChatTitle.TextColor3 = BLUE
	ChatTitle.Font = Enum.Font.GothamBold
	ChatTitle.TextSize = 16
	ChatTitle.ZIndex = 5

	local ChatInfo = MakeLabel(ChatScroll, "ChatInfo", "Talk to Fairwelladmi. He's right here.", UDim2.new(1, -10, 0, 24), UDim2.new(0, 5, 0, 38))
	ChatInfo.TextColor3 = GREY
	ChatInfo.TextSize = 10
	ChatInfo.Text = "Live avatar • Fairwelladmi • Chat ready"

	local ChatStage = Instance.new("Frame")
	ChatStage.Name = "FairwellStage"
	ChatStage.Position = UDim2.new(0, 5, 0, 68)
	ChatStage.Size = UDim2.new(1, -10, 0, 276)
	ChatStage.ClipsDescendants = true
	ChatStage.BackgroundColor3 = Color3.fromRGB(4, 3, 30)
	ChatStage.BorderSizePixel = 0
	ChatStage.Parent = ChatScroll

	local StageCorner = Instance.new("UICorner")
	StageCorner.CornerRadius = UDim.new(0, 9)
	StageCorner.Parent = ChatStage

	local StageStroke = Instance.new("UIStroke")
	StageStroke.Color = BLUE
	StageStroke.Transparency = 0.2
	StageStroke.Parent = ChatStage

	local StageHeader = Instance.new("TextLabel")
	StageHeader.Name = "StageHeader"
	StageHeader.Position = UDim2.new(0, 12, 0, 10)
	StageHeader.Size = UDim2.new(0, 170, 0, 26)
	StageHeader.BackgroundTransparency = 1
	StageHeader.Text = "FAIRWELL"
	StageHeader.TextColor3 = WHITE
	StageHeader.TextSize = 14
	StageHeader.Font = Enum.Font.GothamBold
	StageHeader.TextXAlignment = Enum.TextXAlignment.Left
	StageHeader.ZIndex = 11
	StageHeader.Parent = ChatStage

	local StageStatus = Instance.new("TextLabel")
	StageStatus.Name = "StageStatus"
	StageStatus.Position = UDim2.new(0, 72, 0, 13)
	StageStatus.Size = UDim2.new(0, 100, 0, 20)
	StageStatus.BackgroundTransparency = 1
	StageStatus.Text = "● ONLINE"
	StageStatus.TextColor3 = Color3.fromRGB(70, 220, 145)
	StageStatus.TextSize = 9
	StageStatus.Font = Enum.Font.GothamBold
	StageStatus.TextXAlignment = Enum.TextXAlignment.Left
	StageStatus.ZIndex = 11
	StageStatus.Parent = ChatStage

	local AvatarFrame = Instance.new("Frame")
AvatarFrame.Name = "AvatarFrame"
AvatarFrame.Position = UDim2.new(0, 10, 0, 46)
AvatarFrame.Size = UDim2.fromOffset(170, 212)
AvatarFrame.BackgroundColor3 = Color3.fromRGB(7, 8, 24)
AvatarFrame.BackgroundTransparency = 0.12
AvatarFrame.BorderSizePixel = 0
AvatarFrame.ZIndex = 2
AvatarFrame.Parent = ChatStage

local AvatarCorner = Instance.new("UICorner")
AvatarCorner.CornerRadius = UDim.new(0, 10)
AvatarCorner.Parent = AvatarFrame

local AvatarStroke = Instance.new("UIStroke")
AvatarStroke.Color = BLUE
AvatarStroke.Transparency = 0.45
AvatarStroke.Parent = AvatarFrame

	local Wall = Instance.new("Frame")
	Wall.Name = "FairwellWall"
	Wall.Position = UDim2.new(0, 8, 0, 18)
	Wall.Size = UDim2.new(0, 7, 1, -34)
	Wall.BackgroundColor3 = Color3.fromRGB(18, 22, 42)
	Wall.BorderSizePixel = 0
	Wall.Parent = ChatStage

	local WallStroke = Instance.new("UIStroke")
	WallStroke.Color = Color3.fromRGB(35, 110, 150)
	WallStroke.Transparency = 0.35
	WallStroke.Parent = Wall

	local FairwellSpot = Instance.new("ViewportFrame")
	FairwellSpot.Name = "Fairwell"
	FairwellSpot.Position = UDim2.new(0, 10, 0, 52)
	FairwellSpot.Size = UDim2.fromOffset(170, 210)
	FairwellSpot.BackgroundColor3 = Color3.fromRGB(7, 8, 24)
	FairwellSpot.BackgroundTransparency = 1
	FairwellSpot.ClipsDescendants = true
	FairwellSpot.ZIndex = 3
	FairwellSpot.Ambient = Color3.fromRGB(180, 190, 210)
	FairwellSpot.LightColor = Color3.fromRGB(255, 255, 255)
	FairwellSpot.LightDirection = Vector3.new(-1, -1, -2)
	FairwellSpot.Parent = ChatStage

	local FairwellWorld = Instance.new("WorldModel")
	FairwellWorld.Name = "FairwellWorld"
	FairwellWorld.Parent = FairwellSpot

	local FairwellCamera = Instance.new("Camera")
	FairwellCamera.Name = "Camera"
	FairwellCamera.FieldOfView = 32
	FairwellCamera.CFrame = CFrame.lookAt(
		Vector3.new(4.8, 3.1, 8.2),
		Vector3.new(0, 1.65, 0)
	)
	FairwellCamera.Parent = FairwellSpot
	FairwellSpot.CurrentCamera = FairwellCamera

	--==================================================
	-- FAIRWELL 3D WALL / FLOOR
	--==================================================
	-- Real 3D parts inside the ViewportFrame WorldModel.
	local FairwellWall3D = Instance.new("Part")
	FairwellWall3D.Name = "FairwellWall3D"
	FairwellWall3D.Anchored = true
	FairwellWall3D.CanCollide = false
	FairwellWall3D.CanTouch = false
	FairwellWall3D.CanQuery = false
	FairwellWall3D.Material = Enum.Material.SmoothPlastic
	FairwellWall3D.Color = Color3.fromRGB(19, 23, 43)
	FairwellWall3D.Size = Vector3.new(5.5, 5.4, 0.22)
	FairwellWall3D.CFrame = CFrame.new(0, 2.65, -0.72)
	FairwellWall3D.Parent = FairwellWorld

	local FairwellWallTrim = Instance.new("Part")
	FairwellWallTrim.Name = "FairwellWallTrim"
	FairwellWallTrim.Anchored = true
	FairwellWallTrim.CanCollide = false
	FairwellWallTrim.CanTouch = false
	FairwellWallTrim.CanQuery = false
	FairwellWallTrim.Material = Enum.Material.SmoothPlastic
	FairwellWallTrim.Color = Color3.fromRGB(27, 147, 227)
	FairwellWallTrim.Size = Vector3.new(0.055, 5.0, 0.08)
	FairwellWallTrim.CFrame = CFrame.new(-2.62, 2.55, -0.58)
	FairwellWallTrim.Transparency = 0.35
	FairwellWallTrim.Parent = FairwellWorld

	local FairwellFloor3D = Instance.new("Part")
	FairwellFloor3D.Name = "FairwellFloor3D"
	FairwellFloor3D.Anchored = true
	FairwellFloor3D.CanCollide = false
	FairwellFloor3D.CanTouch = false
	FairwellFloor3D.CanQuery = false
	FairwellFloor3D.Material = Enum.Material.SmoothPlastic
	FairwellFloor3D.Color = Color3.fromRGB(12, 14, 29)
	FairwellFloor3D.Size = Vector3.new(5.5, 0.12, 4.0)
	FairwellFloor3D.CFrame = CFrame.new(0, -0.06, 0.25)
	FairwellFloor3D.Parent = FairwellWorld

	--==================================================
	-- FAIRWELL ROBLOX AVATAR
	--==================================================
	-- Uses Roblox's direct user-avatar character API first.
	-- HumanoidDescription and thumbnail are fallbacks.

	local FAIRWELL_USERNAME = "fairwelladmi"
	local FairwellModel = nil
	local Fairwell3DActive = false

	-- Animation state is initialized before the asynchronous avatar loader runs.
	-- This prevents RenderStepped from touching nil state while the avatar loads.
	local FairwellBasePivot = CFrame.new()
	local MouthParts = {}
	local EyeParts = {}

	local FairwellThumbnail = Instance.new("ImageLabel")
	FairwellThumbnail.Name = "FairwellAvatarThumbnail"
	FairwellThumbnail.Position = UDim2.new(0, 10, 0, 52)
	FairwellThumbnail.Size = UDim2.fromOffset(170, 210)
	FairwellThumbnail.BackgroundColor3 = Color3.fromRGB(7, 8, 24)
	FairwellThumbnail.BackgroundTransparency = 0
	FairwellThumbnail.Image = ""
	FairwellThumbnail.ScaleType = Enum.ScaleType.Fit
	FairwellThumbnail.Visible = true
	FairwellThumbnail.ZIndex = 2
	FairwellThumbnail.Parent = ChatStage

	local FairwellThumbnailCorner = Instance.new("UICorner")
	FairwellThumbnailCorner.CornerRadius = UDim.new(0, 10)
	FairwellThumbnailCorner.Parent = FairwellThumbnail

	local FairwellThumbnailStroke = Instance.new("UIStroke")
	FairwellThumbnailStroke.Color = BLUE
	FairwellThumbnailStroke.Transparency = 0.25
	FairwellThumbnailStroke.Parent = FairwellThumbnail

	local AvatarName = Instance.new("TextLabel")
	AvatarName.Name = "AvatarName"
	AvatarName.Position = UDim2.new(0, 10, 0, 238)
	AvatarName.Size = UDim2.fromOffset(170, 22)
	AvatarName.BackgroundTransparency = 1
	AvatarName.Text = "@fairwelladmi"
	AvatarName.TextColor3 = GREY
	AvatarName.TextSize = 9
	AvatarName.Font = Enum.Font.GothamBold
	AvatarName.TextXAlignment = Enum.TextXAlignment.Center
	AvatarName.ZIndex = 12
	AvatarName.Parent = ChatStage

	local function PrepareFairwellModel(Model)
		if not Model or not Model:IsA("Model") then
			return nil
		end

		Model.Name = "Fairwell3D"

		-- The Roblox avatar can contain an executable Animate LocalScript.
		-- A ViewportFrame/WorldModel does not need it; Fairwell Heaven drives
		-- the display pose itself with RenderStepped below. Remove embedded
		-- scripts so FairwellWorld.Fairwell3D.Animate cannot throw errors.
		for _, Descendant in ipairs(Model:GetDescendants()) do
			if Descendant:IsA("Script")
				or Descendant:IsA("LocalScript")
				or Descendant:IsA("ModuleScript") then
				Descendant:Destroy()
			end
		end

		Model.Parent = FairwellWorld

		for _, Descendant in ipairs(Model:GetDescendants()) do
			if Descendant:IsA("BasePart") then
				Descendant.Anchored = true
				Descendant.CanCollide = false
				Descendant.CanTouch = false
				Descendant.CanQuery = false
			end
		end

		local BoundingCFrame, BoundingSize = Model:GetBoundingBox()
		if BoundingSize.Y <= 0 then
			return nil
		end

		local Pivot = Model:GetPivot()
		local CenterOffset = Pivot:ToObjectSpace(BoundingCFrame)
		Model:PivotTo(CFrame.new(0, 0, 0) * CenterOffset:Inverse())

		local _, NormalizedSize = Model:GetBoundingBox()
		local TargetHeight = 3.65

		if NormalizedSize.Y > 0 then
			Model:ScaleTo(TargetHeight / NormalizedSize.Y)
		end

		-- Cache facial parts now; cache the final pivot only after the model has been placed. 
		MouthParts = {}
		EyeParts = {}

		for _, Descendant in ipairs(Model:GetDescendants()) do
			if Descendant:IsA("BasePart") then
				local Name = string.lower(Descendant.Name)
				if string.find(Name, "mouth", 1, true) or string.find(Name, "lip", 1, true) then
					table.insert(MouthParts, Descendant)
				end
				if string.find(Name, "eye", 1, true) then
					table.insert(EyeParts, Descendant)
				end
			end
		end

		local FinalCFrame, FinalSize = Model:GetBoundingBox()
		local FinalCenter = FinalCFrame.Position

		Model:PivotTo(CFrame.new(
			0,
			FinalSize.Y * 0.5 - FinalCenter.Y,
			0
		))

		-- IMPORTANT: animation must start from the final centered pivot.
		FairwellBasePivot = Model:GetPivot()

		local CameraDistance = math.max(6, FinalSize.Y * 2.35)
		local CameraHeight = math.max(1.35, FinalSize.Y * 0.52)

		FairwellCamera.FieldOfView = 30
		FairwellCamera.CFrame = CFrame.lookAt(
			Vector3.new(0, CameraHeight, CameraDistance),
			Vector3.new(0, FinalSize.Y * 0.52, 0)
		)

		return Model
	end

	local function LoadFairwellThumbnail(UserId)
		local ThumbnailUrl = "rbxthumb://type=AvatarBust&id=" .. tostring(UserId) .. "&w=420&h=420"
		FairwellThumbnail.Image = ThumbnailUrl
		FairwellThumbnail.Visible = true

		task.spawn(function()
			local ok, err = pcall(function()
				ContentProvider:PreloadAsync({FairwellThumbnail})
			end)
			if ok then
				Hub:Log("Fairwell avatar thumbnail is ready.", "INFO")
			else
				Hub:Log("Avatar thumbnail preload failed: " .. tostring(err), "WARN")
			end
		end)

		task.spawn(function()
			local Success, Image, IsReady = pcall(function()
				return Players:GetUserThumbnailAsync(UserId, Enum.ThumbnailType.AvatarBust, Enum.ThumbnailSize.Size420x420)
			end)
			if Success and type(Image) == "string" and Image ~= "" then
				FairwellThumbnail.Image = Image
				FairwellThumbnail.Visible = true
				Hub:Log("Loaded official fairwelladmi avatar thumbnail" .. (IsReady and " (ready)." or " (waiting)."), "INFO")
			else
				Hub:Log("Using direct Roblox thumbnail URL fallback.", "WARN")
			end
		end)
		return true
	end
	local function LoadFairwellAvatar()
		local UserIdSuccess, UserId = pcall(function()
			return Players:GetUserIdFromNameAsync(FAIRWELL_USERNAME)
		end)

		if not UserIdSuccess or not UserId then
			Hub:Log(
				"Could not resolve " .. FAIRWELL_USERNAME ..
			": " .. tostring(UserId),
				"ERROR"
			)
			return nil
		end

		Hub:Log(
			"Resolved " .. FAIRWELL_USERNAME ..
			" (UserId " .. tostring(UserId) .. ").",
			"INFO"
		)

		-- PRIMARY: Roblox directly builds this user's current avatar.
		local ModelSuccess, Model = pcall(function()
			return Players:CreateHumanoidModelFromUserIdAsync(UserId)
		end)

		if ModelSuccess and Model and Model:IsA("Model") then
			local Prepared = PrepareFairwellModel(Model)
			if Prepared then
				Fairwell3DActive = true
				FairwellThumbnail.Visible = true
				FairwellSpot.Visible = true
				Hub:Log("Loaded the actual 3D fairwelladmi Roblox avatar over the fallback thumbnail.", "SUCCESS")
				return Prepared
			end
		end

		Hub:Log(
			"Direct avatar creation failed: " .. tostring(Model),
			"WARN"
		)

		-- SECONDARY: explicit HumanoidDescription path.
		local DescriptionSuccess, Description = pcall(function()
			return Players:GetHumanoidDescriptionFromUserIdAsync(UserId)
		end)

		if DescriptionSuccess and Description then
			local DescriptionModelSuccess, DescriptionModel = pcall(function()
				return Players:CreateHumanoidModelFromDescriptionAsync(
					Description,
					Enum.HumanoidRigType.R15
				)
			end)

			if DescriptionModelSuccess and DescriptionModel then
				local Prepared = PrepareFairwellModel(DescriptionModel)
				if Prepared then
					Fairwell3DActive = true
					FairwellThumbnail.Visible = true
					FairwellSpot.Visible = true
					Hub:Log("Loaded fairwelladmi through HumanoidDescription over the fallback thumbnail.", "SUCCESS")
					return Prepared
				end
			end
		else
			Hub:Log(
				"HumanoidDescription failed: " .. tostring(Description),
				"WARN"
			)
		end

		-- FINAL: official Roblox avatar thumbnail.
		LoadFairwellThumbnail(UserId)
		return nil
	end

	task.spawn(function()
		local UserIdSuccess, UserId = pcall(function()
			return Players:GetUserIdFromNameAsync(FAIRWELL_USERNAME)
		end)

		if UserIdSuccess and UserId then
			LoadFairwellThumbnail(UserId)
		else
			Hub:Log("Could not resolve Fairwell avatar user.", "ERROR")
		end

		local Model = LoadFairwellAvatar()
		if Model then
			FairwellModel = Model
			Fairwell3DActive = true
			FairwellThumbnail.Visible = true
			FairwellSpot.Visible = true
			Hub:Log("Fairwell 3D avatar is active; thumbnail remains as a transparent fallback.", "SUCCESS")
		else
			Fairwell3DActive = false
			FairwellThumbnail.Visible = true
			Hub:Log("3D avatar unavailable; keeping Roblox avatar thumbnail visible.", "WARN")
		end
	end)

	local Bubble = Instance.new("TextLabel")
	Bubble.Name = "SpeechBubble"
	Bubble.Position = UDim2.new(0, 194, 0, 48)
	Bubble.Size = UDim2.new(0, 170, 0, 58)
	Bubble.ZIndex = 12
	Bubble.BackgroundColor3 = Color3.fromRGB(245, 245, 250)
	Bubble.BackgroundTransparency = 0.02
	Bubble.BorderSizePixel = 0
	Bubble.Text = "Hey! I'm Fairwell. Talk to me!"
	Bubble.TextColor3 = Color3.fromRGB(20, 20, 30)
	Bubble.TextSize = 12
	Bubble.Font = Enum.Font.GothamBold
	Bubble.TextWrapped = true
	Bubble.TextXAlignment = Enum.TextXAlignment.Center
	Bubble.TextYAlignment = Enum.TextYAlignment.Center
	Bubble.Parent = ChatStage

	local BubbleCorner = Instance.new("UICorner")
	BubbleCorner.CornerRadius = UDim.new(0, 14)
	BubbleCorner.Parent = Bubble

	local BubbleStroke = Instance.new("UIStroke")
	BubbleStroke.Color = BLUE
	BubbleStroke.Thickness = 2
	BubbleStroke.Parent = Bubble

	local BubbleTail = Instance.new("TextLabel")
	BubbleTail.Position = UDim2.new(0, 174, 0, 78)
	BubbleTail.Size = UDim2.fromOffset(28, 22)
	BubbleTail.ZIndex = 12
	BubbleTail.BackgroundTransparency = 1
	BubbleTail.Text = "◀"
	BubbleTail.TextColor3 = Color3.fromRGB(245, 245, 250)
	BubbleTail.TextSize = 25
	BubbleTail.Font = Enum.Font.GothamBold
	BubbleTail.Parent = ChatStage

	local ChatDivider = Instance.new("Frame")
	ChatDivider.Name = "ChatDivider"
	ChatDivider.Position = UDim2.new(0.34, 0, 0, 10)
	ChatDivider.Size = UDim2.new(0, 1, 0, 256)
	ChatDivider.ZIndex = 4
	ChatDivider.BackgroundColor3 = BLUE
	ChatDivider.BackgroundTransparency = 0.65
	ChatDivider.BorderSizePixel = 0
	ChatDivider.Parent = ChatStage

	local ChatMessages = Instance.new("ScrollingFrame")
	ChatMessages.Name = "Messages"
	ChatMessages.Position = UDim2.new(0.36, 5, 0, 8)
	ChatMessages.Size = UDim2.new(0.64, -10, 0, 260)
	ChatMessages.ZIndex = 5
	ChatMessages.BackgroundColor3 = Color3.fromRGB(4, 3, 30)
	ChatMessages.BorderSizePixel = 0
	ChatMessages.ScrollBarThickness = 3
	ChatMessages.AutomaticCanvasSize = Enum.AutomaticSize.Y
	ChatMessages.CanvasSize = UDim2.new(0, 0, 0, 0)
	ChatMessages.Parent = ChatStage

	local ChatCorner = Instance.new("UICorner")
	ChatCorner.CornerRadius = UDim.new(0, 7)
	ChatCorner.Parent = ChatMessages

	local ChatStroke = Instance.new("UIStroke")
	ChatStroke.Color = BLUE
	ChatStroke.Transparency = 0.25
	ChatStroke.Parent = ChatMessages

	local ChatLayout = Instance.new("UIListLayout")
	ChatLayout.Padding = UDim.new(0, 4)
	ChatLayout.SortOrder = Enum.SortOrder.LayoutOrder
	ChatLayout.Parent = ChatMessages

	local function AddChatMessage(Sender, Message, SenderColor)
		local Row = Instance.new("TextLabel")
		Row.Name = "Message"
		Row.LayoutOrder = math.floor(os.clock() * 1000)
		Row.Size = UDim2.new(1, -4, 0, 25)
		Row.AutomaticSize = Enum.AutomaticSize.Y
		Row.BackgroundColor3 = PANEL
		Row.BackgroundTransparency = 0.15
		Row.BorderSizePixel = 0
		Row.Text = tostring(Sender) .. "  •  " .. tostring(Message)
		Row.TextColor3 = WHITE
		Row.TextSize = 10
		Row.Font = Enum.Font.Gotham
		Row.TextWrapped = true
		Row.TextXAlignment = Enum.TextXAlignment.Left
		Row.TextYAlignment = Enum.TextYAlignment.Center
		Row.ZIndex = 6
		Row.Parent = ChatMessages

		local Corner = Instance.new("UICorner")
		Corner.CornerRadius = UDim.new(0, 5)
		Corner.Parent = Row

		local Stroke = Instance.new("UIStroke")
		Stroke.Color = SenderColor or BLUE
		Stroke.Transparency = 0.55
		Stroke.Parent = Row

		task.defer(function()
			ChatMessages.CanvasPosition = Vector2.new(0, math.max(0, ChatMessages.AbsoluteCanvasSize.Y))
		end)
	end

	local function FairwellReply(Message)
		local Text = tostring(Message):lower()

		if Text:find("hello", 1, true) or Text:find("hi", 1, true) or Text:find("hey", 1, true) then
			return "Hey! I'm Fairwell. What are we working on?"
		elseif Text:find("who are you", 1, true) or Text:find("what are you", 1, true) then
			return "I'm Fairwelladmi — the little guy living inside Fairwell Heaven."
		elseif Text:find("doors", 1, true) then
			return "DOORS? Yep. I know about the hub's room tracking, doors, highlights, HUD, and entity notifications."
		elseif Text:find("fairwell heaven", 1, true) then
			return "This is my home. Keep making Fairwell Heaven better."
		elseif Text:find("thank", 1, true) or Text:find("thanks", 1, true) then
			return "Anytime!"
		end

		local Replies = {
			"Interesting. Tell me more.",
			"I'm listening.",
			"Got it. What do you want to do next?",
			"Yeah, I see what you mean.",
			"Alright. Let's figure it out together."
		}
		return Replies[(math.floor(os.clock() * 1000) % #Replies) + 1]
	end

	local FairwellTalkingUntil = 0
	local FairwellTalkCycle = 0
	local FairwellBlinkUntil = 0

	local function SetFairwellPose(Time)
		if not FairwellModel then
			return
		end

		local Bob = math.sin(Time * 2.2) * 0.018
		local Sway = math.sin(Time * 1.45) * 0.012

		-- Relaxed wall lean: his back shifts toward the wall while
		-- his shoulders stay slightly rolled for a natural pose.
		local BackLean = math.rad(5 + math.sin(Time * 1.25) * 0.35)
		local SideLean = math.rad(12 + math.sin(Time * 1.1) * 0.7)

		local WallLean = CFrame.new(
			Sway,
			Bob,
			-0.20
		) * CFrame.Angles(
			BackLean,
			0,
			-math.rad(12) + SideLean * 0.10
		)

		FairwellModel:PivotTo(FairwellBasePivot * WallLean)
	end

	local FairwellAnimationConnection = RunService.RenderStepped:Connect(function()
		if not ChatStage.Parent then
			return
		end

		local Time = os.clock()
		SetFairwellPose(Time)

		if Time < FairwellTalkingUntil then
			FairwellTalkCycle += 1
			local Talking = FairwellTalkCycle % 12

			for _, Part in ipairs(MouthParts) do
				if Part:IsA("BasePart") then
					Part.Transparency = Talking < 6 and 0 or math.min(0.35, Part.Transparency)
				end
			end

			Bubble.Position = UDim2.new(0, 194, 0, 46 + math.sin(Time * 8) * 1.5)
		else
			Bubble.Position = UDim2.new(0, 194, 0, 48)
		end
	end)

	-- Blink support is automatic for imported models whose eye meshes/parts
	-- contain "Eye" in their names. The supplied model can therefore animate
	-- without requiring its geometry to be rebuilt.
	task.spawn(function()
		while ChatStage.Parent do
			task.wait(math.random(25, 45) / 10)

			if not ChatStage.Parent then
				break
			end

			for _, Eye in ipairs(EyeParts) do
				if Eye:IsA("BasePart") then
					Eye:SetAttribute("FairwellOriginalTransparency", Eye.Transparency)
					Eye.Transparency = 1
				end
			end

			task.wait(0.09)

			for _, Eye in ipairs(EyeParts) do
				if Eye:IsA("BasePart") then
					local Original = Eye:GetAttribute("FairwellOriginalTransparency")
					Eye.Transparency = typeof(Original) == "number" and Original or 0
				end
			end
		end
	end)

	local function FairwellSpeak(Text)
		Bubble.Text = tostring(Text)
		Bubble.BackgroundTransparency = 0.02
		FairwellTalkingUntil = os.clock() + math.max(1.5, math.min(5, #tostring(Text) * 0.055))
		FairwellTalkCycle = 0

		task.spawn(function()
			for Index = 1, 2 do
				if Bubble.Parent then
					Bubble.Position = UDim2.new(0, 194, 0, 46)
					task.wait(0.06)
					Bubble.Position = UDim2.new(0, 194, 0, 48)
					task.wait(0.06)
				end
			end
		end)
	end

	FairwellSpeak("Hey! I'm Fairwell. Talk to me.")
	AddChatMessage("FAIRWELL", "Hey! I'm Fairwell. Talk to me.", BLUE)

	local ChatInput = Instance.new("TextBox")
	ChatInput.Name = "Input"
	ChatInput.Position = UDim2.new(0, 5, 0, 292)
	ChatInput.Size = UDim2.new(1, -75, 0, 36)
	ChatInput.BackgroundColor3 = PANEL
	ChatInput.BorderSizePixel = 0
	ChatInput.ClearTextOnFocus = false
	ChatInput.PlaceholderText = "Type here..."
	ChatInput.Text = ""
	ChatInput.TextColor3 = WHITE
	ChatInput.PlaceholderColor3 = GREY
	ChatInput.TextSize = 11
	ChatInput.Font = Enum.Font.Gotham
	ChatInput.TextXAlignment = Enum.TextXAlignment.Left
	ChatInput.Parent = ChatScroll

	local InputCorner = Instance.new("UICorner")
	InputCorner.CornerRadius = UDim.new(0, 5)
	InputCorner.Parent = ChatInput

	local InputStroke = Instance.new("UIStroke")
	InputStroke.Color = BLUE
	InputStroke.Parent = ChatInput

	local SendButton = Instance.new("TextButton")
	SendButton.Name = "Send"
	SendButton.Position = UDim2.new(1, -64, 0, 292)
	SendButton.Size = UDim2.new(0, 59, 0, 36)
	SendButton.BackgroundColor3 = BLUE
	SendButton.BackgroundTransparency = 0.1
	SendButton.BorderSizePixel = 0
	SendButton.Text = "SEND"
	SendButton.TextColor3 = WHITE
	SendButton.TextSize = 10
	SendButton.Font = Enum.Font.GothamBold
	SendButton.Parent = ChatScroll

	local SendCorner = Instance.new("UICorner")
	SendCorner.CornerRadius = UDim.new(0, 5)
	SendCorner.Parent = SendButton

	local function SendChat()
		local Message = ChatInput.Text:gsub("^%s+", ""):gsub("%s+$", "")
		if Message == "" then return end
		ChatInput.Text = ""

		local Lower = Message:lower()
		if Lower == "/help" then
			FairwellSpeak("/clear • clears chat | /status • hub status | /help • commands")
			AddChatMessage("FAIRWELL", "/clear • clears chat | /status • hub status | /help • commands", BLUE)
			return
		elseif Lower == "/clear" then
			for _, Child in ipairs(ChatMessages:GetChildren()) do
				if Child:IsA("TextLabel") and Child.Name == "Message" then Child:Destroy() end
			end
			FairwellSpeak("Chat cleared. I'm still here.")
			AddChatMessage("FAIRWELL", "Chat cleared. I'm still here.", BLUE)
			return
		elseif Lower == "/status" then
			local Status = "Hub online • " .. tostring(Hub.Version or "unknown") .. " • " .. tostring(Hub.Game.Name or "Unknown")
			FairwellSpeak(Status)
			AddChatMessage("FAIRWELL", Status, BLUE)
			return
		end

		AddChatMessage(Players.LocalPlayer and Players.LocalPlayer.Name or "YOU", Message, Color3.fromRGB(55, 200, 120))
		task.delay(0.35, function()
			if not ChatMessages.Parent then return end
			local Reply = FairwellReply(Message)
			FairwellSpeak(Reply)
			AddChatMessage("FAIRWELL", Reply, BLUE)
		end)
	end

	SendButton.MouseButton1Click:Connect(SendChat)
	ChatInput.FocusLost:Connect(function(EnterPressed)
		if EnterPressed then SendChat() end
	end)

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
			"Live runtime logs. Useful for debugging feature detection, errors, and state changes.",
			UDim2.new(1, -10, 0, 42),
			UDim2.new(0, 5, 0, 42)
		)

	DevInfo.TextWrapped = true

	--==================================================
	-- NOTIFICATION TESTER
	--==================================================

	local NotifyTester = Instance.new("Frame")
	NotifyTester.Name = "NotificationTester"
	NotifyTester.Position = UDim2.new(0, 5, 0, 88)
	NotifyTester.Size = UDim2.new(1, -10, 0, 72)
	NotifyTester.BackgroundColor3 = Color3.fromRGB(4, 3, 30)
	NotifyTester.BorderSizePixel = 0
	NotifyTester.Parent = DevScroll

	local NotifyCorner = Instance.new("UICorner")
	NotifyCorner.CornerRadius = UDim.new(0, 6)
	NotifyCorner.Parent = NotifyTester

	local NotifyStroke = Instance.new("UIStroke")
	NotifyStroke.Color = BLUE
	NotifyStroke.Thickness = 1
	NotifyStroke.Transparency = 0.15
	NotifyStroke.Parent = NotifyTester

	local NotifyTitle = Instance.new("TextLabel")
	NotifyTitle.Position = UDim2.new(0, 10, 0, 5)
	NotifyTitle.Size = UDim2.new(1, -20, 0, 20)
	NotifyTitle.BackgroundTransparency = 1
	NotifyTitle.Text = "NOTIFICATION TESTER"
	NotifyTitle.TextColor3 = WHITE
	NotifyTitle.TextSize = 12
	NotifyTitle.Font = Enum.Font.GothamBold
	NotifyTitle.TextXAlignment = Enum.TextXAlignment.Left
	NotifyTitle.Parent = NotifyTester

	local NotifyInfo = Instance.new("TextLabel")
	NotifyInfo.Position = UDim2.new(0, 10, 0, 25)
	NotifyInfo.Size = UDim2.new(1, -20, 0, 14)
	NotifyInfo.BackgroundTransparency = 1
	NotifyInfo.Text = "Preview the live Fairwell Heaven notification styles."
	NotifyInfo.TextColor3 = GREY
	NotifyInfo.TextSize = 8
	NotifyInfo.Font = Enum.Font.Gotham
	NotifyInfo.TextXAlignment = Enum.TextXAlignment.Left
	NotifyInfo.Parent = NotifyTester

	local NotifyButtons = {
		{"INFO", "INFO", "Test information notification.", BLUE},
		{"SUCCESS", "SUCCESS", "Test success notification.", Color3.fromRGB(55, 200, 120)},
		{"WARNING", "WARNING", "Test warning notification.", Color3.fromRGB(240, 165, 55)},
		{"ERROR", "ERROR", "Test error notification.", Color3.fromRGB(235, 75, 95)}
	}

	for Index, Data in ipairs(NotifyButtons) do
		local Button = Instance.new("TextButton")
		Button.Name = Data[1]
		Button.Position = UDim2.new((Index - 1) * 0.25, 3, 0, 46)
		Button.Size = UDim2.new(0.25, -6, 0, 20)
		Button.BackgroundColor3 = PANEL
		Button.BorderSizePixel = 0
		Button.Text = Data[1]
		Button.TextColor3 = Data[4]
		Button.TextSize = 8
		Button.Font = Enum.Font.GothamBold
		Button.Parent = NotifyTester

		local ButtonCorner = Instance.new("UICorner")
		ButtonCorner.CornerRadius = UDim.new(0, 4)
		ButtonCorner.Parent = Button

		local ButtonStroke = Instance.new("UIStroke")
		ButtonStroke.Color = Data[4]
		ButtonStroke.Thickness = 1
		ButtonStroke.Transparency = 0.25
		ButtonStroke.Parent = Button

		Button.MouseButton1Click:Connect(function()
			if self.Hub and self.Hub.Notify then
				self.Hub:Notify(
					"DEV TEST • " .. Data[1],
					Data[3],
					Data[2],
					4
				)
			end
		end)
	end

	local TestAllButton = Instance.new("TextButton")
	TestAllButton.Name = "TestAll"
	TestAllButton.Position = UDim2.new(1, -108, 0, 5)
	TestAllButton.Size = UDim2.fromOffset(98, 20)
	TestAllButton.BackgroundColor3 = BLUE
	TestAllButton.BackgroundTransparency = 0.15
	TestAllButton.BorderSizePixel = 0
	TestAllButton.Text = "TEST ALL"
	TestAllButton.TextColor3 = WHITE
	TestAllButton.TextSize = 8
	TestAllButton.Font = Enum.Font.GothamBold
	TestAllButton.Parent = NotifyTester

	local TestAllCorner = Instance.new("UICorner")
	TestAllCorner.CornerRadius = UDim.new(0, 4)
	TestAllCorner.Parent = TestAllButton

	TestAllButton.MouseButton1Click:Connect(function()
		if not self.Hub or not self.Hub.Notify then
			return
		end

		local Sequence = {
			{"INFO", "Information test.", BLUE},
			{"SUCCESS", "Success test.", Color3.fromRGB(55, 200, 120)},
			{"WARNING", "Warning test.", Color3.fromRGB(240, 165, 55)},
			{"ERROR", "Error test.", Color3.fromRGB(235, 75, 95)}
		}

		for Index, Data in ipairs(Sequence) do
			task.delay((Index - 1) * 0.35, function()
				if self.Hub and self.Hub.Notify then
					self.Hub:Notify(
						"DEV TEST • " .. Data[1],
						Data[2],
						Data[1],
						4
					)
				end
			end)
		end
	end)

	local LogFrame = Instance.new("Frame")
	LogFrame.Name = "DevLogs"
	LogFrame.Position = UDim2.new(0, 5, 0, 168)
	LogFrame.Size = UDim2.new(1, -10, 0, 340)
	LogFrame.BackgroundColor3 = Color3.fromRGB(4, 3, 30)
	LogFrame.BorderSizePixel = 0
	LogFrame.Parent = DevScroll

	local LogCorner = Instance.new("UICorner")
	LogCorner.CornerRadius = UDim.new(0, 6)
	LogCorner.Parent = LogFrame

	local LogStroke = Instance.new("UIStroke")
	LogStroke.Color = BLUE
	LogStroke.Thickness = 1
	LogStroke.Transparency = 0.15
	LogStroke.Parent = LogFrame

	local LogHeader = Instance.new("Frame")
	LogHeader.Size = UDim2.new(1, 0, 0, 34)
	LogHeader.BackgroundColor3 = PANEL
	LogHeader.BorderSizePixel = 0
	LogHeader.Parent = LogFrame

	local HeaderCorner = Instance.new("UICorner")
	HeaderCorner.CornerRadius = UDim.new(0, 6)
	HeaderCorner.Parent = LogHeader

	local HeaderMask = Instance.new("Frame")
	HeaderMask.Position = UDim2.new(0, 0, 1, -6)
	HeaderMask.Size = UDim2.new(1, 0, 0, 6)
	HeaderMask.BackgroundColor3 = PANEL
	HeaderMask.BorderSizePixel = 0
	HeaderMask.Parent = LogHeader

	local LogHeaderTitle = Instance.new("TextLabel")
	LogHeaderTitle.Position = UDim2.new(0, 10, 0, 0)
	LogHeaderTitle.Size = UDim2.new(1, -120, 1, 0)
	LogHeaderTitle.BackgroundTransparency = 1
	LogHeaderTitle.Text = "LIVE RUNTIME LOGS"
	LogHeaderTitle.TextColor3 = WHITE
	LogHeaderTitle.TextSize = 12
	LogHeaderTitle.Font = Enum.Font.GothamBold
	LogHeaderTitle.TextXAlignment = Enum.TextXAlignment.Left
	LogHeaderTitle.Parent = LogHeader

	local LogCount = Instance.new("TextLabel")
	LogCount.Position = UDim2.new(1, -105, 0, 0)
	LogCount.Size = UDim2.fromOffset(95, 34)
	LogCount.BackgroundTransparency = 1
	LogCount.Text = "0 ENTRIES"
	LogCount.TextColor3 = GREY
	LogCount.TextSize = 9
	LogCount.Font = Enum.Font.GothamBold
	LogCount.TextXAlignment = Enum.TextXAlignment.Right
	LogCount.Parent = LogHeader

	local LogScroll = Instance.new("ScrollingFrame")
	LogScroll.Name = "LogScroll"
	LogScroll.Position = UDim2.new(0, 6, 0, 40)
	LogScroll.Size = UDim2.new(1, -12, 1, -46)
	LogScroll.BackgroundTransparency = 1
	LogScroll.BorderSizePixel = 0
	LogScroll.ScrollBarThickness = 4
	LogScroll.ScrollBarImageColor3 = BLUE
	LogScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	LogScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	LogScroll.Parent = LogFrame

	local LogLayout = Instance.new("UIListLayout")
	LogLayout.Padding = UDim.new(0, 4)
	LogLayout.SortOrder = Enum.SortOrder.LayoutOrder
	LogLayout.Parent = LogScroll

	local LogPadding = Instance.new("UIPadding")
	LogPadding.PaddingTop = UDim.new(0, 2)
	LogPadding.PaddingBottom = UDim.new(0, 4)
	LogPadding.PaddingLeft = UDim.new(0, 2)
	LogPadding.PaddingRight = UDim.new(0, 2)
	LogPadding.Parent = LogScroll

	local EmptyLabel = Instance.new("TextLabel")
	EmptyLabel.Name = "Empty"
	EmptyLabel.Size = UDim2.new(1, -10, 0, 50)
	EmptyLabel.BackgroundTransparency = 1
	EmptyLabel.Text = "NO RUNTIME LOGS"
	EmptyLabel.TextColor3 = GREY
	EmptyLabel.TextSize = 11
	EmptyLabel.Font = Enum.Font.GothamBold
	EmptyLabel.Parent = LogScroll

	local ClearInfoButton = Instance.new("TextButton")
	ClearInfoButton.Name = "ClearInfo"
	ClearInfoButton.Position = UDim2.new(0, 5, 0, 516)
	ClearInfoButton.Size = UDim2.new(0.5, -7, 0, 32)
	ClearInfoButton.BackgroundColor3 = PANEL
	ClearInfoButton.BorderSizePixel = 0
	ClearInfoButton.Text = "CLEAR INFO"
	ClearInfoButton.TextColor3 = WHITE
	ClearInfoButton.TextSize = 10
	ClearInfoButton.Font = Enum.Font.GothamBold
	ClearInfoButton.Parent = DevScroll

	local ClearInfoCorner = Instance.new("UICorner")
	ClearInfoCorner.CornerRadius = UDim.new(0, 5)
	ClearInfoCorner.Parent = ClearInfoButton

	local ClearInfoStroke = Instance.new("UIStroke")
	ClearInfoStroke.Color = BLUE
	ClearInfoStroke.Thickness = 1
	ClearInfoStroke.Parent = ClearInfoButton

	local ClearLogsButton = Instance.new("TextButton")
	ClearLogsButton.Name = "ClearLogs"
	ClearLogsButton.Position = UDim2.new(0.5, 2, 0, 516)
	ClearLogsButton.Size = UDim2.new(0.5, -7, 0, 32)
	ClearLogsButton.BackgroundColor3 = PANEL
	ClearLogsButton.BorderSizePixel = 0
	ClearLogsButton.Text = "CLEAR ALL"
	ClearLogsButton.TextColor3 = WHITE
	ClearLogsButton.TextSize = 10
	ClearLogsButton.Font = Enum.Font.GothamBold
	ClearLogsButton.Parent = DevScroll

	local ClearCorner = Instance.new("UICorner")
	ClearCorner.CornerRadius = UDim.new(0, 5)
	ClearCorner.Parent = ClearLogsButton

	local ClearStroke = Instance.new("UIStroke")
	ClearStroke.Color = BLUE
	ClearStroke.Thickness = 1
	ClearStroke.Parent = ClearLogsButton

	local function RefreshDevLogs()
		if not self.Hub or not self.Hub.GetLogs then return end

		for _, Child in ipairs(LogScroll:GetChildren()) do
			if Child:IsA("Frame") or Child:IsA("TextLabel") and Child.Name ~= "Empty" then
				Child:Destroy()
			end
		end

		local Logs = self.Hub:GetLogs()
		LogCount.Text = tostring(#Logs) .. " ENTRIES"
		EmptyLabel.Visible = #Logs == 0

		for Index, Entry in ipairs(Logs) do
			local Row = Instance.new("Frame")
			Row.Name = "Log_" .. tostring(Index)
			Row.LayoutOrder = Index
			Row.Size = UDim2.new(1, -4, 0, 38)
			Row.BackgroundColor3 = Index % 2 == 0 and Color3.fromRGB(8, 7, 43) or Color3.fromRGB(6, 5, 35)
			Row.BorderSizePixel = 0
			Row.Parent = LogScroll

			local RowCorner = Instance.new("UICorner")
			RowCorner.CornerRadius = UDim.new(0, 4)
			RowCorner.Parent = Row

			local Level = tostring(Entry.Level or "INFO")
			local Badge = Instance.new("TextLabel")
			Badge.Position = UDim2.new(0, 6, 0, 7)
			Badge.Size = UDim2.fromOffset(48, 24)
			Badge.BackgroundColor3 = Level == "ERROR" and Color3.fromRGB(125, 35, 55)
				or Level == "WARN" and Color3.fromRGB(120, 80, 25)
				or Color3.fromRGB(25, 85, 130)
			Badge.BorderSizePixel = 0
			Badge.Text = Level
			Badge.TextColor3 = WHITE
			Badge.TextSize = 8
			Badge.Font = Enum.Font.GothamBold
			Badge.Parent = Row

			local BadgeCorner = Instance.new("UICorner")
			BadgeCorner.CornerRadius = UDim.new(0, 4)
			BadgeCorner.Parent = Badge

			local Time = Instance.new("TextLabel")
			Time.Position = UDim2.new(0, 62, 0, 3)
			Time.Size = UDim2.fromOffset(70, 14)
			Time.BackgroundTransparency = 1
			Time.Text = tostring(Entry.Timestamp or "--:--:--")
			Time.TextColor3 = GREY
			Time.TextSize = 8
			Time.Font = Enum.Font.Code
			Time.TextXAlignment = Enum.TextXAlignment.Left
			Time.Parent = Row

			local Message = Instance.new("TextLabel")
			Message.Position = UDim2.new(0, 62, 0, 16)
			Message.Size = UDim2.new(1, -70, 0, 18)
			Message.BackgroundTransparency = 1
			Message.Text = tostring(Entry.Message or "")
			Message.TextColor3 = WHITE
			Message.TextSize = 10
			Message.Font = Enum.Font.Code
			Message.TextXAlignment = Enum.TextXAlignment.Left
			Message.TextTruncate = Enum.TextTruncate.AtEnd
			Message.Parent = Row
		end

		task.defer(function()
			LogScroll.CanvasPosition = Vector2.new(0, math.max(0, LogScroll.AbsoluteCanvasSize.Y))
		end)
	end

	ClearInfoButton.MouseButton1Click:Connect(function()
		if self.Hub and self.Hub.ClearLogs then
			self.Hub:ClearLogs("INFO")
			RefreshDevLogs()
		end
	end)

	ClearLogsButton.MouseButton1Click:Connect(function()
		if self.Hub and self.Hub.ClearLogs then
			self.Hub:ClearLogs()
			RefreshDevLogs()
		end
	end)

	self.DevLogRefresh = RefreshDevLogs

	--==================================================
	-- SETTINGS PAGE
	--==================================================

	local SettingsTab =
		Instance.new("TextButton")

	SettingsTab.Position =
		UDim2.new(3/4, 0, 0, 0)

	SettingsTab.Size =
		UDim2.new(1/4, 0, 1, 0)

	SettingsTab.BackgroundTransparency = 1
	SettingsTab.Text = "SETTINGS"
	SettingsTab.TextColor3 = GREY
	SettingsTab.TextSize = 13
	SettingsTab.Font = Enum.Font.GothamBold
	SettingsTab.ZIndex = 16
	SettingsTab.Parent = Tabs

	local SettingsScroll =
		Instance.new("ScrollingFrame")

	SettingsScroll.Name = "SettingsScroll"
	SettingsScroll.Position =
		UDim2.new(0, 8, 0, 8)

	SettingsScroll.Size =
		UDim2.new(1, -16, 1, -16)

	SettingsScroll.BackgroundTransparency = 1
	SettingsScroll.BorderSizePixel = 0
	SettingsScroll.ScrollBarThickness = 4
	SettingsScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	SettingsScroll.Visible = false
	SettingsScroll.Parent = Content

	local SettingsTitle =
		MakeLabel(
			SettingsScroll,
			"SettingsTitle",
			"FAIRWELL HEAVEN SETTINGS",
			UDim2.new(1, -10, 0, 30),
			UDim2.new(0, 5, 0, 5)
		)

	SettingsTitle.TextColor3 = BLUE
	SettingsTitle.Font = Enum.Font.GothamBold
	SettingsTitle.TextSize = 16

	local SettingsService =
		Hub:GetService("Settings")

	local function SaveFeature(Name, Enabled)
		if not SettingsService then
			return
		end

		SettingsService:SetFeatureEnabled(
			Name,
			Enabled,
			true
		)

		if Enabled then
			Hub:Enable(Name)
		else
			Hub:Disable(Name)
		end
	end

	local function MakeToggle(Text, FeatureName, Y)
		local Button =
			Instance.new("TextButton")

		Button.Position =
			UDim2.new(0, 5, 0, Y)

		Button.Size =
			UDim2.new(1, -10, 0, 38)

		Button.BackgroundColor3 = PANEL
		Button.BorderSizePixel = 0
		Button.TextColor3 = WHITE
		Button.TextSize = 13
		Button.Font = Enum.Font.Gotham
		Button.TextXAlignment = Enum.TextXAlignment.Left
		Button.ZIndex = 2
		Button.Parent = SettingsScroll

		local Stroke = Instance.new("UIStroke")
		Stroke.Color = BLUE
		Stroke.Thickness = 1
		Stroke.Parent = Button

		local function Refresh()
			local Enabled = true

			if SettingsService then
				Enabled =
					SettingsService:GetFeatureEnabled(
						FeatureName,
						true
					)
			end

			Button.Text =
				"  "
				.. Text
				.. "    ["
				.. (Enabled and "ON" or "OFF")
				.. "]"
		end

		Refresh()

		Button.MouseButton1Click:Connect(function()
			local Enabled = true

			if SettingsService then
				Enabled =
					SettingsService:GetFeatureEnabled(
						FeatureName,
						true
					)
			end

			SaveFeature(FeatureName, not Enabled)
			Refresh()
		end)

		return Button
	end

	MakeToggle(
		"DOORS HIGHLIGHTS",
		"DOORS Highlights",
		48
	)

	MakeToggle(
		"ENTITY NOTIFICATIONS",
		"DOORS Entity Notifications",
		92
	)

	MakeToggle(
		"ROOM HUD",
		"DOORS Room HUD",
		136
	)

	local IntervalLabel =
		MakeLabel(
			SettingsScroll,
			"IntervalLabel",
			"Update Check Interval (seconds)",
			UDim2.new(1, -10, 0, 24),
			UDim2.new(0, 5, 0, 184)
		)

	local IntervalBox =
		Instance.new("TextBox")

	IntervalBox.Position =
		UDim2.new(0, 5, 0, 210)

	IntervalBox.Size =
		UDim2.new(1, -10, 0, 38)

	IntervalBox.BackgroundColor3 = PANEL
	IntervalBox.BorderSizePixel = 0
	IntervalBox.ClearTextOnFocus = false
	IntervalBox.PlaceholderText = "30 - 3600"
	IntervalBox.TextColor3 = WHITE
	IntervalBox.TextSize = 13
	IntervalBox.Font = Enum.Font.Gotham
	IntervalBox.Text = "120"
	IntervalBox.Parent = SettingsScroll

	local IntervalStroke = Instance.new("UIStroke")
	IntervalStroke.Color = BLUE
	IntervalStroke.Thickness = 1
	IntervalStroke.Parent = IntervalBox

	if SettingsService then
		IntervalBox.Text =
			tostring(
				SettingsService:Get(
					"UpdateInterval",
					120
				)
			)
	end

	IntervalBox.FocusLost:Connect(function()
		if not SettingsService then
			return
		end

		local Value = tonumber(IntervalBox.Text)

		if not Value then
			IntervalBox.Text =
				tostring(
					SettingsService:Get(
						"UpdateInterval",
						120
					)
				)
			return
		end

		Value = math.clamp(Value, 30, 3600)

		IntervalBox.Text = tostring(Value)
		SettingsService:Set("UpdateInterval", Value, true)
	end)

	local ResetButton =
		Instance.new("TextButton")

	ResetButton.Position =
		UDim2.new(0, 5, 0, 258)

	ResetButton.Size =
		UDim2.new(1, -10, 0, 38)

	ResetButton.BackgroundColor3 = PANEL
	ResetButton.BorderSizePixel = 0
	ResetButton.Text = "  RESET SETTINGS"
	ResetButton.TextColor3 = WHITE
	ResetButton.TextSize = 13
	ResetButton.Font = Enum.Font.GothamBold
	ResetButton.TextXAlignment = Enum.TextXAlignment.Left
	ResetButton.Parent = SettingsScroll

	local ResetStroke = Instance.new("UIStroke")
	ResetStroke.Color = BLUE
	ResetStroke.Thickness = 1
	ResetStroke.Parent = ResetButton

	ResetButton.MouseButton1Click:Connect(function()
		if not SettingsService then
			return
		end

		SettingsService:Reset()

		IntervalBox.Text = "120"

		Hub:Log("Settings reset to defaults.")

		Hub:Disable("DOORS Highlights")
		Hub:Disable("DOORS Entity Notifications")
		Hub:Disable("DOORS Room HUD")

		SettingsService:SetFeatureEnabled(
			"DOORS Highlights",
			true,
			true
		)

		SettingsService:SetFeatureEnabled(
			"DOORS Entity Notifications",
			true,
			true
		)

		SettingsService:SetFeatureEnabled(
			"DOORS Room HUD",
			true,
			true
		)

		Hub:Enable("DOORS Highlights")
		Hub:Enable("DOORS Entity Notifications")
		Hub:Enable("DOORS Room HUD")
	end)

	--==================================================
	-- TAB SWITCHING
	--==================================================

	MainTab.MouseButton1Click:Connect(function()
		MainScroll.Visible = true
		DevScroll.Visible = false
		ChatScroll.Visible = false
		SettingsScroll.Visible = false

		MainTab.TextColor3 = BLUE
		DevTab.TextColor3 = GREY
		ChatTab.TextColor3 = GREY
		SettingsTab.TextColor3 = GREY
	end)

	DevTab.MouseButton1Click:Connect(function()
		MainScroll.Visible = false
		DevScroll.Visible = true
		ChatScroll.Visible = false
		SettingsScroll.Visible = false

		MainTab.TextColor3 = GREY
		DevTab.TextColor3 = BLUE
		ChatTab.TextColor3 = GREY
		SettingsTab.TextColor3 = GREY
	end)

	ChatTab.MouseButton1Click:Connect(function()
		MainScroll.Visible = false
		DevScroll.Visible = false
		ChatScroll.Visible = true
		SettingsScroll.Visible = false

		MainTab.TextColor3 = GREY
		DevTab.TextColor3 = GREY
		ChatTab.TextColor3 = BLUE
		SettingsTab.TextColor3 = GREY
	end)

	SettingsTab.MouseButton1Click:Connect(function()
		MainScroll.Visible = false
		DevScroll.Visible = false
		ChatScroll.Visible = false
		SettingsScroll.Visible = true

		MainTab.TextColor3 = GREY
		DevTab.TextColor3 = GREY
		ChatTab.TextColor3 = GREY
		SettingsTab.TextColor3 = BLUE
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
			if self.DevLogRefresh then
				self.DevLogRefresh()
			end
		end)

	self.Gui = Gui
	self.Window = Window
	self.FairwellAnimationConnection = FairwellAnimationConnection

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
		"Main UI v3.9 initialized with 3D fairwelladmi avatar plus transparent thumbnail fallback."
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

	if self.FairwellAnimationConnection then
		self.FairwellAnimationConnection:Disconnect()
		self.FairwellAnimationConnection = nil
	end

	if self.Gui then
		self.Gui:Destroy()
		self.Gui = nil
	end

	self.Status = nil
end

return MainUI