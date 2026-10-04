--// FAIRWELL HEAVEN
--// Visual: DOORS Item Labels

local Workspace = game:GetService("Workspace")

local ItemLabels = {
    Name = "VISUAL DOORS Item Labels",
    Description = "Puts readable labels over doors, keys, keycards, and levers.",
    Game = "DOORS",
    Objects = {},
    RoomConnection = nil,
    DescendantConnection = nil,
    CurrentRoom = nil
}

local function Normalize(Name)
    return string.lower(tostring(Name):gsub("[%s_%-%./]", ""))
end

local function Kind(Object)
    local Name = Normalize(Object.Name)
    if Name == "door" then return "DOOR" end
    if Name == "keycard" then return "KEYCARD" end
    if Name == "key" or string.find(Name, "key", 1, true) then return "KEY" end
    if Name == "lever" or string.find(Name, "lever", 1, true) then return "LEVER" end
end

local function Add(self, Object)
    if self.Objects[Object] or not (Object:IsA("Model") or Object:IsA("BasePart")) then return end
    local Text = Kind(Object)
    if not Text then return end

    local Gui = Instance.new("BillboardGui")
    Gui.Name = "FairwellHeavenItemLabel"
    Gui.Size = UDim2.fromOffset(110, 28)
    Gui.StudsOffset = Vector3.new(0, 3, 0)
    Gui.AlwaysOnTop = true
    Gui.MaxDistance = 100
    Gui.Adornee = Object
    Gui.Parent = Object

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.fromScale(1, 1)
    Label.BackgroundColor3 = Color3.fromRGB(6, 4, 43)
    Label.BackgroundTransparency = 0.18
    Label.BorderSizePixel = 0
    Label.Text = Text
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.TextSize = 11
    Label.Font = Enum.Font.GothamBold
    Label.Parent = Gui

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Label

    self.Objects[Object] = Gui
end

function ItemLabels.ScanRoom(self, Room)
    for Object, Gui in pairs(self.Objects) do
        if Gui then Gui:Destroy() end
        self.Objects[Object] = nil
    end
    self.CurrentRoom = Room
    if not Room then return end
    for _, Object in ipairs(Room:GetDescendants()) do
        Add(self, Object)
    end
end

function ItemLabels.Start(self, Hub)
    local Settings = Hub:GetService("Settings")
    if Settings and Settings:GetFeatureEnabled(self.Name, false) == false then return false end
    local Doors = Hub:GetService("Doors")
    if not Doors then return end
    self:ScanRoom(Doors.CurrentRoom)
    self.RoomConnection = Doors.RoomChanged.Event:Connect(function(Room) self:ScanRoom(Room) end)
    self.DescendantConnection = Workspace.DescendantAdded:Connect(function(Object)
        if self.CurrentRoom and Object:IsDescendantOf(self.CurrentRoom) then Add(self, Object) end
    end)
    Hub:Log("Visual DOORS Item Labels started.")
end

function ItemLabels.Stop(self)
    if self.RoomConnection then self.RoomConnection:Disconnect(); self.RoomConnection=nil end
    if self.DescendantConnection then self.DescendantConnection:Disconnect(); self.DescendantConnection=nil end
    for Object, Gui in pairs(self.Objects) do if Gui then Gui:Destroy() end self.Objects[Object]=nil end
    self.CurrentRoom=nil
end

return ItemLabels
