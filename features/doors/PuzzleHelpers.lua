--// FAIRWELL HEAVEN
--// DOORS Puzzle Helpers
--// Non-destructive helper HUD for common puzzle objects.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Helpers = {
    Name = "DOORS Puzzle Helpers",
    Description = "Shows nearby puzzle/objective information and common puzzle counts.",
    Game = "DOORS",
    Gui = nil,
    Connection = nil
}

local function Normalize(Name)
    return string.lower(tostring(Name):gsub("[%s_%-%./]", ""))
end

local function Analyze(Room)
    local Counts = {Breaker=0, Books=0, Buttons=0, Anchors=0, Code=0, Lever=0}
    if not Room then return Counts end

    for _, Object in ipairs(Room:GetDescendants()) do
        local Name = Normalize(Object.Name)
        if string.find(Name, "breaker", 1, true) then Counts.Breaker += 1 end
        if string.find(Name, "book", 1, true) then Counts.Books += 1 end
        if string.find(Name, "button", 1, true) then Counts.Buttons += 1 end
        if string.find(Name, "anchor", 1, true) then Counts.Anchors += 1 end
        if string.find(Name, "code", 1, true) or string.find(Name, "padlock", 1, true) then Counts.Code += 1 end
        if string.find(Name, "lever", 1, true) then Counts.Lever += 1 end
    end

    return Counts
end

function Helpers.Start(self, Hub)
    local Settings = Hub:GetService("Settings")
    if Settings and Settings:GetFeatureEnabled(self.Name, false) == false then return false end

    local Doors = Hub:GetService("Doors")
    if not Doors then return false end

    local Player = Players.LocalPlayer
    local PlayerGui = Player:WaitForChild("PlayerGui")

    local Old = PlayerGui:FindFirstChild("FairwellHeaven_PuzzleHelpers")
    if Old then Old:Destroy() end

    local Gui = Instance.new("ScreenGui")
    Gui.Name = "FairwellHeaven_PuzzleHelpers"
    Gui.ResetOnSpawn = false
    Gui.IgnoreGuiInset = true
    Gui.DisplayOrder = 999997
    Gui.Parent = PlayerGui

    local Frame = Instance.new("Frame")
    Frame.Position = UDim2.new(1, -230, 0, 85)
    Frame.Size = UDim2.fromOffset(215, 130)
    Frame.BackgroundColor3 = Color3.fromRGB(8, 7, 35)
    Frame.BackgroundTransparency = 0.15
    Frame.BorderSizePixel = 0
    Frame.Parent = Gui

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 10)
    Corner.Parent = Frame

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(70, 175, 255)
    Stroke.Parent = Frame

    local Label = Instance.new("TextLabel")
    Label.Position = UDim2.fromOffset(10, 8)
    Label.Size = UDim2.new(1, -20, 1, -16)
    Label.BackgroundTransparency = 1
    Label.TextColor3 = Color3.fromRGB(235, 238, 250)
    Label.TextSize = 12
    Label.Font = Enum.Font.GothamBold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.TextYAlignment = Enum.TextYAlignment.Top
    Label.TextWrapped = true
    Label.Parent = Frame

    self.Gui = Gui

    local Timer = 0
    local function Refresh()
        local C = Analyze(Doors.CurrentRoom)
        Label.Text = "PUZZLE HELPERS\n\nBREAKERS: " .. C.Breaker
            .. "\nBOOKS: " .. C.Books
            .. "\nBUTTONS: " .. C.Buttons
            .. "\nANCHORS: " .. C.Anchors
            .. "\nCODE/PADLOCK: " .. C.Code
            .. "\nLEVERS: " .. C.Lever
    end

    Refresh()
    self.Connection = RunService.Heartbeat:Connect(function(Delta)
        Timer += Delta
        if Timer >= 0.5 then
            Timer = 0
            Refresh()
        end
    end)

    Hub:Log("DOORS Puzzle Helpers started.")
end

function Helpers.Stop(self)
    if self.Connection then self.Connection:Disconnect(); self.Connection=nil end
    if self.Gui then self.Gui:Destroy(); self.Gui=nil end
end

return Helpers
