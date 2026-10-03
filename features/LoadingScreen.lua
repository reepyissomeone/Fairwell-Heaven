--// FAIRWELL HEAVEN
--// Loading Screen
--// Version 2.0

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local LoadingScreen = {
	Name = "Loading Screen",
	Description = "Fairwell Heaven startup screen."
}

local BLUE = Color3.fromRGB(27, 147, 227) -- #1B93E3
local BACKGROUND = Color3.fromRGB(6, 4, 43) -- #06042B
local WHITE = Color3.fromRGB(255, 255, 255)

function LoadingScreen.Start(self, Hub)

	local Player = Players.LocalPlayer

	if not Player then
		warn("[Fairwell Heaven] LocalPlayer not found.")
		return
	end

	local PlayerGui = Player:WaitForChild("PlayerGui")

	local Old = PlayerGui:FindFirstChild("FairwellHeaven_Main")

	if Old then
		Old:Destroy()
	end

	--==================================================
	-- SCREEN GUI
	--==================================================

	local Gui = Instance.new("ScreenGui")

	Gui.Name = "FairwellHeaven_Main"
	Gui.ResetOnSpawn = false
	Gui.IgnoreGuiInset = true
	Gui.DisplayOrder = 999999

	Gui.Parent = PlayerGui

	--==================================================
	-- LOADING WINDOW
	--==================================================

	local Window = Instance.new("Frame")

	Window.Name = "Window"
	Window.AnchorPoint = Vector2.new(0.5, 0.5)
	Window.Position = UDim2.fromScale(0.5, 0.5)

	-- Small loading size
	Window.Size = UDim2.fromScale(0.55, 0.32)

	Window.BackgroundColor3 = BACKGROUND
	Window.BorderSizePixel = 0

	Window.Parent = Gui

	--==================================================
	-- OUTLINE
	--==================================================

	local Outline = Instance.new("UIStroke")

	Outline.Name = "Outline"
	Outline.Color = BLUE
	Outline.Thickness = 4

	Outline.Parent = Window

	--==================================================
	-- LOADING TEXT
	--==================================================

	local Text = Instance.new("TextLabel")

	Text.Name = "LoadingText"

	Text.AnchorPoint = Vector2.new(0.5, 0.5)
	Text.Position = UDim2.fromScale(0.5, 0.5)
	Text.Size = UDim2.fromScale(0.8, 0.25)

	Text.BackgroundTransparency = 1

	Text.Text = "LOADING"
	Text.TextColor3 = WHITE
	Text.TextScaled = true
	Text.Font = Enum.Font.GothamBold

	Text.Parent = Window

	--==================================================
	-- ANIMATED DOTS
	--==================================================

	task.spawn(function()

		local Dots = {
			"",
			".",
			"..",
			"..."
		}

		local Index = 1

		while Gui.Parent and self.IsLoading do

			Text.Text = "LOADING" .. Dots[Index]

			Index += 1

			if Index > #Dots then
				Index = 1
			end

			task.wait(0.45)
		end

	end)

	self.Gui = Gui
	self.Window = Window
	self.Text = Text
	self.Outline = Outline

	self.IsLoading = true

	Hub:Log("Loading screen created.")

end

--======================================================
-- FINISH
--======================================================

function LoadingScreen:Finish(Hub)

	if not self.IsLoading then
		return
	end

	if not self.Gui or not self.Gui.Parent then
		return
	end

	self.IsLoading = false

	Hub:Log("All features loaded. Expanding interface.")

	--==================================================
	-- FADE LOADING TEXT
	--==================================================

	local TextFade = TweenInfo.new(
		0.45,
		Enum.EasingStyle.Quad,
		Enum.EasingDirection.Out
	)

	if self.Text then

		local TextTween = TweenService:Create(
			self.Text,
			TextFade,
			{
				TextTransparency = 1
			}
		)

		TextTween:Play()
		TextTween.Completed:Wait()

		self.Text.Visible = false
	end

	--==================================================
	-- EXPAND WINDOW
	--==================================================

	local MainUI = Hub:GetFeature("Main UI")

	if not MainUI then

		warn("[Fairwell Heaven] Main UI was not found.")

		return
	end

	local TargetSize = MainUI.TargetSize

	if not TargetSize then

		warn("[Fairwell Heaven] Main UI has no TargetSize.")

		return
	end

	local ExpandInfo = TweenInfo.new(
		0.65,
		Enum.EasingStyle.Quint,
		Enum.EasingDirection.Out
	)

	local ExpandTween = TweenService:Create(
		self.Window,
		ExpandInfo,
		{
			Size = TargetSize
		}
	)

	ExpandTween:Play()

	ExpandTween.Completed:Wait()

	--==================================================
	-- REVEAL MAIN UI
	--==================================================

	if MainUI.Reveal then
		MainUI:Reveal()
	end

	Hub:Log("Main interface ready.")

end

--======================================================
-- STOP
--======================================================

function LoadingScreen.Stop(self, Hub)

	self.IsLoading = false

	if self.Gui then
		self.Gui:Destroy()
	end

	self.Gui = nil
	self.Window = nil
	self.Text = nil
	self.Outline = nil

end

return LoadingScreen