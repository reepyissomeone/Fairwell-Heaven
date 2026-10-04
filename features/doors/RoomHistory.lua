--// FAIRWELL HEAVEN
--// DOORS Room History
--// Remembers the player's recent room path for Fairwell's awareness.

local RoomHistory = {
    Name = "DOORS Room History",
    Description = "Remembers recent rooms and detects revisits.",
    Game = "DOORS",
    History = {},
    Current = nil,
    Previous = nil,
    BestRoom = 0,
    Connection = nil
}

local MAX_HISTORY = 30

function RoomHistory:Push(room)
    if not room then return end

    local number = tonumber(room.Name)
    if not number or number == self.Current then return end

    self.Previous = self.Current
    self.Current = number
    self.BestRoom = math.max(self.BestRoom, number)

    local revisited = false
    for _, value in ipairs(self.History) do
        if value == number then
            revisited = true
            break
        end
    end

    table.insert(self.History, number)
    while #self.History > MAX_HISTORY do
        table.remove(self.History, 1)
    end

    if revisited and self.Hub then
        self.Hub:Log("DOORS room revisit:", tostring(number))
    end
end

function RoomHistory:GetRecent()
    local copy = {}
    for index, value in ipairs(self.History) do
        copy[index] = value
    end
    return copy
end

function RoomHistory:Start(Hub)
    local Settings = Hub:GetService("Settings")
    if Settings and Settings:GetFeatureEnabled(self.Name, true) == false then return end

    self.Hub = Hub
    self.History = {}
    self.Current = nil
    self.Previous = nil
    self.BestRoom = 0

    local Doors = Hub:GetService("Doors")
    if not Doors then return end

    self.Connection = Doors.RoomChanged.Event:Connect(function(room)
        self:Push(room)
    end)

    if Doors.CurrentRoom then
        self:Push(Doors.CurrentRoom)
    end

    Hub:Log("DOORS Room History started.")
end

function RoomHistory:Stop()
    if self.Connection then
        self.Connection:Disconnect()
        self.Connection = nil
    end

    self.History = {}
    self.Current = nil
    self.Previous = nil
    self.BestRoom = 0
    self.Hub = nil
end

return RoomHistory
