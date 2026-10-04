--// FAIRWELL HEAVEN
--// DOORS Threat Memory
--// Keeps a compact history of recent entity encounters for Fairwell/AI.

local ThreatMemory = {
    Name = "DOORS Threat Memory",
    Description = "Remembers recent DOORS entity encounters and exposes them to Fairwell AI.",
    Game = "DOORS",
    MaxEntries = 20,
    Entries = {},
    LastEntity = nil
}

local ALIASES = {
    rush = "Rush",
    rushmoving = "Rush",
    ambush = "Ambush",
    seek = "Seek",
    halt = "Halt",
    screech = "Screech",
    eyes = "Eyes",
    figure = "Figure",
    dupe = "Dupe",
    grumble = "Grumble",
    giggle = "Giggle",
    sally = "Sally"
}

local function normalize(name)
    local key = string.lower(tostring(name or "")):gsub("%s+", "")
    return ALIASES[key] or tostring(name or "Unknown")
end

function ThreatMemory.Record(self, name, room, kind)
    local entry = {
        Entity = normalize(name),
        Room = tonumber(room) or room,
        Kind = kind or "Encounter",
        Time = os.clock()
    }

    table.insert(self.Entries, 1, entry)
    while #self.Entries > self.MaxEntries do
        table.remove(self.Entries)
    end

    self.LastEntity = entry
end

function ThreatMemory.GetRecent(self, limit)
    local result = {}
    limit = math.max(1, math.floor(tonumber(limit) or 6))

    for index = 1, math.min(limit, #self.Entries) do
        local source = self.Entries[index]
        result[index] = {
            Entity = source.Entity,
            Room = source.Room,
            Kind = source.Kind,
            SecondsAgo = math.max(0, os.clock() - source.Time)
        }
    end

    return result
end

function ThreatMemory.Start(self, Hub)
    self.Entries = {}
    self.LastEntity = nil

    local Brain = Hub:GetFeature("Fairwell Companion Brain")
    if Brain then
        Brain.ThreatMemory = self
    end

    local event = Hub.EntityEvent
    if event and event.Event then
        self.EntityConnection = event.Event:Connect(function(entityName, data)
            local room = nil
            local Doors = Hub:GetService("Doors")
            if Doors and Doors.CurrentRoom then
                room = tonumber(Doors.CurrentRoom.Name)
            end

            self:Record(entityName, room, data and data.Kind or "Encounter")

            if Brain and type(Brain.PushEvent) == "function" then
                Brain:PushEvent("EntityMemory", {
                    Entity = normalize(entityName),
                    Room = room
                }, 1)
            end
        end)
    end

    Hub:Log("DOORS Threat Memory started.")
    return true
end

function ThreatMemory.Stop(self)
    if self.EntityConnection then
        self.EntityConnection:Disconnect()
        self.EntityConnection=nil
    end
    self.Entries = {}
    self.LastEntity = nil
end

return ThreatMemory
