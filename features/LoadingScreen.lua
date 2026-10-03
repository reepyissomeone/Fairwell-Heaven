--// FAIRWELL HEAVEN
--// Loading Screen
--// Version 1.2

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local LoadingScreen = {
	Name = "Loading Screen",
	Description = "Fairwell Heaven startup loading screen."
}

function LoadingScreen.Start(self, Hub)

	local Player = Players.LocalPlayer

	if not Player then
		warn("[Fairwell Heaven] LocalPlayer not found.")
		return
	end

	local PlayerGui = Player:WaitForChild("PlayerGui")

	--==================================================
	-- REMOVE OLD SCREEN
	--==================================================

	local Old = PlayerGui:FindFirstChild("FairwellHeaven_Loading")

	if Old then
		Old:Destroy()
	end

	--==================================================
	-- COLORS
	--==================================================

	local OUTLINE_COLOR = Color3.fromRGB(27, 147, 227)
	local BACKGROUND_COLOR = Color3.fromRGB(6, 4, 43)
	local TEXT_COLOR = Color3.fromRGB(255, 255, 255)

	--==================================================
	-- SCREEN GUI
	--==================================================

	local Gui = Instance.new("ScreenGui")

	Gui.Name = "FairwellHeaven_Loading"
	Gui.ResetOnSpawn = false
	Gui.IgnoreGuiInset = true
	Gui.DisplayOrder = 999999

	Gui.Parent = PlayerGui

	--==================================================
	-- MAIN PANEL
	--==================================================

	local Main = Instance.new("Frame")

	Main.Name = "Main"
	Main.AnchorPoint = Vector2.new(0.5, 0.5)
	Main.Position = UDim2.fromScale(0.5, 0.5)
	Main.Size = UDim2.fromScale(0.75, 0.5)

	Main.BackgroundColor3 = BACKGROUND_COLOR
	Main.BorderSizePixel = 0

	Main.Parent = Gui

	--==================================================
	-- OUTLINE
	--==================================================

	local Outline = Instance.new("UIStroke")

	Outline.Name = "Outline"
	Outline.Color = OUTLINE_COLOR
	Outline.Thickness = 4

	Outline.Parent = Main

	--==================================================
	-- LOADING TEXT
	--==================================================

	local Text = Instance.new("TextLabel")

	Text.Name = "Loading"

	Text.AnchorPoint = Vector2.new(0.5, 0.5)
	Text.Position = UDim2.fromScale(0.5, 0.5)
	Text.Size = UDim2.fromScale(0.8, 0.2)

	Text.BackgroundTransparency = 1

	Text.Text = "LOADING"
	Text.TextColor3 = TEXT_COLOR
	Text.TextScaled = true
	Text.Font = Enum.Font.GothamBold

	Text.Parent = Main

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

		while Gui.Parent do

			Text.Text = "LOADING" .. Dots[Index]

			Index += 1

			if Index > #Dots then
				Index = 1
			end

			task.wait(0.45)
		end

	end)

	--==================================================
	-- STORE REFERENCES
	--==================================================

	self.Gui = Gui
	self.Main = Main
	self.Text = Text
	self.Outline = Outline

	self.IsLoading = true

	Hub:Log("Loading screen created.")

end

--======================================================
-- FINISH LOADING
--======================================================

function LoadingScreen:Finish(Hub)

	if not self.IsLoading then
		return
	end

	if not self.Gui or not self.Gui.Parent then
		return
	end

	self.IsLoading = false

	Hub:Log("Main UI ready. Fading loading screen.")

	local FadeInfo = TweenInfo.new(
		0.6,
		Enum.EasingStyle.Quad,
		Enum.EasingDirection.Out
	)

	-- Fade text
	if self.Text then
		TweenService:Create(
			self.Text,
			FadeInfo,
			{
				TextTransparency = 1
			}
		):Play()
	end

	-- Fade outline
	if self.Outline then
		TweenService:Create(
			self.Outline,
			FadeInfo,
			{
				Transparency = 1
			}
		):Play()
	end

	-- Fade background
	if self.Main then
		TweenService:Create(
			self.Main,
			FadeInfo,
			{
				BackgroundTransparency = 1
			}
		):Play()
	end

	task.wait(0.65)

	if self.Gui then
		self.Gui:Destroy()
	end

	self.Gui = nil
	self.Main = nil
	self.Text = nil
	self.Outline = nil

	Hub:Log("Loading screen removed.")

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
	self.Main = nil
	self.Text = nil
	self.Outline = nil

end

return LoadingScreen