--// FAIRWELL HEAVEN
--// Visual: Crosshair

local Players = game:GetService("Players")

local Crosshair = {
    Name = "VISUAL Crosshair",
    Description = "Adds a minimal center-screen crosshair.",
    Gui = nil
}

function Crosshair.Start(self, Hub)
    local Settings = Hub:GetService("Settings")
    if Settings and Settings:GetFeatureEnabled(self.Name, false) == false then return false end

    local Player = Players.LocalPlayer
    if not Player then return end
    local PlayerGui = Player:WaitForChild("PlayerGui")

    local Old = PlayerGui:FindFirstChild("FairwellHeaven_Crosshair")
    if Old then Old:Destroy() end

    local Gui = Instance.new("ScreenGui")
    Gui.Name = "FairwellHeaven_Crosshair"
    Gui.ResetOnSpawn = false
    Gui.IgnoreGuiInset = true
    Gui.DisplayOrder = 999996
    Gui.Parent = PlayerGui

    local Root = Instance.new("Frame")
    Root.AnchorPoint = Vector2.new(0.5, 0.5)
    Root.Position = UDim2.fromScale(0.5, 0.5)
    Root.Size = UDim2.fromOffset(32, 32)
    Root.BackgroundTransparency = 1
    Root.Parent = Gui

    local function Part(name, position, size)
        local P = Instance.new("Frame")
        P.Name = name
        P.Position = position
        P.Size = size
        P.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        P.BackgroundTransparency = 0.1
        P.BorderSizePixel = 0
        P.Parent = Root
    end

    Part("Top", UDim2.new(0.5, -1, 0, 0), UDim2.fromOffset(2, 10))
    Part("Bottom", UDim2.new(0.5, -1, 1, -10), UDim2.fromOffset(2, 10))
    Part("Left", UDim2.new(0, 0, 0.5, -1), UDim2.fromOffset(10, 2))
    Part("Right", UDim2.new(1, -10, 0.5, -1), UDim2.fromOffset(10, 2))

    self.Gui = Gui
    Hub:Log("Visual Crosshair started.")
end

function Crosshair.Stop(self)
    if self.Gui then self.Gui:Destroy(); self.Gui = nil end
end

return Crosshair
