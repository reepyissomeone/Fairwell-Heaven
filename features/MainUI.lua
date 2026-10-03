--// FAIRWELL HEAVEN
--// Main UI
--// Version 2.4
--// Draggable + Scrollable + Collapsible + Dynamic Status

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

------------------------------------------------------------
-- CREATE
------------------------------------------------------------

local function Create(ClassName, Properties, Parent)

	local Object = Instance.new(ClassName)

	for Property, Value in pairs(Properties) do
		Object[Property] = Value
	end

	Object.Parent = Parent

	return Object

end

------------------------------------------------------------
-- DRAGGING
------------------------------------------------------------

local function MakeDraggable(Window, DragHandle)

	local Dragging = false
	local DragStart = nil
	local StartPosition = nil
	local DragInput = nil

	local function Update(Input)

		if not Dragging then
			return
		end

		if not DragHandle.Active then
			return
		end

		local Delta =
			Input.Position - DragStart

		Window.Position = UDim2.new(

			StartPosition.X.Scale,
			StartPosition.X.Offset + Delta.X,

			StartPosition.Y.Scale,
			StartPosition.Y.Offset + Delta.Y

		)

	end

	DragHandle.InputBegan:Connect(function(Input)

		if not DragHandle.Active then
			return
		end

		if Input.UserInputType == Enum.UserInputType.MouseButton1
			or Input.UserInputType == Enum.UserInputType.Touch then

			Dragging = true

			DragStart =
				Input.Position

			StartPosition =
				Window.Position

			Input.Changed:Connect(function()

				if Input.UserInputState
					== Enum.UserInputState.End then

					Dragging = false

				end

			end)

		end

	end)

	DragHandle.InputChanged:Connect(function(Input)

		if Input.UserInputType
			== Enum.UserInputType.MouseMovement

			or Input.UserInputType
			== Enum.UserInputType.Touch then

			DragInput = Input

		end

	end)

	UserInputService.InputChanged:Connect(function(Input)

		if Input == DragInput
			and Dragging
			and DragHandle.Active then

			Update(Input)

		end

	end)

end

------------------------------------------------------------
-- SCROLL PAGE
------------------------------------------------------------

local function CreateScrollPage(Parent, Name)

	local Scroll = Create("ScrollingFrame", {

		Name = Name,

		Position = UDim2.fromScale(0, 0),

		Size = UDim2.fromScale(1, 1),

		BackgroundTransparency = 1,

		BorderSizePixel = 0,

		ScrollBarThickness = 6,

		ScrollBarImageColor3 = BLUE,

		ScrollBarImageTransparency = 0.15,

		ScrollingDirection =
			Enum.ScrollingDirection.Y,

		CanvasSize =
			UDim2.new(0, 0, 0, 900),

		AutomaticCanvasSize =
			Enum.AutomaticSize.None,

		ScrollingEnabled = true,

		Active = true,

		ElasticBehavior =
			Enum.ElasticBehavior.Always,

		ClipsDescendants = true,

		Visible = false

	}, Parent)

	return Scroll

end

------------------------------------------------------------
-- START
------------------------------------------------------------

