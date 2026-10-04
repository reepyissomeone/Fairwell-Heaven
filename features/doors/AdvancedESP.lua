--// FAIRWELL HEAVEN
--// DOORS Advanced ESP
--// Room-scoped item/entity/objective ESP with distance labels.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local ESP = {
    Name = "DOORS Advanced ESP",
    Description = "Advanced room ESP for doors, items, gold, closets, objectives, entities, and players.",
    Game = "DOORS",
    CurrentRoom = nil,
    RoomConnection = nil,
    DescendantConnection = nil,
    PlayerConnection = nil,
    HeartbeatConnection = nil,
    Objects = {},
    MaxDistance = 250
}

local function Normalize(Name)
    return string.lower(tostring(Name):gsub("[%s_%-%./]", ""))
end

local function Classify(Object)
    local Name = Normalize(Object.Name)
    local ParentName = Object.Parent and Normalize(Object.Parent.Name) or ""
    if Object:IsA("Model") and Players:GetPlayerFromCharacter(Object) then
        if Object ~= Players.LocalPlayer.Character then
            return "PLAYER"
        end
        return nil
    end

    if Name == "door" then return "DOOR" end
    if Name == "key" or string.find(Name, "key", 1, true) then return "KEY" end
    if Name == "keycard" then return "KEYCARD" end
    if string.find(Name, "gold", 1, true) or string.find(Name, "coin", 1, true) then return "GOLD" end
    if string.find(Name, "closet", 1, true) or string.find(Name, "wardrobe", 1, true) or Name == "bed" then return "HIDE" end
    if string.find(Name, "objective", 1, true) or string.find(Name, "generator", 1, true)
        or string.find(Name, "breaker", 1, true) or string.find(Name, "lever", 1, true) then
        return "OBJECTIVE"
    end

    local Entities = {
        rush="RUSH", ambush="AMBUSH", seek="SEEK", halt="HALT",
        screech="SCREECH", eyes="EYES", figure="FIGURE", dupe="DUPE",
        grumble="GRUMBLE", giggle="GIGGLE"
    }
    if Entities[Name] and Object:IsA("Model") then return Entities[Name] end
    if ParentName == "currentrooms" then
        if string.find(Name, "entity", 1, true) then return "ENTITY" end
    end
end

local function GetPart(Object)
    if Object:IsA("BasePart") then return Object end
    if Object:IsA("Model") then
        local Root = Object.PrimaryPart or Object:FindFirstChildWhichIsA("BasePart", true)
        return Root
    end
end

local function ColorFor(Kind)
    if Kind == "DOOR" then return Color3.fromRGB(50, 170, 255) end
    if Kind == "KEY" or Kind == "KEYCARD" then return Color3.fromRGB(255, 210, 55) end
    if Kind == "GOLD" then return Color3.fromRGB(255, 190, 45) end
    if Kind == "HIDE" then return Color3.fromRGB(180, 150, 255) end
    if Kind == "OBJECTIVE" then return Color3.fromRGB(70, 230, 150) end
    if Kind == "PLAYER" then return Color3.fromRGB(120, 210, 255) end
    return Color3.fromRGB(255, 75, 95)
end

local function Add(self, Object)
    if self.Objects[Object] then return end
    if not (Object:IsA("Model") or Object:IsA("BasePart")) then return end

    local Kind = Classify(Object)
    if not Kind then return end

    local Part = GetPart(Object)
    if not Part then return end

    local Highlight = Instance.new("Highlight")
    Highlight.Name = "FairwellHeavenAdvancedESP"
    Highlight.Adornee = Object
    Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    Highlight.FillColor = ColorFor(Kind)
    Highlight.FillTransparency = 0.82
    Highlight.OutlineColor = ColorFor(Kind)
    Highlight.OutlineTransparency = 0.05
    Highlight.Parent = Object

    local Billboard = Instance.new("BillboardGui")
    Billboard.Name = "FairwellHeavenAdvancedESPLabel"
    Billboard.Adornee = Part
    Billboard.Size = UDim2.fromOffset(150, 32)
    Billboard.StudsOffset = Vector3.new(0, 3.5, 0)
    Billboard.AlwaysOnTop = true
    Billboard.MaxDistance = self.MaxDistance
    Billboard.Parent = Object

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.fromScale(1, 1)
    Label.BackgroundTransparency = 1
    Label.Text = Kind
    Label.TextColor3 = ColorFor(Kind)
    Label.TextStrokeTransparency = 0.25
    Label.TextSize = 12
    Label.Font = Enum.Font.GothamBold
    Label.Parent = Billboard

    self.Objects[Object] = {Highlight = Highlight, Billboard = Billboard, Label = Label, Part = Part, Kind = Kind}
end

local function Clear(self)
    for Object, Data in pairs(self.Objects) do
        if Data.Highlight then Data.Highlight:Destroy() end
        if Data.Billboard then Data.Billboard:Destroy() end
        self.Objects[Object] = nil
    end
end

function ESP.ScanRoom(self, Room)
    Clear(self)
    self.CurrentRoom = Room
    if not Room then return end
    for _, Object in ipairs(Room:GetDescendants()) do Add(self, Object) end
end

function ESP.Start(self, Hub)
    local Settings = Hub:GetService("Settings")
    if Settings and Settings:GetFeatureEnabled(self.Name, false) == false then return false end

    local Doors = Hub:GetService("Doors")
    if not Doors then return false end

    self:ScanRoom(Doors.CurrentRoom)

    self.RoomConnection = Doors.RoomChanged.Event:Connect(function(Room)
        self:ScanRoom(Room)
    end)

    self.DescendantConnection = Workspace.DescendantAdded:Connect(function(Object)
        if self.CurrentRoom and Object:IsDescendantOf(self.CurrentRoom) then
            task.defer(function() Add(self, Object) end)
        end
    end)

    self.PlayerConnection = Players.PlayerAdded:Connect(function(Player)
        Player.CharacterAdded:Connect(function(Character)
            if Character ~= Players.LocalPlayer.Character then
                local Part = Character:FindFirstChild("HumanoidRootPart")
                if Part then Add(self, Character) end
            end
        end)
    end)

    self.HeartbeatConnection = RunService.Heartbeat:Connect(function()
        for Object, Data in pairs(self.Objects) do
            if not Object.Parent then
                self.Objects[Object] = nil
            else
                local Part = Data.Part
                if Part and Data.Billboard then
                    local Camera = Workspace.CurrentCamera
                    local Root = Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if Camera and Root then
                        local Distance = (Root.Position - Part.Position).Magnitude
                        Data.Label.Text = Data.Kind .. "  [" .. math.floor(Distance) .. "m]"
                    end
                end
            end
        end
    end)

    Hub:Log("DOORS Advanced ESP started.")
end

function ESP.Stop(self)
    if self.RoomConnection then self.RoomConnection:Disconnect(); self.RoomConnection=nil end
    if self.DescendantConnection then self.DescendantConnection:Disconnect(); self.DescendantConnection=nil end
    if self.PlayerConnection then self.PlayerConnection:Disconnect(); self.PlayerConnection=nil end
    if self.HeartbeatConnection then self.HeartbeatConnection:Disconnect(); self.HeartbeatConnection=nil end
    Clear(self)
    self.CurrentRoom=nil
end

return ESP
