--// FAIRWELL HEAVEN
--// DOORS Core
--// Version 1.2
--// More reliable room centers and throttled room checks.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Doors = {
    Name = "DOORS Core",
    Description = "Core DOORS game service.",
    Game = "DOORS",
    CurrentRoom = nil,
    PreviousRoom = nil,
    CurrentDoor = nil,
    Player = nil,
    Character = nil,
    Root = nil,
    RoomChanged = Instance.new("BindableEvent"),
    DoorChanged = Instance.new("BindableEvent")
}

function Doors:GetRoomNumber(room)
    return room and tonumber(room.Name) or nil
end

function Doors:GetRoomCenter(room)
    if not room then return nil end

    -- Prefer the room's model bounds instead of the first arbitrary
    -- BasePart (which can be furniture, a prop, or a trigger).
    if room:IsA("Model") then
        local Success, BoundsCFrame = pcall(function()
            local CFrameValue = room:GetBoundingBox()
            return CFrameValue
        end)

        if Success and BoundsCFrame then
            return BoundsCFrame.Position
        end
    end

    -- DOORS rooms can also expose a Door model/part. Prefer that over
    -- an arbitrary descendant when a bounding box is unavailable.
    local Door = room:FindFirstChild("Door")
    if Door then
        if Door:IsA("BasePart") then
            return Door.Position
        end

        if Door:IsA("Model") then
            local Success, BoundsCFrame = pcall(function()
                local CFrameValue = Door:GetBoundingBox()
                return CFrameValue
            end)

            if Success and BoundsCFrame then
                return BoundsCFrame.Position
            end
        end

        local DoorPart = Door:FindFirstChildWhichIsA("BasePart", true)
        if DoorPart then
            return DoorPart.Position
        end
    end

    local Part = room:FindFirstChildWhichIsA("BasePart", true)
    return Part and Part.Position or nil
end

function Doors:GetCurrentRoom()
    local CurrentRooms = workspace:FindFirstChild("CurrentRooms")
    if not CurrentRooms then return nil end

    if self.Root then
        local BestRoom, BestDistance
        for _, Room in ipairs(CurrentRooms:GetChildren()) do
            if tonumber(Room.Name) then
                local Center = self:GetRoomCenter(Room)
                if Center then
                    local Distance = (self.Root.Position - Center).Magnitude
                    if not BestDistance or Distance < BestDistance then
                        BestDistance = Distance
                        BestRoom = Room
                    end
                end
            end
        end
        if BestRoom then return BestRoom end
    end

    local HighestRoom, HighestNumber
    for _, Room in ipairs(CurrentRooms:GetChildren()) do
        local Number = tonumber(Room.Name)
        if Number and (not HighestNumber or Number > HighestNumber) then
            HighestNumber = Number
            HighestRoom = Room
        end
    end
    return HighestRoom
end

function Doors:UpdatePlayer()
    self.Character = self.Player and self.Player.Character
    self.Root = self.Character and self.Character:FindFirstChild("HumanoidRootPart")
end

function Doors.Start(self, Hub)
    self.Player = Players.LocalPlayer
    if not self.Player then return end
    self:UpdatePlayer()

    self.CharacterConnection = self.Player.CharacterAdded:Connect(function()
        self:UpdatePlayer()
    end)

    local RoomCheckTimer = 0

    self.UpdateConnection = RunService.Heartbeat:Connect(function(DeltaTime)
        RoomCheckTimer += DeltaTime

        -- Room detection does not need to run every rendered frame.
        if RoomCheckTimer < 0.10 then
            return
        end

        RoomCheckTimer = 0
        self:UpdatePlayer()

        local NewRoom = self:GetCurrentRoom()
        if NewRoom ~= self.CurrentRoom then
            local OldRoom = self.CurrentRoom
            self.PreviousRoom = OldRoom
            self.CurrentRoom = NewRoom
            self.RoomChanged:Fire(NewRoom, OldRoom)
        end
    end)

    Hub:RegisterService("Doors", self)
    Hub:Log("DOORS Core initialized.")
end

function Doors.Stop(self)
    if self.CharacterConnection then self.CharacterConnection:Disconnect(); self.CharacterConnection=nil end
    if self.UpdateConnection then self.UpdateConnection:Disconnect(); self.UpdateConnection=nil end
    self.CurrentRoom=nil
    self.PreviousRoom=nil
    self.CurrentDoor=nil
end

return Doors
