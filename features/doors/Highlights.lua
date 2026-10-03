--// FAIRWELL HEAVEN
--// DOORS Highlights
--// Room-scoped and performance-safe

local Workspace = game:GetService("Workspace")

local Highlights = {
    Name = "DOORS Highlights",
    Description = "Highlights doors and useful room items.",
    Game = "DOORS",
    Objects = {},
    CurrentRoom = nil
}

local COLORS = {
    door = Color3.fromRGB(27,147,227),
    key = Color3.fromRGB(255,205,55),
    keycard = Color3.fromRGB(120,210,255)
}

local function GetKind(object)
    local Name = string.lower(object.Name)
    if Name == "door" then return "door" end
    if Name == "keycard" then return "keycard" end
    if Name == "key" or string.find(Name, "key") then return "key" end
    return nil
end

local function Add(self, object)
    if not object or self.Objects[object] then return end
    local Kind = GetKind(object)
    if not Kind then return end
    if not (object:IsA("Model") or object:IsA("BasePart")) then return end

    local H = Instance.new("Highlight")
    H.Name = "FairwellHeavenHighlight"
    H.Adornee = object
    H.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    H.FillColor = COLORS[Kind]
    H.FillTransparency = 0.78
    H.OutlineColor = COLORS[Kind]
    H.OutlineTransparency = 0
    H.Parent = object
    self.Objects[object] = H
end

function Highlights:Clear()
    for Object, Highlight in pairs(self.Objects) do
        if Highlight then Highlight:Destroy() end
        self.Objects[Object] = nil
    end
end

function Highlights:ScanRoom(Room)
    self:Clear()
    self.CurrentRoom = Room
    if not Room then return end
    for _, Object in ipairs(Room:GetDescendants()) do Add(self, Object) end
end

function Highlights.Start(self, Hub)
    local Settings = Hub:GetService("Settings")
    if Settings and Settings:GetFeatureEnabled(self.Name, true) == false then return end

    local Doors = Hub:GetService("Doors")
    if not Doors then return end

    self:ScanRoom(Doors.CurrentRoom)

    self.RoomConnection = Doors.RoomChanged.Event:Connect(function(NewRoom)
        self:ScanRoom(NewRoom)
    end)

    self.DescendantConnection = Workspace.DescendantAdded:Connect(function(Object)
        local Room = self.CurrentRoom
        if Room and Object:IsDescendantOf(Room) then Add(self, Object) end
    end)

    Hub:Log("DOORS Highlights started.")
end

function Highlights.Stop(self)
    if self.RoomConnection then self.RoomConnection:Disconnect(); self.RoomConnection=nil end
    if self.DescendantConnection then self.DescendantConnection:Disconnect(); self.DescendantConnection=nil end
    self:Clear()
    self.CurrentRoom = nil
end

return Highlights
