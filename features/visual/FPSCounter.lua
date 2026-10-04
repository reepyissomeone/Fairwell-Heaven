--// FAIRWELL HEAVEN
--// Visual: FPS Counter

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local FPSCounter = {
    Name = "VISUAL FPS Counter",
    Description = "Shows a lightweight live FPS counter.",
    Connection = nil,
    Gui = nil
}

function FPSCounter.Start(self, Hub)
    local Settings = Hub:GetService("Settings")
    if Settings and Settings:GetFeatureEnabled(self.Name, true) == false then return false end

    local Player = Players.LocalPlayer
    if not Player then return end
    local PlayerGui = Player:WaitForChild("PlayerGui")

    local Old = PlayerGui:FindFirstChild("FairwellHeaven_FPSCounter")
    if Old then Old:Destroy() end

    local Gui = Instance.new("ScreenGui")
    Gui.Name = "FairwellHeaven_FPSCounter"
    Gui.ResetOnSpawn = false
    Gui.IgnoreGuiInset = true
    Gui.DisplayOrder = 999997
    Gui.Parent = PlayerGui

    local Label = Instance.new("TextLabel")
    Label.AnchorPoint = Vector2.new(0, 1)
    Label.Position = UDim2.new(0, 14, 1, -14)
    Label.Size = UDim2.fromOffset(92, 28)
    Label.BackgroundColor3 = Color3.fromRGB(6, 4, 43)
    Label.BackgroundTransparency = 0.2
    Label.BorderSizePixel = 0
    Label.Text = "FPS: --"
    Label.TextColor3 = Color3.fromRGB(90, 220, 140)
    Label.TextSize = 12
    Label.Font = Enum.Font.GothamBold
    Label.Parent = Gui

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 7)
    Corner.Parent = Label

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(27, 147, 227)
    Stroke.Thickness = 1
    Stroke.Parent = Label

    self.Gui = Gui
    local Frames, Elapsed = 0, 0

    self.Connection = RunService.RenderStepped:Connect(function(Delta)
        Frames += 1
        Elapsed += Delta
        if Elapsed >= 0.5 then
            local FPS = math.floor((Frames / Elapsed) + 0.5)
            Label.Text = "FPS: " .. tostring(FPS)
            Frames, Elapsed = 0, 0
        end
    end)

    Hub:Log("Visual FPS Counter started.")
end

function FPSCounter.Stop(self)
    if self.Connection then self.Connection:Disconnect(); self.Connection = nil end
    if self.Gui then self.Gui:Destroy(); self.Gui = nil end
end

return FPSCounter
