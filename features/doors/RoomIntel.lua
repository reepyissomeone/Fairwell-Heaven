--// FAIRWELL HEAVEN
--// DOORS Room Intel
--// Mobile-friendly room-change intelligence with anti-spam notifications.

local RoomIntel = {
    Name = "DOORS Room Intel",
    Description = "Scans each room for useful objects and reports meaningful room details.",
    Game = "DOORS",
    LastRoomNumber = nil,
    LastSignature = nil
}

local function lower(v)
    return string.lower(tostring(v or ""))
end

local function countNamed(root, names)
    local count = 0
    local found = {}
    for _, object in ipairs(root:GetDescendants()) do
        local n = lower(object.Name)
        for _, wanted in ipairs(names) do
            if n == wanted or string.find(n, wanted, 1, true) then
                count += 1
                found[wanted] = (found[wanted] or 0) + 1
                break
            end
        end
    end
    return count, found
end

function RoomIntel.Scan(self, room)
    if not room then return nil end

    local number = tonumber(room.Name)
    local keys = countNamed(room, {"key"})
    local lockers = countNamed(room, {"wardrobe", "closet", "locker"})
    local drawers = countNamed(room, {"drawer"})
    local books = countNamed(room, {"book"})
    local paintings = countNamed(room, {"painting"})
    local switches = countNamed(room, {"switch", "lever", "button"})
    local generators = countNamed(room, {"generator"})
    local closets = lockers

    local flags = {}
    if keys > 0 then table.insert(flags, "KEY") end
    if closets > 0 then table.insert(flags, "HIDE") end
    if drawers > 0 then table.insert(flags, "LOOT") end
    if books > 0 then table.insert(flags, "BOOK") end
    if paintings > 0 then table.insert(flags, "PAINT") end
    if switches > 0 then table.insert(flags, "SWITCH") end
    if generators > 0 then table.insert(flags, "GENERATOR") end

    return {
        Number = number,
        Keys = keys,
        Hides = closets,
        Drawers = drawers,
        Books = books,
        Paintings = paintings,
        Switches = switches,
        Generators = generators,
        Flags = flags
    }
end

function RoomIntel.Start(self, Hub)
    local Doors = Hub:GetService("Doors")
    if not Doors then return false end

    local function announce(room)
        local info = self:Scan(room)
        if not info then return end

        local signature = table.concat({
            tostring(info.Number or "?"),
            tostring(info.Keys),
            tostring(info.Hides),
            tostring(info.Drawers),
            tostring(info.Books),
            tostring(info.Paintings),
            tostring(info.Switches),
            tostring(info.Generators)
        }, ":")

        if info.Number == self.LastRoomNumber and signature == self.LastSignature then
            return
        end

        self.LastRoomNumber = info.Number
        self.LastSignature = signature

        if #info.Flags == 0 then
            Hub:Log("Room Intel:", "Room", info.Number or "?", "no special objects detected.")
            return
        end

        local message = "Room " .. tostring(info.Number or "?") .. ": " .. table.concat(info.Flags, " • ")

        if info.Keys > 0 or info.Generators > 0 then
            Hub:Notify("ROOM INTEL", message, "INFO", 3)
        else
            Hub:Log("Room Intel:", message)
        end
    end

    self.RoomConnection = Doors.RoomChanged.Event:Connect(function(room)
        task.defer(announce, room)
    end)

    if Doors.CurrentRoom then
        task.defer(announce, Doors.CurrentRoom)
    end

    Hub:Log("DOORS Room Intel started.")
    return true
end

function RoomIntel.Stop(self)
    if self.RoomConnection then
        self.RoomConnection:Disconnect()
        self.RoomConnection = nil
    end
    self.LastRoomNumber = nil
    self.LastSignature = nil
end

return RoomIntel
