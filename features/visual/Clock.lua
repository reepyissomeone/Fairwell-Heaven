--// FAIRWELL HEAVEN
--// Visual: Clock

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Clock = {
    Name = "VISUAL Clock",
    Description = "Shows the local time in a compact overlay.",
    Connection = nil,
    Gui = nil
}

function Clock.Start(self, Hub)
    local Settings = Hub:GetService("Settings")
    if Settings and Settings:GetFeatureEnabled(self.Name, true) == false then return end

    local Player = Players.LocalPlayer
    if not Player then return end
    local PlayerGui = Player:WaitForChild("PlayerGui")

    local Old = PlayerGui:FindFirstChild("FairwellHeaven_Clock")
    if Old then Old:Destroy() end

    local Gui = Instance.new("ScreenGui")
    Gui.Name = "FairwellHeaven_Clock"
    Gui.ResetOnSpawn = false
    Gui.IgnoreGuiInset = true
    Gui.DisplayOrder = 999997
    Gui.Parent = PlayerGui

    local Label = Instance.new("TextLabel")
    Label.AnchorPoint = Vector2.new(0.5, 0)
    Label.Position = UDim2.new(0.5, 0, 0, 12)
    Label.Size = UDim2.fromOffset(130, 28)
    Label.BackgroundColor3 = Color3.fromRGB(6, 4, 43)
    Label.BackgroundTransparency = 0.2
    Label.BorderSizePixel = 0
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
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

    local LastSecond = -1
    self.Connection = RunService.Heartbeat:Connect(function()
        local Now = os.date("*t")
        if Now.sec ~= LastSecond then
            LastSecond = Now.sec
            Label.Text = string.format("%02d:%02d:%02d", Now.hour, Now.min, Now.sec)
        end
    end)

    Hub:Log("Visual Clock started.")
end

function Clock.Stop(self)
    if self.Connection then self.Connection:Disconnect(); self.Connection = nil end
    if self.Gui then self.Gui:Destroy(); self.Gui = nil end
end

return Clock
