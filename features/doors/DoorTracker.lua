--// FAIRWELL HEAVEN
--// DOORS Door Tracker
--// Handles late doors without rescanning on every descendant

local Workspace = game:GetService("Workspace")

local DoorTracker = {
    Name = "DOORS Door Tracker",
    Description = "Tracks the door belonging to the current room.",
    Game = "DOORS",
    CurrentDoor = nil,
    RoomConnection = nil,
    DescendantConnection = nil
}

function DoorTracker.FindDoor(room)
    if not room then return nil end
    local Direct = room:FindFirstChild("Door")
    if Direct then return Direct end
    for _, Object in ipairs(room:GetDescendants()) do
        if Object.Name == "Door" then return Object end
    end
    return nil
end

function DoorTracker.Update(self, Hub, Room)
    local NewDoor = self.FindDoor(Room)
    if NewDoor == self.CurrentDoor then return end
    local OldDoor = self.CurrentDoor
    self.CurrentDoor = NewDoor

    local Doors = Hub:GetService("Doors")
    if Doors then
        Doors.CurrentDoor = NewDoor
        Doors.DoorChanged:Fire(NewDoor, OldDoor)
    end

    if NewDoor then Hub:Log("DOORS door detected:", NewDoor:GetFullName()) end
end

function DoorTracker.Start(self, Hub)
    local Doors = Hub:GetService("Doors")
    if not Doors then return end
    self:Update(Hub, Doors.CurrentRoom)

    self.RoomConnection = Doors.RoomChanged.Event:Connect(function(NewRoom)
        self:Update(Hub, NewRoom)
    end)

    self.DescendantConnection = Workspace.DescendantAdded:Connect(function(Object)
        local Room = Doors.CurrentRoom
        if not Room then
            return
        end

        -- Only rescan when a possible Door node is added. Scanning the
        -- entire room for every spawned part/particle is unnecessarily expensive.
        local Name = string.lower(tostring(Object.Name))
        if Name ~= "door" and not string.find(Name, "door", 1, true) then
            return
        end

        if Object:IsDescendantOf(Room) then
            self:Update(Hub, Room)
        end
    end)

    Hub:Log("DOORS Door Tracker started.")
end

function DoorTracker.Stop(self)
    if self.RoomConnection then self.RoomConnection:Disconnect(); self.RoomConnection=nil end
    if self.DescendantConnection then self.DescendantConnection:Disconnect(); self.DescendantConnection=nil end
    self.CurrentDoor = nil

    local Doors = Hub and Hub:GetService("Doors")
    if Doors then
        Doors.CurrentDoor = nil
    end
end

return DoorTracker
