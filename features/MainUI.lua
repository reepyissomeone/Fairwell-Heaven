--// FAIRWELL HEAVEN
--// Main UI
--// Version 4.4
--// Adds animated minimized Fairwell notifications
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

		local PreviousRoom = self.LastRoomNumber

		if self.LastDisplayedRoom
			and self.LastDisplayedRoom ~= CurrentRoomNumber then
			self.RoomChangeCount = (self.RoomChangeCount or 0) + 1
			self.LastRoomNumber = self.LastDisplayedRoom
			PreviousRoom = self.LastRoomNumber
		end

		self.LastDisplayedRoom = CurrentRoomNumber

		self.PreviousRoomLabel.Text =
			"Previous Room: "
			.. tostring(PreviousRoom or "--")

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

	local Old = PlayerGui:FindFirstChild("FairwellHeaven_MainUI")
	if Old then
		Old:Destroy()
	end

	local Gui =
		Instance.new("ScreenGui")

	Gui.Name =
		"FairwellHeaven_MainUI"

	Gui.ResetOnSpawn = false
	Gui.IgnoreGuiInset = true
	Gui.DisplayOrder = 999999

	Gui.Enabled = false

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
		UDim2.fromScale(0.55, 0.32)

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
		"FAIRWELL HEAVEN • v4.2"

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
	ChatInfo.Text = "Artwork character • Fairwelladmi • Chat ready"

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

	local Bubble = Instance.new("TextLabel")
	Bubble.Name = "SpeechBubble"
	Bubble.Position = UDim2.new(0, 194, 0, 46)
	Bubble.Size = UDim2.new(1, -204, 0, 58)
	Bubble.BackgroundColor3 = PANEL
	Bubble.BackgroundTransparency = 0.02
	Bubble.BorderSizePixel = 0
	Bubble.Text = ""
	Bubble.TextColor3 = WHITE
	Bubble.TextSize = 11
	Bubble.Font = Enum.Font.Gotham
	Bubble.TextWrapped = true
	Bubble.TextXAlignment = Enum.TextXAlignment.Left
	Bubble.TextYAlignment = Enum.TextYAlignment.Center
	Bubble.ZIndex = 8
	Bubble.Parent = ChatStage

	local BubblePadding = Instance.new("UIPadding")
	BubblePadding.PaddingLeft = UDim.new(0, 10)
	BubblePadding.PaddingRight = UDim.new(0, 10)
	BubblePadding.PaddingTop = UDim.new(0, 6)
	BubblePadding.PaddingBottom = UDim.new(0, 6)
	BubblePadding.Parent = Bubble

	local BubbleCorner = Instance.new("UICorner")
	BubbleCorner.CornerRadius = UDim.new(0, 8)
	BubbleCorner.Parent = Bubble

	local BubbleStroke = Instance.new("UIStroke")
	BubbleStroke.Color = BLUE
	BubbleStroke.Transparency = 0.35
	BubbleStroke.Parent = Bubble

	local ChatMessages = Instance.new("ScrollingFrame")
	ChatMessages.Name = "Messages"
	ChatMessages.Position = UDim2.new(0, 194, 0, 112)
	ChatMessages.Size = UDim2.new(1, -204, 0, 152)
	ChatMessages.BackgroundColor3 = Color3.fromRGB(5, 4, 32)
	ChatMessages.BackgroundTransparency = 0.15
	ChatMessages.BorderSizePixel = 0
	ChatMessages.ScrollBarThickness = 3
	ChatMessages.ScrollBarImageColor3 = BLUE
	ChatMessages.AutomaticCanvasSize = Enum.AutomaticSize.Y
	ChatMessages.CanvasSize = UDim2.new(0, 0, 0, 0)
	ChatMessages.ZIndex = 7
	ChatMessages.Parent = ChatStage

	local ChatMessagesCorner = Instance.new("UICorner")
	ChatMessagesCorner.CornerRadius = UDim.new(0, 7)
	ChatMessagesCorner.Parent = ChatMessages

	local ChatMessagesPadding = Instance.new("UIPadding")
	ChatMessagesPadding.PaddingTop = UDim.new(0, 6)
	ChatMessagesPadding.PaddingBottom = UDim.new(0, 6)
	ChatMessagesPadding.PaddingLeft = UDim.new(0, 6)
	ChatMessagesPadding.PaddingRight = UDim.new(0, 6)
	ChatMessagesPadding.Parent = ChatMessages

	local ChatMessagesLayout = Instance.new("UIListLayout")
	ChatMessagesLayout.Padding = UDim.new(0, 5)
	ChatMessagesLayout.SortOrder = Enum.SortOrder.LayoutOrder
	ChatMessagesLayout.Parent = ChatMessages

	local function AddChatMessage(Author, Message, TextColor)
		local Row = Instance.new("TextLabel")
		Row.Name = "Message"
		Row.Size = UDim2.new(1, -4, 0, 34)
		Row.AutomaticSize = Enum.AutomaticSize.Y
		Row.BackgroundTransparency = 1
		Row.Text = tostring(Author) .. ": " .. tostring(Message)
		Row.TextColor3 = TextColor or WHITE
		Row.TextSize = 9
		Row.Font = Enum.Font.Gotham
		Row.TextWrapped = true
		Row.TextXAlignment = Enum.TextXAlignment.Left
		Row.TextYAlignment = Enum.TextYAlignment.Center
		Row.LayoutOrder = math.floor(os.clock() * 1000)
		Row.ZIndex = 8
		Row.Parent = ChatMessages

		task.defer(function()
			if ChatMessages.Parent then
				ChatMessages.CanvasPosition = Vector2.new(
					0,
					math.max(0, ChatMessages.AbsoluteCanvasSize.Y)
				)
			end
		end)

		return Row
	end

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

	-- Artwork replaces the former 3D viewport/avatar scene.

	--==================================================
	-- FAIRWELL ARTWORK
	--==================================================
	-- Fairwell is rendered entirely from the supplied artwork assets.
	-- No Roblox avatar model, ViewportFrame, Animate script, or 3D avatar API is used.

	local FairwellArtwork = Instance.new("ImageLabel")
	FairwellArtwork.Name = "FairwellArtwork"
	FairwellArtwork.Position = UDim2.new(0, 10, 0, 52)
	FairwellArtwork.Size = UDim2.fromOffset(170, 210)
	FairwellArtwork.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	FairwellArtwork.BackgroundTransparency = 0
	FairwellArtwork.BorderSizePixel = 0
	FairwellArtwork.Image = ""
	FairwellArtwork.ScaleType = Enum.ScaleType.Fit
	FairwellArtwork.ZIndex = 4
	FairwellArtwork.Parent = ChatStage

	local FairwellArtworkCorner = Instance.new("UICorner")
	FairwellArtworkCorner.CornerRadius = UDim.new(0, 10)
	FairwellArtworkCorner.Parent = FairwellArtwork

	local FairwellArtworkStroke = Instance.new("UIStroke")
	FairwellArtworkStroke.Color = BLUE
	FairwellArtworkStroke.Transparency = 0.25
	FairwellArtworkStroke.Parent = FairwellArtwork

	local AvatarName = Instance.new("TextLabel")
	AvatarName.Name = "AvatarName"
	AvatarName.Position = UDim2.new(0, 10, 0, 238)
	AvatarName.Size = UDim2.fromOffset(170, 22)
	AvatarName.BackgroundTransparency = 1
	AvatarName.Text = "@fairwelladmi • ARTWORK"
	AvatarName.TextColor3 = GREY
	AvatarName.TextSize = 9
	AvatarName.Font = Enum.Font.GothamBold
	AvatarName.TextXAlignment = Enum.TextXAlignment.Center
	AvatarName.ZIndex = 12
	AvatarName.Parent = ChatStage

	local FAIRWELL_ASSET_BASE = "https://raw.githubusercontent.com/reepyissomeone/Fairwell-Heaven/main/assets/Fairwell/"
	local FairwellArtworkUrls = {
		Silent = FAIRWELL_ASSET_BASE .. "Silent.png",
		Talking = FAIRWELL_ASSET_BASE .. "talking.png",
		Thinking = FAIRWELL_ASSET_BASE .. "thinking.png"
	}

	local MiniArtworkUrls = {
		Body = FAIRWELL_ASSET_BASE .. "Fairwellmini.png",
		Arms = FAIRWELL_ASSET_BASE .. "Fairwellminiarms.png"
	}

	local FairwellArtworkFiles = {
		Silent = "FairwellHeaven/assets/Fairwell/Silent.png",
		Talking = "FairwellHeaven/assets/Fairwell/talking.png",
		Thinking = "FairwellHeaven/assets/Fairwell/thinking.png"
	}

	local MiniArtworkFiles = {
		Body = "FairwellHeaven/assets/Fairwell/Fairwellmini.png",
		Arms = "FairwellHeaven/assets/Fairwell/Fairwellminiarms.png"
	}

	local FairwellArtworkImages = {}
	local MiniArtworkImages = {}

	local function GetCustomAssetLoader()
		if type(getcustomasset) == "function" then
			return getcustomasset
		end
		if type(getsynasset) == "function" then
			return getsynasset
		end
		if type(getcustomassetfromfile) == "function" then
			return getcustomassetfromfile
		end
		return nil
	end

	local function EnsureFolder(Path)
		if type(makefolder) ~= "function" then
			return
		end

		local Parts = {}
		for Part in string.gmatch(Path, "[^/]+") do
			table.insert(Parts, Part)
		end

		local Current = ""
		for _, Part in ipairs(Parts) do
			Current = Current == "" and Part or Current .. "/" .. Part
			pcall(makefolder, Current)
		end
	end

	local function SetFairwellArtwork(State)
		State = State == "Talking" and "Talking" or State == "Thinking" and "Thinking" or "Silent"
		local Image = FairwellArtworkImages[State]
		if Image and Image ~= "" then FairwellArtwork.Image = Image end
		StageStatus.Text = State == "Talking" and "● TALKING" or State == "Thinking" and "● THINKING" or "● ONLINE"
	end

	local function DownloadFairwellArtwork(State)
		local FilePath = FairwellArtworkFiles[State]
		local Url = FairwellArtworkUrls[State]
		local AssetLoader = GetCustomAssetLoader()

		if not FilePath or not Url then
			Hub:Log("Missing Fairwell artwork configuration for " .. tostring(State), "ERROR")
			return false
		end

		if not AssetLoader then
			Hub:Log("This executor does not expose a custom-asset loader; Fairwell artwork cannot be displayed.", "WARN")
			return false
		end

		local Success, AssetOrError = pcall(function()
			EnsureFolder("FairwellHeaven/assets/Fairwell")

			if type(isfile) == "function" and isfile(FilePath) then
				return AssetLoader(FilePath)
			end

			if type(writefile) ~= "function" then
				error("writefile is unavailable")
			end

			local HttpSuccess, Data = pcall(function()
				return game:HttpGet(Url .. "?cache=" .. tostring(math.floor(os.clock() * 1000000)))
			end)

			if not HttpSuccess or type(Data) ~= "string" or Data == "" then
				error("download failed")
			end

			writefile(FilePath, Data)
			return AssetLoader(FilePath)
		end)

		if Success and type(AssetOrError) == "string" and AssetOrError ~= "" then
			FairwellArtworkImages[State] = AssetOrError
			return true
		end

		Hub:Log("Failed to load Fairwell " .. State .. " artwork: " .. tostring(AssetOrError), "WARN")
		return false
	end

	local function DownloadMiniArtwork(Name)
		local FilePath = MiniArtworkFiles[Name]
		local Url = MiniArtworkUrls[Name]
		local AssetLoader = GetCustomAssetLoader()

		if not FilePath or not Url or not AssetLoader then
			return false
		end

		local Success, AssetOrError = pcall(function()
			EnsureFolder("FairwellHeaven/assets/Fairwell")

			if type(isfile) == "function" and isfile(FilePath) then
				return AssetLoader(FilePath)
			end

			if type(writefile) ~= "function" then
				error("writefile is unavailable")
			end

			local HttpSuccess, Data = pcall(function()
				return game:HttpGet(Url .. "?cache=" .. tostring(math.floor(os.clock() * 1000000)))
			end)

			if not HttpSuccess or type(Data) ~= "string" or Data == "" then
				error("download failed")
			end

			writefile(FilePath, Data)
			return AssetLoader(FilePath)
		end)

		if Success and type(AssetOrError) == "string" and AssetOrError ~= "" then
			MiniArtworkImages[Name] = AssetOrError
			return true
		end

		Hub:Log("Failed to load Fairwell mini artwork: " .. tostring(Name) .. " / " .. tostring(AssetOrError), "WARN")
		return false
	end
	-- Load the artwork before the chat starts so the first message and every
	-- later chat state can immediately switch images.
	local FairwellArtworkReady = false
	for _, State in ipairs({"Silent", "Talking", "Thinking"}) do
		DownloadFairwellArtwork(State)
	end

	if FairwellArtworkImages.Silent then
		FairwellArtworkReady = true
		SetFairwellArtwork("Silent")
	else
		Hub:Log("No Fairwell artwork could be loaded.", "ERROR")
	end

	if not FairwellArtworkImages.Talking then
		Hub:Log("Talking artwork is unavailable; chat will keep the current artwork.", "WARN")
	end
	if not FairwellArtworkImages.Thinking then
		Hub:Log("Thinking artwork is unavailable; chat will keep the current artwork.", "WARN")
	end

	for _, Name in ipairs({"Body", "Arms"}) do
		DownloadMiniArtwork(Name)
	end

	Hub:Log(
		"Fairwell artwork system initialized"
		.. (FairwellArtworkReady and " and chat is ready." or "."),
		"SUCCESS"
	)

	--==================================================
	-- MINIMIZED FAIRWELL NOTIFICATIONS
	--==================================================
	-- When the main window is collapsed, Fairwell can temporarily appear
	-- above the mini bar and speak the same message as Hub:Notify.

	local MiniRoot = Instance.new("Frame")
	MiniRoot.Name = "FairwellMiniNotification"
	MiniRoot.AnchorPoint = Vector2.new(0.5, 1)
	MiniRoot.Size = UDim2.fromOffset(320, 258)
	MiniRoot.BackgroundTransparency = 1
	MiniRoot.Visible = false
	MiniRoot.ZIndex = 60
	MiniRoot.Parent = Gui

	local MiniScale = Instance.new("UIScale")
	MiniScale.Scale = 0.86
	MiniScale.Parent = MiniRoot

	local MiniBubble = Instance.new("TextLabel")
	MiniBubble.Name = "SpeechBubble"
	MiniBubble.Position = UDim2.fromOffset(10, 4)
	MiniBubble.Size = UDim2.new(1, -20, 0, 72)
	MiniBubble.BackgroundColor3 = PANEL
	MiniBubble.BackgroundTransparency = 0.02
	MiniBubble.BorderSizePixel = 0
	MiniBubble.Text = ""
	MiniBubble.TextColor3 = WHITE
	MiniBubble.TextSize = 12
	MiniBubble.Font = Enum.Font.GothamBold
	MiniBubble.TextWrapped = true
	MiniBubble.TextXAlignment = Enum.TextXAlignment.Center
	MiniBubble.TextYAlignment = Enum.TextYAlignment.Center
	MiniBubble.ZIndex = 63
	MiniBubble.Parent = MiniRoot

	local MiniBubbleCorner = Instance.new("UICorner")
	MiniBubbleCorner.CornerRadius = UDim.new(0, 12)
	MiniBubbleCorner.Parent = MiniBubble

	local MiniBubbleStroke = Instance.new("UIStroke")
	MiniBubbleStroke.Color = BLUE
	MiniBubbleStroke.Thickness = 2
	MiniBubbleStroke.Parent = MiniBubble

	local MiniTail = Instance.new("Frame")
	MiniTail.Name = "Tail"
	MiniTail.AnchorPoint = Vector2.new(0.5, 0.5)
	MiniTail.Position = UDim2.new(0.5, 0, 0, 75)
	MiniTail.Size = UDim2.fromOffset(18, 18)
	MiniTail.Rotation = 45
	MiniTail.BackgroundColor3 = PANEL
	MiniTail.BorderSizePixel = 0
	MiniTail.ZIndex = 61
	MiniTail.Parent = MiniRoot

	local MiniAvatar = Instance.new("ImageLabel")
	MiniAvatar.Name = "Body"
	MiniAvatar.Position = UDim2.fromOffset(80, 82)
	MiniAvatar.Size = UDim2.fromOffset(160, 160)
	MiniAvatar.BackgroundTransparency = 1
	MiniAvatar.BorderSizePixel = 0
	MiniAvatar.Image = ""
	MiniAvatar.ScaleType = Enum.ScaleType.Fit
	MiniAvatar.ZIndex = 60
	MiniAvatar.Parent = MiniRoot

	local MiniArms = Instance.new("ImageLabel")
	MiniArms.Name = "Arms"
	MiniArms.Position = MiniAvatar.Position
	MiniArms.Size = MiniAvatar.Size
	MiniArms.BackgroundTransparency = 1
	MiniArms.BorderSizePixel = 0
	MiniArms.Image = ""
	MiniArms.ScaleType = Enum.ScaleType.Fit
	MiniArms.ZIndex = 61
	MiniArms.Parent = MiniRoot

	local MiniNotificationQueue = {}
	local MiniNotificationShowing = false
	local MiniNotificationToken = 0
	local MiniArmsTween

	local function UpdateMiniPosition()
		if not Window or not Window.Parent then
			return
		end

		local CenterX = Window.AbsolutePosition.X + (Window.AbsoluteSize.X * 0.5)
		local TopY = Window.AbsolutePosition.Y - 6
		MiniRoot.Position = UDim2.fromOffset(CenterX, TopY)
	end

	local function StopMiniAnimation()
		MiniNotificationToken += 1
		if MiniArmsTween then
			MiniArmsTween:Cancel()
			MiniArmsTween = nil
		end
	end

	local function HideMiniNotification(Immediate)
		StopMiniAnimation()

		if not MiniRoot.Visible then
			return
		end

		if Immediate then
			MiniRoot.Visible = false
			MiniScale.Scale = 0.86
			MiniBubble.BackgroundTransparency = 0.02
			MiniBubble.TextTransparency = 0
			MiniAvatar.ImageTransparency = 0
			MiniArms.ImageTransparency = 0
			return
		end

		local FadeInfo = TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
		TweenService:Create(MiniScale, FadeInfo, {Scale = 0.86}):Play()
		TweenService:Create(MiniBubble, FadeInfo, {BackgroundTransparency = 1, TextTransparency = 1}):Play()
		TweenService:Create(MiniAvatar, FadeInfo, {ImageTransparency = 1}):Play()
		TweenService:Create(MiniArms, FadeInfo, {ImageTransparency = 1}):Play()
		task.delay(0.3, function()
			MiniRoot.Visible = false
		end)
	end

	local function ShowMiniNotification(TitleText, MessageText, Kind)
		if not self.Collapsed or not Gui.Enabled then
			return
		end
		if not MiniArtworkImages.Body or not MiniArtworkImages.Arms then
			return
		end

		MiniNotificationShowing = true
		MiniNotificationToken += 1
		local ThisToken = MiniNotificationToken

		local KindName = string.upper(tostring(Kind or "INFO"))
		local Accent = KindName == "ERROR" and Color3.fromRGB(255, 75, 90)
			or KindName == "WARNING" and Color3.fromRGB(255, 175, 55)
			or KindName == "SUCCESS" and Color3.fromRGB(70, 210, 130)
			or BLUE

		UpdateMiniPosition()
		MiniRoot.Visible = true
		MiniScale.Scale = 0.82
		MiniBubble.BackgroundTransparency = 0.02
		MiniBubble.TextTransparency = 0
		MiniAvatar.ImageTransparency = 0
		MiniArms.ImageTransparency = 0
		MiniBubbleStroke.Color = Accent
		MiniBubble.Text = string.upper(tostring(TitleText or "FAIRWELL")) .. "\n" .. tostring(MessageText or "")
		MiniAvatar.Image = MiniArtworkImages.Body
		MiniArms.Image = MiniArtworkImages.Arms
		MiniArms.Rotation = 0

		TweenService:Create(MiniScale, TweenInfo.new(0.42, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1}):Play()

		task.spawn(function()
			while MiniRoot.Visible and MiniNotificationShowing and ThisToken == MiniNotificationToken do
				MiniArmsTween = TweenService:Create(MiniArms, TweenInfo.new(0.42, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Rotation = -5})
				MiniArmsTween:Play()
			MiniArmsTween.Completed:Wait()
				if ThisToken ~= MiniNotificationToken then break end
				MiniArmsTween = TweenService:Create(MiniArms, TweenInfo.new(0.42, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Rotation = 5})
				MiniArmsTween:Play()
				MiniArmsTween.Completed:Wait()
			end
		end)

		local Duration = math.clamp(1.8 + (#tostring(MessageText or "") * 0.035), 2.4, 5.5)
		task.delay(Duration, function()
			if ThisToken ~= MiniNotificationToken then
				return
			end
			HideMiniNotification(false)
			task.delay(0.32, function()
				if ThisToken == MiniNotificationToken then
					MiniNotificationShowing = false
					ProcessMiniNotificationQueue()
				end
			end)
		end)
	end

	local function ProcessMiniNotificationQueue()
		if MiniNotificationShowing or not self.Collapsed then
			return
		end

		local Next = table.remove(MiniNotificationQueue, 1)
		if not Next then
			return
		end

		ShowMiniNotification(Next.Title, Next.Message, Next.Kind)
	end

	if Hub.NotificationEvent then
		self.MiniNotificationConnection = Hub.NotificationEvent.Event:Connect(function(TitleText, MessageText, Kind)
			if not self.Collapsed then
				return
			end

			table.insert(MiniNotificationQueue, {
				Title = TitleText,
				Message = MessageText,
				Kind = Kind
			})
			ProcessMiniNotificationQueue()
		end)
	end

	local FairwellSpeechId = 0

	local function FairwellSpeak(Text)
		FairwellSpeechId += 1
		local ThisSpeech = FairwellSpeechId
		SetFairwellArtwork("Talking")
		Bubble.Text = tostring(Text)
		Bubble.BackgroundTransparency = 0.02
		local Duration = math.max(1.5, math.min(5, #tostring(Text) * 0.055))

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

		task.delay(Duration, function()
			if ThisSpeech == FairwellSpeechId and ChatStage.Parent then
				SetFairwellArtwork("Silent")
			end
		end)
	end
	FairwellSpeak("Hey! I'm Fairwell. Talk to me.")
	AddChatMessage("FAIRWELL", "Hey! I'm Fairwell. Talk to me.", BLUE)

	local ChatInput = Instance.new("TextBox")
	ChatInput.Name = "Input"
	ChatInput.Position = UDim2.new(0, 5, 0, 352)
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

	local function FairwellReply(Message)
		local Lower = string.lower(tostring(Message))

		local Replies = {
			{"hello", "Hello. I was wondering when you'd show up."},
			{"hi", "Hi. I'm Fairwell. What's going on?"},
			{"hey", "Hey. I'm listening."},
			{"who are you", "I'm Fairwell. The one sitting in the corner of this UI."},
			{"fairwell", "You called? I'm right here."},
			{"help", "Try /help if you want to see the chat commands."},
			{"doors", "DOORS detected. Keep an eye on that next room."},
			{"scary", "Good. It would be boring if everything felt safe."},
			{"thank", "You're welcome."},
			{"thanks", "You're welcome."},
			{"bye", "See you later."}
		}

		for _, Entry in ipairs(Replies) do
			local Key = Entry[1]
			if Lower == Key or string.find(Lower, "%f[%a]" .. Key .. "%f[%A]") then
				return Entry[2]
			end
		end

		return "I heard you. Tell me more."
	end

	local SendButton = Instance.new("TextButton")
	SendButton.Name = "Send"
	SendButton.Position = UDim2.new(1, -64, 0, 352)
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
		SetFairwellArtwork("Thinking")
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