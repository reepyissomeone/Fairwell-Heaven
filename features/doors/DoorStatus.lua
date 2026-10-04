--// FAIRWELL HEAVEN
--// DOORS Door Status
--// Lightweight status tracker for the current room door.

local DoorStatus = {
    Name = "DOORS Door Status",
    Description = "Tracks the current room door and reports important state changes.",
    Game = "DOORS",
    CurrentDoor = nil,
    LastState = nil
}

local function lower(v)
    return string.lower(tostring(v or ""))
end

local function readBool(object, names)
    for _, name in ipairs(names) do
        local child = object:FindFirstChild(name, true)
        if child and child:IsA("BoolValue") then
            return child.Value
        end
        local ok, value = pcall(function()
            return object:GetAttribute(name)
        end)
        if ok and type(value) == "boolean" then
            return value
        end
    end
    return nil
end

local function readNumber(object, names)
    for _, name in ipairs(names) do
        local ok, value = pcall(function()
            return object:GetAttribute(name)
        end)
        if ok and type(value) == "number" then
            return value
        end
    end
    return nil
end

function DoorStatus.Describe(self, door)
    if not door then return "NO DOOR" end

    local locked = readBool(door, {"Locked", "IsLocked", "locked"})
    local opened = readBool(door, {"Opened", "Open", "IsOpen", "opened"})
    local requiresKey = readBool(door, {"RequiresKey", "NeedsKey", "LockedByKey"})

    local state
    if opened == true then
        state = "OPEN"
    elseif locked == true or requiresKey == true then
        state = "LOCKED"
    else
        state = "CLOSED"
    end

    local keyId = readNumber(door, {"KeyID", "KeyId", "RequiredKey"})
    if keyId then
        state = state .. " • KEY " .. tostring(keyId)
    end

    return state
end

function DoorStatus.Update(self, Hub, door)
    if door == self.CurrentDoor then
        local state = self:Describe(door)
        if state ~= self.LastState then
            self.LastState = state
            Hub:Log("Door Status:", state)
        end
        return
    end

    self.CurrentDoor = door
    self.LastState = self:Describe(door)

    if door then
        Hub:Log("Door Status:", self.LastState, "-", door:GetFullName())
    end

    if self.DescendantConnection then
        self.DescendantConnection:Disconnect()
        self.DescendantConnection = nil
    end

    if self.AttributeConnection then
        self.AttributeConnection:Disconnect()
        self.AttributeConnection = nil
    end

    if not door then return end

    self.DescendantConnection = door.DescendantAdded:Connect(function()
        task.defer(function()
            self:Update(Hub, door)
        end)
    end)

    self.AttributeConnection = door.AttributeChanged:Connect(function()
        task.defer(function()
            self:Update(Hub, door)
        end)
    end)
end

function DoorStatus.Start(self, Hub)
    local Doors = Hub:GetService("Doors")
    if not Doors then return false end

    self.RoomConnection = Doors.DoorChanged.Event:Connect(function(door)
        self:Update(Hub, door)
    end)

    self:Update(Hub, Doors.CurrentDoor)
    Hub:Log("DOORS Door Status started.")
    return true
end

function DoorStatus.Stop(self)
    if self.RoomConnection then self.RoomConnection:Disconnect(); self.RoomConnection=nil end
    if self.DescendantConnection then self.DescendantConnection:Disconnect(); self.DescendantConnection=nil end
    if self.AttributeConnection then self.AttributeConnection:Disconnect(); self.AttributeConnection=nil end
    self.CurrentDoor = nil
    self.LastState = nil
end

return DoorStatus
