--// FAIRWELL HEAVEN
--// Game Detection

local Games = {}

Games.DOORS = {
    Name = "DOORS",
    -- DOORS main experience place.
    PlaceId = 6516141723
}

local function isDoorsPlace(placeId)
    return tostring(placeId) == tostring(Games.DOORS.PlaceId)
end

local function hasDoorsRuntime()
    local Workspace = game:GetService("Workspace")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")

    -- CurrentRooms is the strongest client-side fingerprint for DOORS.
    if Workspace:FindFirstChild("CurrentRooms") then
        return true
    end

    -- Some DOORS builds expose GameData even while CurrentRooms is loading.
    if ReplicatedStorage:FindFirstChild("GameData") then
        return true
    end

    return false
end

function Games:Detect()
    local PlaceId = game.PlaceId

    -- Compare as strings as well as numbers so executor/runtime wrappers
    -- cannot cause a valid PlaceId to miss the DOORS check.
    if isDoorsPlace(PlaceId) or hasDoorsRuntime() then
        return {
            Name = "DOORS",
            IsDOORS = true,
            PlaceId = PlaceId
        }
    end

    return {
        Name = "Unknown",
        IsDOORS = false,
        PlaceId = PlaceId
    }
end

return Games
