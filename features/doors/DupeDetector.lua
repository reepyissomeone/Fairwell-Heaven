--// FAIRWELL HEAVEN
--// DOORS Dupe Detector
--// Detects suspicious duplicate doors and marks the likely fake door.

local DupeDetector = {
    Name = "DOORS Dupe Detector",
    Description = "Detects Dupe doors in the current room and marks suspicious door frames.",
    Game = "DOORS",
    RoomConnection = nil,
    DescendantConnection = nil,
    Objects = {},
    CurrentRoom = nil
}

local function norm(v)
    return string.lower(tostring(v or "")):gsub("[%s_%-%./]", "")
end

local function clear(self)
    for object, highlight in pairs(self.Objects) do
        if highlight then pcall(function() highlight:Destroy() end) end
        self.Objects[object] = nil
    end
end

local function mark(self, object)
    if not object or self.Objects[object] then return end
    if not (object:IsA("Model") or object:IsA("BasePart")) then return end

    local h = Instance.new("Highlight")
    h.Name = "FairwellHeavenDupe"
    h.Adornee = object
    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    h.FillColor = Color3.fromRGB(255, 65, 65)
    h.FillTransparency = 0.72
    h.OutlineColor = Color3.fromRGB(255, 40, 40)
    h.Parent = object
    self.Objects[object] = h
end

function DupeDetector.Scan(self, room)
    clear(self)
    self.CurrentRoom = room
    if not room then return end

    local dupe = room:FindFirstChild("dupeDoor", true)
    if not dupe then
        for _, object in ipairs(room:GetDescendants()) do
            if norm(object.Name) == "dupdoor" or norm(object.Name) == "dupedoor" then
                dupe = object
                break
            end
        end
    end

    if not dupe then return end

    local target = dupe
    if dupe.Parent and dupe.Parent:FindFirstChild("Parts") then
        local parts = dupe.Parent.Parts
        local frame = parts:FindFirstChild("DoorFrame")
        target = frame or dupe
    end

    mark(self, target)
end

function DupeDetector.Start(self, Hub)
    local Doors = Hub:GetService("Doors")
    if not Doors then return false end

    self:Scan(Doors.CurrentRoom)

    self.RoomConnection = Doors.RoomChanged.Event:Connect(function(room)
        task.defer(function() self:Scan(room) end)
    end)

    self.DescendantConnection = workspace.DescendantAdded:Connect(function(object)
        local room = self.CurrentRoom
        if room and object:IsDescendantOf(room) then
            local n = norm(object.Name)
            if string.find(n, "dupe", 1, true) or string.find(n, "door", 1, true) then
                task.defer(function() self:Scan(room) end)
            end
        end
    end)

    Hub:Log("DOORS Dupe Detector started.")
    return true
end

function DupeDetector.Stop(self)
    if self.RoomConnection then self.RoomConnection:Disconnect(); self.RoomConnection=nil end
    if self.DescendantConnection then self.DescendantConnection:Disconnect(); self.DescendantConnection=nil end
    clear(self)
    self.CurrentRoom=nil
end

return DupeDetector