function MainUI.Start(self, Hub)

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

	local Gui =
		PlayerGui:FindFirstChild(
			"FairwellHeaven_Main"
		)

	if not Gui then

		warn(
			"[Fairwell Heaven] Main GUI was not found."
		)

		return

	end

	local Window =
		Gui:FindFirstChild("Window")

	if not Window then

		warn(
			"[Fairwell Heaven] Loading window was not found."
		)

		return

	end

	self.Gui = Gui
	self.Window = Window

	------------------------------------------------------------
	-- TITLE BAR
	------------------------------------------------------------

	local TitleBar = Create("Frame", {

		Name = "TitleBar",

		Position = UDim2.fromScale(0, 0),

		Size = UDim2.new(
			1,
			0,
			0,
			48
		),

		BackgroundColor3 = PANEL,

		BorderSizePixel = 0,

		ZIndex = 10

	}, Window)

	------------------------------------------------------------
	-- DRAG HANDLE
	------------------------------------------------------------

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

	------------------------------------------------------------
	-- TITLE
	------------------------------------------------------------

	local Title = Create("TextLabel", {

		Name = "Title",

		Position = UDim2.new(
			0,
			14,
			0,
			4
		),

		Size = UDim2.new(
			0.6,
			0,
			0,
			23
		),

		BackgroundTransparency = 1,

		Text = "HACKER HEAVEN",

		TextColor3 = WHITE,

		TextSize = 18,

		Font = Enum.Font.GothamBold,

		TextXAlignment =
			Enum.TextXAlignment.Left,

		ZIndex = 15

	}, TitleBar)

	------------------------------------------------------------
	-- VERSION
	------------------------------------------------------------

	local Version = Create("TextLabel", {

		Name = "Version",

		Position = UDim2.new(
			0,
			14,
			0,
			27
		),

		Size = UDim2.new(
			0.6,
			0,
			0,
			15
		),

		BackgroundTransparency = 1,

		Text = "FAIRWELL HEAVEN • v2.4",

		TextColor3 = BLUE,

		TextSize = 10,

		Font = Enum.Font.GothamBold,

		TextXAlignment =
			Enum.TextXAlignment.Left,

		ZIndex = 15

	}, TitleBar)

	------------------------------------------------------------
	-- TOGGLE
	------------------------------------------------------------

	local ToggleButton = Create("TextButton", {

		Name = "ToggleButton",

		AnchorPoint =
			Vector2.new(1, 0.5),

		Position = UDim2.new(
			1,
			-10,
			0.5,
			0
		),

		Size = UDim2.fromOffset(
			32,
			28
		),

		BackgroundColor3 = BACKGROUND,

		BorderSizePixel = 0,

		Text = "−",

		TextColor3 = WHITE,

		TextSize = 20,

		Font = Enum.Font.GothamBold,

		AutoButtonColor = false,

		Active = true,

		ZIndex = 30

	}, TitleBar)

	local ToggleStroke = Create("UIStroke", {

		Color = BLUE,

		Thickness = 1

	}, ToggleButton)

	------------------------------------------------------------
	-- COLLAPSE STATE
	------------------------------------------------------------

	local Expanded = true

	local ExpandedPosition =
		Window.Position

	local ExpandedSize =
		Window.Size

	local CollapsedSize =
		UDim2.fromOffset(
			270,
			48
		)

	------------------------------------------------------------
	-- COLLAPSE
	------------------------------------------------------------

	local function Collapse()

		if not Expanded then
			return
		end

		Expanded = false

		--------------------------------------------------------
		-- SAVE CURRENT WINDOW STATE
		--------------------------------------------------------

		ExpandedPosition =
			Window.Position

		ExpandedSize =
			Window.Size

		--------------------------------------------------------
		-- DISABLE DRAGGING
		--------------------------------------------------------

		DragHandle.Active = false

		--------------------------------------------------------
		-- CHANGE BUTTON
		--------------------------------------------------------

		ToggleButton.Text = "+"

		--------------------------------------------------------
		-- MOVE TO BOTTOM
		--------------------------------------------------------

		local TargetPosition =
			UDim2.new(
				0.5,
				0,
				1,
				-12
			)

		local Tween =
			TweenService:Create(

				Window,

				TweenInfo.new(

					0.4,

					Enum.EasingStyle.Quint,

					Enum.EasingDirection.Out

				),

				{

					Position =
						TargetPosition,

					Size =
						CollapsedSize

				}

			)

		Tween:Play()

	end

	------------------------------------------------------------
	-- EXPAND
	------------------------------------------------------------

	local function Expand()

		if Expanded then
			return
		end

		Expanded = true

		--------------------------------------------------------
		-- BUTTON
		--------------------------------------------------------

		ToggleButton.Text = "−"

		--------------------------------------------------------
		-- RESTORE WINDOW
		--------------------------------------------------------

		local Tween =
			TweenService:Create(

				Window,

				TweenInfo.new(

					0.4,

					Enum.EasingStyle.Quint,

					Enum.EasingDirection.Out

				),

				{

					Position =
						ExpandedPosition,

					Size =
						ExpandedSize

				}

			)

		Tween:Play()

		Tween.Completed:Connect(function()

			----------------------------------------------------
			-- RE-ENABLE DRAGGING
			----------------------------------------------------

			if Expanded then

				DragHandle.Active =
					true

			end

		end)

	end

	------------------------------------------------------------
	-- TOGGLE CLICK
	------------------------------------------------------------

	ToggleButton.MouseButton1Click:Connect(function()

		if Expanded then

			Collapse()

		else

			Expand()

		end

	end)

	------------------------------------------------------------
	-- TAB BAR
	------------------------------------------------------------

	local TabBar = Create("Frame", {

		Name = "TabBar",

		Position = UDim2.new(
			0,
			0,
			0,
			48
		),

		Size = UDim2.new(
			1,
			0,
			0,
			40
		),

		BackgroundColor3 = BACKGROUND,

		BorderSizePixel = 0,

		ZIndex = 9

	}, Window)

	------------------------------------------------------------
	-- MAIN TAB
	------------------------------------------------------------

	local MainTab = Create("TextButton", {

		Name = "MainTab",

		Position = UDim2.new(
			0,
			10,
			0,
			6
		),

		Size = UDim2.new(
			0,
			100,
			0,
			28
		),

		BackgroundColor3 = BLUE,

		BorderSizePixel = 0,

		Text = "MAIN",

		TextColor3 = WHITE,

		TextSize = 13,

		Font = Enum.Font.GothamBold,

		AutoButtonColor = false,

		ZIndex = 10

	}, TabBar)

	------------------------------------------------------------
	-- DEV TAB
	------------------------------------------------------------

	local DevTab = Create("TextButton", {

		Name = "DevTab",

		Position = UDim2.new(
			0,
			116,
			0,
			6
		),

		Size = UDim2.new(
			0,
			100,
			0,
			28
		),

		BackgroundColor3 = PANEL,

		BorderSizePixel = 0,

		Text = "DEV",

		TextColor3 = GRAY,

		TextSize = 13,

		Font = Enum.Font.GothamBold,

		AutoButtonColor = false,

		ZIndex = 10

	}, TabBar)

	------------------------------------------------------------
	-- CONTENT
	------------------------------------------------------------

	local Content = Create("Frame", {

		Name = "Content",

		Position = UDim2.new(
			0,
			0,
			0,
			88
		),

		Size = UDim2.new(
			1,
			0,
			1,
			-88
		),

		BackgroundTransparency = 1,

		ClipsDescendants = true

	}, Window)

	------------------------------------------------------------
	-- SCROLLING PAGES
	------------------------------------------------------------

	local MainScroll =
		CreateScrollPage(
			Content,
			"MainScroll"
		)

	MainScroll.Visible = true

	local DevScroll =
		CreateScrollPage(
			Content,
			"DevScroll"
		)

	------------------------------------------------------------
	-- MAIN PAGE
	------------------------------------------------------------

	local MainPage = Create("Frame", {

		Name = "MainPage",

		Position = UDim2.new(
			0,
			12,
			0,
			12
		),

		Size = UDim2.new(
			1,
			-30,
			0,
			850
		),

		BackgroundTransparency = 1

	}, MainScroll)

	------------------------------------------------------------
	-- WELCOME
	------------------------------------------------------------

	Create("TextLabel", {

		Name = "Welcome",

		Position = UDim2.new(
			0,
			0,
			0,
			0
		),

		Size = UDim2.new(
			1,
			0,
			0,
			45
		),

		BackgroundTransparency = 1,

		Text = "WELCOME TO HACKER HEAVEN",

		TextColor3 = WHITE,

		TextSize = 24,

		Font = Enum.Font.GothamBold,

		TextXAlignment =
			Enum.TextXAlignment.Left

	}, MainPage)

	Create("TextLabel", {

		Name = "Description",

		Position = UDim2.new(
			0,
			0,
			0,
			48
		),

		Size = UDim2.new(
			1,
			0,
			0,
			45
		),

		BackgroundTransparency = 1,

		Text =
			"Fairwell Heaven modular feature hub.",

		TextColor3 = GRAY,

		TextSize = 14,

		Font = Enum.Font.Gotham,

		TextXAlignment =
			Enum.TextXAlignment.Left

	}, MainPage)

	------------------------------------------------------------
	-- STATUS PANEL
	------------------------------------------------------------

	local StatusPanel = Create("Frame", {

		Name = "StatusPanel",

		Position = UDim2.new(
			0,
			0,
			0,
			110
		),

		Size = UDim2.new(
			1,
			0,
			0,
			270
		),

		BackgroundColor3 = PANEL,

		BorderSizePixel = 0

	}, MainPage)

	Create("UIStroke", {

		Color = BLUE,

		Thickness = 2

	}, StatusPanel)

	Create("TextLabel", {

		Name = "StatusTitle",

		Position = UDim2.new(
			0,
			14,
			0,
			12
		),

		Size = UDim2.new(
			1,
			-28,
			0,
			30
		),

		BackgroundTransparency = 1,

		Text = "SYSTEM STATUS",

		TextColor3 = WHITE,

		TextSize = 18,

		Font = Enum.Font.GothamBold,

		TextXAlignment =
			Enum.TextXAlignment.Left

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

			Size = UDim2.new(
				1,
				-28,
				0,
				25
			),

			BackgroundTransparency = 1

		}, StatusPanel)

		Create("TextLabel", {

			Position = UDim2.new(
				0,
				0,
				0,
				0
			),

			Size = UDim2.new(
				0.38,
				0,
				1,
				0
			),

			BackgroundTransparency = 1,

			Text = Name,

			TextColor3 = GRAY,

			TextSize = 13,

			Font = Enum.Font.GothamBold,

			TextXAlignment =
				Enum.TextXAlignment.Left

		}, Row)

		local Value = Create("TextLabel", {

			Position = UDim2.new(
				0.38,
				0,
				0,
				0
			),

			Size = UDim2.new(
				0.62,
				0,
				1,
				0
			),

			BackgroundTransparency = 1,

			Text = "Loading...",

			TextColor3 = WHITE,

			TextSize = 13,

			Font = Enum.Font.Gotham,

			TextXAlignment =
				Enum.TextXAlignment.Right,

			TextTruncate =
				Enum.TextTruncate.AtEnd

		}, Row)

		Status[Name] = Value

	end

	------------------------------------------------------------
	-- FEATURE PANEL
	------------------------------------------------------------

	local FeaturePanel = Create("Frame", {

		Name = "FeaturePanel",

		Position = UDim2.new(
			0,
			0,
			0,
			400
		),

		Size = UDim2.new(
			1,
			0,
			0,
			300
		),

		BackgroundColor3 = PANEL,

		BorderSizePixel = 0

	}, MainPage)

	Create("UIStroke", {

		Color = BLUE,

		Thickness = 2

	}, FeaturePanel)

	Create("TextLabel", {

		Position = UDim2.new(
			0,
			14,
			0,
			12
		),

		Size = UDim2.new(
			1,
			-28,
			0,
			30
		),

		BackgroundTransparency = 1,

		Text = "FEATURES",

		TextColor3 = WHITE,

		TextSize = 18,

		Font = Enum.Font.GothamBold,

		TextXAlignment =
			Enum.TextXAlignment.Left

	}, FeaturePanel)

	local FeatureList = Create("TextLabel", {

		Position = UDim2.new(
			0,
			14,
			0,
			50
		),

		Size = UDim2.new(
			1,
			-28,
			0,
			230
		),

		BackgroundTransparency = 1,

		Text = "Loading features...",

		TextColor3 = GRAY,

		TextSize = 14,

		Font = Enum.Font.Gotham,

		TextXAlignment =
			Enum.TextXAlignment.Left,

		TextYAlignment =
			Enum.TextYAlignment.Top,

		TextWrapped = true

	}, FeaturePanel)

	------------------------------------------------------------
	-- DEV PAGE
	------------------------------------------------------------

	local DevPage = Create("Frame", {

		Name = "DevPage",

		Position = UDim2.new(
			0,
			12,
			0,
			12
		),

		Size = UDim2.new(
			1,
			-30,
			0,
			850
		),

		BackgroundTransparency = 1

	}, DevScroll)

	Create("TextLabel", {

		Name = "DevTitle",

		Position = UDim2.new(
			0,
			0,
			0,
			0
		),

		Size = UDim2.new(
			1,
			0,
			0,
			45
		),

		BackgroundTransparency = 1,

		Text = "DEVELOPMENT",

		TextColor3 = WHITE,

		TextSize = 24,

		Font = Enum.Font.GothamBold,

		TextXAlignment =
			Enum.TextXAlignment.Left

	}, DevPage)

	Create("TextLabel", {

		Name = "DevDescription",

		Position = UDim2.new(
			0,
			0,
			0,
			48
		),

		Size = UDim2.new(
			1,
			0,
			0,
			45
		),

		BackgroundTransparency = 1,

		Text =
			"Development tools and feature testing.",

		TextColor3 = GRAY,

		TextSize = 14,

		Font = Enum.Font.Gotham,

		TextXAlignment =
			Enum.TextXAlignment.Left

	}, DevPage)

	local DevPanel = Create("Frame", {

		Position = UDim2.new(
			0,
			0,
			0,
			110
		),

		Size = UDim2.new(
			1,
			0,
			0,
			400
		),

		BackgroundColor3 = PANEL,

		BorderSizePixel = 0

	}, DevPage)

	Create("UIStroke", {

		Color = BLUE,

		Thickness = 2

	}, DevPanel)

	Create("TextLabel", {

		Position = UDim2.new(
			0,
			16,
			0,
			16
		),

		Size = UDim2.new(
			1,
			-32,
			0,
			350
		),

		BackgroundTransparency = 1,

		Text =
			"DEVELOPER WORKSPACE\n\n"
			.. "This area is reserved for building "
			.. "and testing Fairwell Heaven features.\n\n"
			.. "New features can be added without "
			.. "replacing the main loader.",

		TextColor3 = GRAY,

		TextSize = 15,

		Font = Enum.Font.Gotham,

		TextXAlignment =
			Enum.TextXAlignment.Left,

		TextYAlignment =
			Enum.TextYAlignment.Top,

		TextWrapped = true

	}, DevPanel)

	------------------------------------------------------------
	-- TABS
	------------------------------------------------------------

	local function ShowMain()

		MainScroll.Visible = true
		DevScroll.Visible = false

		MainTab.BackgroundColor3 =
			BLUE

		MainTab.TextColor3 =
			WHITE

		DevTab.BackgroundColor3 =
			PANEL

		DevTab.TextColor3 =
			GRAY

	end

	local function ShowDev()

		MainScroll.Visible = false
		DevScroll.Visible = true

		MainTab.BackgroundColor3 =
			PANEL

		MainTab.TextColor3 =
			GRAY

		DevTab.BackgroundColor3 =
			BLUE

		DevTab.TextColor3 =
			WHITE

	end

	MainTab.MouseButton1Click:Connect(
		ShowMain
	)

	DevTab.MouseButton1Click:Connect(
		ShowDev
	)

	------------------------------------------------------------
	-- FEATURE LIST
	------------------------------------------------------------

	local function UpdateFeatureList()

		local Lines = {}

		for Name in pairs(Hub.Features) do

			local State

			if Hub:IsEnabled(Name) then

				State =
					"[ ENABLED ]"

			else

				State =
					"[ DISABLED ]"

			end

			table.insert(

				Lines,

				State
				.. "  "
				.. tostring(Name)

			)

		end

		table.sort(Lines)

		if #Lines == 0 then

			FeatureList.Text =
				"No features loaded."

		else

			FeatureList.Text =
				table.concat(
					Lines,
					"\n"
				)

		end

	end

	------------------------------------------------------------
	-- CURRENT ROOM
	------------------------------------------------------------

	local function GetCurrentRoom()

		local CurrentRooms =
			workspace:FindFirstChild(
				"CurrentRooms"
			)

		if not CurrentRooms then
			return "N/A"
		end

		local Highest = nil

		for _, Room in ipairs(
			CurrentRooms:GetChildren()
		) do

			local Number =
				tonumber(Room.Name)

			if Number then

				if not Highest
					or Number > Highest then

					Highest = Number

				end

			end

		end

		if Highest then

			return tostring(Highest)

		end

		return "N/A"

	end

	------------------------------------------------------------
	-- STATUS
	------------------------------------------------------------

	local function UpdateStatus()

		local PlaceId =
			game.PlaceId

		local GameName =
			"Unknown"

		pcall(function()

			GameName =
				game:GetService(
					"MarketplaceService"
				):GetProductInfo(
					PlaceId
				).Name

		end)

		Status["Game"].Text =
			GameName

		Status["Place ID"].Text =
			tostring(PlaceId)

		local IsDOORS =
			workspace:FindFirstChild(
				"CurrentRooms"
			) ~= nil

		if IsDOORS then

			local Room =
				GetCurrentRoom()

			Status["Current Room"].Text =
				Room

			Status["Current Door"].Text =
				Room ~= "N/A"
				and "Room " .. Room
				or "N/A"

		else

			Status["Current Room"].Text =
				"N/A"

			Status["Current Door"].Text =
				"N/A"

		end

		local Character =
			Player.Character

		local Root =
			Character
			and Character:FindFirstChild(
				"HumanoidRootPart"
			)

		if Root then

			local Position =
				Root.Position

			Status["Position"].Text =
				string.format(

					"%.1f, %.1f, %.1f",

					Position.X,
					Position.Y,
					Position.Z

				)

		else

			Status["Position"].Text =
				"N/A"

		end

		local Loaded = 0
		local Enabled = 0

		for _ in pairs(
			Hub.Features
		) do

			Loaded += 1

		end

		for _ in pairs(
			Hub.Enabled
		) do

			Enabled += 1

		end

		Status["Loaded Features"].Text =
			tostring(Loaded)

		Status["Enabled Features"].Text =
			tostring(Enabled)

	end

	------------------------------------------------------------
	-- DRAGGING
	------------------------------------------------------------

	MakeDraggable(
		Window,
		DragHandle
	)

	------------------------------------------------------------
	-- REFERENCES
	------------------------------------------------------------

	self.MainScroll =
		MainScroll

	self.DevScroll =
		DevScroll

	self.MainPage =
		MainPage

	self.DevPage =
		DevPage

	self.Status =
		Status

	self.UpdateStatus =
		UpdateStatus

	self.UpdateFeatureList =
		UpdateFeatureList

	self.ShowMain =
		ShowMain

	self.ShowDev =
		ShowDev

	self.ToggleButton =
		ToggleButton

	self.IsExpanded =
		function()

			return Expanded

		end

	------------------------------------------------------------
	-- LIVE STATUS
	------------------------------------------------------------

	self.StatusConnection =
		RunService.RenderStepped:Connect(
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

	Hub:Log(
		"Main UI created."
	)

end

------------------------------------------------------------
-- REVEAL
------------------------------------------------------------

function MainUI:Reveal()

	if not self.Window then
		return
	end

	if self.Revealed then
		return
	end

	self.Revealed = true

	if self.MainScroll then

		self.MainScroll.Visible =
			true

	end

	if self.DevScroll then

		self.DevScroll.Visible =
			false

	end

end

------------------------------------------------------------
-- STOP
------------------------------------------------------------

function MainUI.Stop(self, Hub)

	self.Revealed = false

	if self.StatusConnection then

		self.StatusConnection:Disconnect()

		self.StatusConnection =
			nil

	end

end

return MainUI