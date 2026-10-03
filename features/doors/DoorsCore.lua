--// FAIRWELL HEAVEN
--// DOORS Core
--// Version 1.1
--// Uses the player's position when possible; falls back to highest loaded room.

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

    self.UpdateConnection = RunService.Heartbeat:Connect(function()
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
