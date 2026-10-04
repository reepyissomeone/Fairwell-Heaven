--// FAIRWELL HEAVEN
--// DOORS: Room Timer

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local RoomTimer = {
    Name = "DOORS Room Timer",
    Description = "Shows the current room and time spent in it.",
    Game = "DOORS",
    RoomConnection = nil,
    Heartbeat = nil,
    Gui = nil,
    EnteredAt = 0,
    RoomNumber = "--"
}

function RoomTimer.Start(self, Hub)
    local Settings = Hub:GetService("Settings")
    if Settings and Settings:GetFeatureEnabled(self.Name, false) == false then
        return false
    end

    local Doors = Hub:GetService("Doors")
    if not Doors then
        return false
    end

    local Player = Players.LocalPlayer
    if not Player then
        return false
    end

    local PlayerGui = Player:WaitForChild("PlayerGui")
    local Old = PlayerGui:FindFirstChild("FairwellHeaven_RoomTimer")
    if Old then Old:Destroy() end

    local Gui = Instance.new("ScreenGui")
    Gui.Name = "FairwellHeaven_RoomTimer"
    Gui.ResetOnSpawn = false
    Gui.IgnoreGuiInset = true
    Gui.DisplayOrder = 999997
    Gui.Parent = PlayerGui

    local Label = Instance.new("TextLabel")
    Label.AnchorPoint = Vector2.new(1, 0)
    Label.Position = UDim2.new(1, -14, 0, 14)
    Label.Size = UDim2.fromOffset(150, 34)
    Label.BackgroundColor3 = Color3.fromRGB(6, 4, 43)
    Label.BackgroundTransparency = 0.15
    Label.BorderSizePixel = 0
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.TextSize = 11
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
    self.EnteredAt = os.clock()

    local function SetRoom(Room)
        local Number = "--"
        if Room and Doors.GetRoomNumber then
            Number = tostring(Doors:GetRoomNumber(Room) or "--")
        end
        self.RoomNumber = Number
        self.EnteredAt = os.clock()
    end

    SetRoom(Doors.CurrentRoom)

    self.RoomConnection = Doors.RoomChanged.Event:Connect(SetRoom)

    self.Heartbeat = RunService.Heartbeat:Connect(function()
        if not Label.Parent then return end
        local Elapsed = math.max(0, os.clock() - self.EnteredAt)
        Label.Text = "ROOM " .. tostring(self.RoomNumber) .. "  •  " .. string.format("%0.1fs", Elapsed)
    end)

    Hub:Log("DOORS Room Timer started.")
end

function RoomTimer.Stop(self)
    if self.RoomConnection then
        self.RoomConnection:Disconnect()
        self.RoomConnection = nil
    end
    if self.Heartbeat then
        self.Heartbeat:Disconnect()
        self.Heartbeat = nil
    end
    if self.Gui then
        self.Gui:Destroy()
        self.Gui = nil
    end
end

return RoomTimer
