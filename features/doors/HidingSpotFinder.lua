--// FAIRWELL HEAVEN
--// DOORS Hiding Spot Finder
--// Highlights actual hiding objects in the current room.

local Players = game:GetService("Players")

local Feature = {
    Name = "DOORS Hiding Spot Finder",
    Description = "Highlights nearby wardrobes, lockers, closets and beds so mobile players can find safety quickly.",
    Game = "DOORS",
    RoomConnection = nil,
    DescendantConnection = nil,
    Highlights = {},
    Room = nil
}

local TOKENS = {"wardrobe", "closet", "locker", "bed"}

local function norm(v)
    return string.lower(tostring(v or "")):gsub("[%s_%-%./]", "")
end

local function isHide(object)
    local n = norm(object.Name)
    for _, token in ipairs(TOKENS) do
        if string.find(n, token, 1, true) then return true end
    end
    return false
end

local function adornTarget(object)
    if object:IsA("Model") or object:IsA("BasePart") then return object end
    return object:FindFirstAncestorOfClass("Model")
end

function Feature.Clear(self)
    for object, highlight in pairs(self.Highlights) do
        if highlight then pcall(function() highlight:Destroy() end) end
        self.Highlights[object] = nil
    end
end

function Feature.Scan(self, room)
    self:Clear()
    self.Room = room
    if not room then return end

    local seen = {}
    for _, object in ipairs(room:GetDescendants()) do
        if isHide(object) then
            local target = adornTarget(object)
            if target and not seen[target] then
                seen[target] = true

                local highlight = Instance.new("Highlight")
                highlight.Name = "FairwellHeavenHideSpot"
                highlight.Adornee = target
                highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                highlight.FillColor = Color3.fromRGB(90, 220, 255)
                highlight.FillTransparency = 0.78
                highlight.OutlineColor = Color3.fromRGB(110, 220, 255)
                highlight.Parent = target

                self.Highlights[target] = highlight
            end
        end
    end
end

function Feature.Start(self, Hub)
    local Settings = Hub:GetService("Settings")
    if Settings and Settings:GetFeatureEnabled(self.Name, true) == false then return false end

    local Doors = Hub:GetService("Doors")
    if not Doors then return false end

    self.Highlights = {}
    self:Scan(Doors.CurrentRoom)

    self.RoomConnection = Doors.RoomChanged.Event:Connect(function(room)
        task.defer(function() self:Scan(room) end)
    end)

    self.DescendantConnection = workspace.DescendantAdded:Connect(function(object)
        local room = self.Room
        if room and object:IsDescendantOf(room) and isHide(object) then
            task.defer(function()
                if self.Hub then self:Scan(room) end
            end)
        end
    end)

    self.Hub = Hub
    Hub:Log("DOORS Hiding Spot Finder started.")
    return true
end

function Feature.Stop(self)
    if self.RoomConnection then self.RoomConnection:Disconnect(); self.RoomConnection=nil end
    if self.DescendantConnection then self.DescendantConnection:Disconnect(); self.DescendantConnection=nil end
    self:Clear()
    self.Room=nil
    self.Hub=nil
end

return Feature
