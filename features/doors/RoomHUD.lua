--// FAIRWELL HEAVEN
--// DOORS Room HUD
--// Lightweight live room/door overlay

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local RoomHUD = {
    Name = "DOORS Room HUD",
    Description = "Shows the current DOORS room and tracked door.",
    Game = "DOORS",
    Gui = nil,
    Connection = nil
}

local function Label(parent, name, text, position, size)
    local L = Instance.new("TextLabel")
    L.Name = name
    L.Position = position
    L.Size = size
    L.BackgroundTransparency = 1
    L.Text = text
    L.TextColor3 = Color3.fromRGB(255,255,255)
    L.TextStrokeTransparency = 0.45
    L.TextSize = 16
    L.Font = Enum.Font.GothamBold
    L.TextXAlignment = Enum.TextXAlignment.Left
    L.Parent = parent
    return L
end

function RoomHUD.Start(self, Hub)
    local Settings = Hub:GetService("Settings")
    if Settings and Settings:GetFeatureEnabled(self.Name, true) == false then return end

    local Player = Players.LocalPlayer
    if not Player then return end

    local PlayerGui = Player:WaitForChild("PlayerGui")
    local Old = PlayerGui:FindFirstChild("FairwellHeaven_RoomHUD")
    if Old then Old:Destroy() end

    local Gui = Instance.new("ScreenGui")
    Gui.Name = "FairwellHeaven_RoomHUD"
    Gui.ResetOnSpawn = false
    Gui.IgnoreGuiInset = true
    Gui.DisplayOrder = 999998
    Gui.Parent = PlayerGui

    local Frame = Instance.new("Frame")
    Frame.Name = "Info"
    Frame.Position = UDim2.new(0, 14, 0, 14)
    Frame.Size = UDim2.fromOffset(220, 82)
    Frame.BackgroundColor3 = Color3.fromRGB(6,4,43)
    Frame.BackgroundTransparency = 0.2
    Frame.BorderSizePixel = 0
    Frame.Parent = Gui

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(27,147,227)
    Stroke.Thickness = 1
    Stroke.Parent = Frame

    self.RoomLabel = Label(Frame, "Room", "ROOM: --", UDim2.new(0,10,0,4), UDim2.new(1,-20,0,22))
    self.DoorLabel = Label(Frame, "Door", "DOOR: --", UDim2.new(0,10,0,28), UDim2.new(1,-20,0,22))
    self.ThreatLabel = Label(Frame, "Threat", "THREAT: CLEAR", UDim2.new(0,10,0,52), UDim2.new(1,-20,0,22))
    self.Gui = Gui

    self.Connection = RunService.Heartbeat:Connect(function()
        if not self.Gui or not self.Gui.Parent then return end
        local Doors = Hub:GetService("Doors")
        local Room = Doors and Doors.CurrentRoom
        local Door = Doors and Doors.CurrentDoor
        local RoomNumber = Doors and Doors:GetRoomNumber(Room)
        self.RoomLabel.Text = "ROOM: " .. tostring(RoomNumber or "--")
        self.DoorLabel.Text = "DOOR: " .. (Door and "FOUND" or "SEARCHING")

        local Brain = Hub:GetFeature("Fairwell Companion Brain")
        local threat = "CLEAR"
        if Brain and type(Brain.ActiveEntity) == "table" then
            for entity, active in pairs(Brain.ActiveEntity) do
                if active then
                    threat = string.upper(tostring(entity))
                    break
                end
            end
        end
        self.ThreatLabel.Text = "THREAT: " .. threat
        self.ThreatLabel.TextColor3 = threat == "CLEAR" and Color3.fromRGB(255,255,255) or Color3.fromRGB(255,185,70)
    end)

    Hub:Log("DOORS Room HUD started.")
end

function RoomHUD.Stop(self)
    if self.Connection then
        self.Connection:Disconnect()
        self.Connection = nil
    end
    if self.Gui then
        self.Gui:Destroy()
        self.Gui = nil
    end
end

return RoomHUD
