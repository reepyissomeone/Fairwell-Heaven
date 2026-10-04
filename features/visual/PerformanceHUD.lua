--// FAIRWELL HEAVEN
--// Visual: Performance HUD

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")

local PerformanceHUD = {
    Name = "VISUAL Performance HUD",
    Description = "Shows FPS and client memory usage.",
    Connection = nil,
    Gui = nil
}

function PerformanceHUD.Start(self, Hub)
    local Settings = Hub:GetService("Settings")
    if Settings and Settings:GetFeatureEnabled(self.Name, false) == false then return end

    local Player = Players.LocalPlayer
    if not Player then return end
    local PlayerGui = Player:WaitForChild("PlayerGui")

    local Old = PlayerGui:FindFirstChild("FairwellHeaven_PerformanceHUD")
    if Old then Old:Destroy() end

    local Gui = Instance.new("ScreenGui")
    Gui.Name = "FairwellHeaven_PerformanceHUD"
    Gui.ResetOnSpawn = false
    Gui.IgnoreGuiInset = true
    Gui.DisplayOrder = 999997
    Gui.Parent = PlayerGui

    local Frame = Instance.new("Frame")
    Frame.AnchorPoint = Vector2.new(1, 0)
    Frame.Position = UDim2.new(1, -14, 0, 14)
    Frame.Size = UDim2.fromOffset(180, 54)
    Frame.BackgroundColor3 = Color3.fromRGB(6, 4, 43)
    Frame.BackgroundTransparency = 0.18
    Frame.BorderSizePixel = 0
    Frame.Parent = Gui

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = Frame

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(27, 147, 227)
    Stroke.Thickness = 1
    Stroke.Parent = Frame

    local Label = Instance.new("TextLabel")
    Label.Position = UDim2.fromOffset(10, 7)
    Label.Size = UDim2.new(1, -20, 1, -14)
    Label.BackgroundTransparency = 1
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.TextSize = 11
    Label.Font = Enum.Font.Code
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.TextYAlignment = Enum.TextYAlignment.Center
    Label.Text = "FPS: --\nMEM: -- MB"
    Label.Parent = Frame

    self.Gui = Gui
    local Frames, Elapsed = 0, 0

    self.Connection = RunService.RenderStepped:Connect(function(Delta)
        Frames += 1
        Elapsed += Delta
        if Elapsed >= 0.75 then
            local FPS = math.floor((Frames / Elapsed) + 0.5)
            local Memory = "?"
            pcall(function()
                Memory = string.format("%.1f", Stats:GetTotalMemoryUsageMb())
            end)
            Label.Text = "FPS: " .. tostring(FPS) .. "\nMEM: " .. tostring(Memory) .. " MB"
            Frames, Elapsed = 0, 0
        end
    end)

    Hub:Log("Visual Performance HUD started.")
end

function PerformanceHUD.Stop(self)
    if self.Connection then self.Connection:Disconnect(); self.Connection = nil end
    if self.Gui then self.Gui:Destroy(); self.Gui = nil end
end

return PerformanceHUD
