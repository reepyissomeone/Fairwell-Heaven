--// FAIRWELL HEAVEN
--// DOORS Entity Notifications
--// Reliable entity detection for spawned AND already-loaded entities

local Workspace = game:GetService("Workspace")

local EntityNotifications = {
    Name = "DOORS Entity Notifications",
    Description = "Reacts when common DOORS entities appear.",
    Game = "DOORS",
    Connections = {},
    LastAlert = {}
}

local EntityNames = {
    rush="Rush", ambush="Ambush", seek="Seek", halt="Halt",
    screech="Screech", creak="Creak", eyes="Eyes", figure="Figure", dupe="Dupe",
    grumble="Grumble", giggle="Giggle", sally="Sally"
}

local EntitySprites = {
    Rush = "hiding",
    Ambush = "hiding",
    Seek = "terrified",
    Halt = "confused",
    Screech = "surpised",
    Creak = "confused",
    Eyes = "confused",
    Figure = "nervous",
    Dupe = "confused",
    Grumble = "nervous",
    Giggle = "confused",
    Sally = "surpised"
}

local function NormalizeName(Name)
    return string.lower(tostring(Name):gsub("[%s_%-%./]", ""))
end

local function FindEntityName(Object)
    local Name = NormalizeName(Object.Name)

    if Name == "figure" or Name == "dupe" then
        return Object:IsA("Model") and EntityNames[Name] or nil
    end

    if EntityNames[Name] then
        return EntityNames[Name]
    end

    for Key, DisplayName in pairs(EntityNames) do
        if Key ~= "figure" and Key ~= "dupe"
            and string.find(Name, Key, 1, true) then
            return DisplayName
        end
    end

    return nil
end

local COOLDOWN = 2

local function IsInStairwell(Object)
    local currentRooms = Workspace:FindFirstChild("CurrentRooms")
    if not currentRooms then return false end

    local room = Object:FindFirstAncestorWhichIsA("Model")
    while room and room.Parent ~= currentRooms do
        room = room.Parent and room.Parent:FindFirstAncestorWhichIsA("Model")
    end

    if room and string.find(string.lower(room.Name), "stairwell", 1, true) then
        return true
    end

    -- Some Stairwell builds use a folder/model outside CurrentRooms.
    local parent = Object.Parent
    while parent and parent ~= Workspace do
        if string.find(string.lower(parent.Name), "stairwell", 1, true) then
            return true
        end
        parent = parent.Parent
    end

    return false
end

local function Notify(Hub, Name, Object)
    -- Creak is specific to the Stairwell. Other entity detection remains global.
    -- Fairwell's Companion Brain handles the actual reaction/hint.
    if Name == "Creak" and not IsInStairwell(Object) then return end

    local Brain = Hub and Hub:GetFeature("Fairwell Companion Brain")
    if Brain and type(Brain.OnEntity) == "function" then
        Brain:OnEntity(Name, Object)
    end
end

local function Detect(self, Object)
    if not Object or not Object.Parent then
        return
    end

    local Name = FindEntityName(Object)

    if not Name then
        return
    end

    local Now = os.clock()
    if self.LastAlert[Name] and Now - self.LastAlert[Name] < COOLDOWN then
        return
    end

    self.LastAlert[Name] = Now
    Notify(self.Hub, Name, Object)

    -- Keep entity state in sync so Fairwell can react again after an entity leaves.
    task.delay(4, function()
        if self.Hub and self.LastAlert[Name] == Now then
            local stillThere = false
            for _, candidate in ipairs(Workspace:GetDescendants()) do
                if FindEntityName(candidate) == Name then
                    stillThere = true
                    break
                end
            end
            if not stillThere then
                local Brain = self.Hub:GetFeature("Fairwell Companion Brain")
                if Brain and type(Brain.OnEntityGone) == "function" then
                    Brain:OnEntityGone(Name)
                end
            end
        end
    end)
end

local function ScanExisting(self)
    for _, Object in ipairs(Workspace:GetDescendants()) do
        Detect(self, Object)
    end
end

function EntityNotifications.Start(self, Hub)
    local Settings = Hub:GetService("Settings")
    if Settings and Settings:GetFeatureEnabled(self.Name, true) == false then
        return
    end

    self.LastAlert = {}
    self.Hub = Hub
    self.Connections = {}

    table.insert(self.Connections, Workspace.DescendantAdded:Connect(function(Object)
        Detect(self, Object)
    end))

    task.defer(function()
        if self.Hub == Hub then
            ScanExisting(self)
        end
    end)

    Hub:Log("DOORS Entity Notifications started.")
end

function EntityNotifications.Stop(self)
    for _, Connection in ipairs(self.Connections or {}) do
        Connection:Disconnect()
    end
    self.Connections = {}
    table.clear(self.LastAlert)
    self.Hub = nil
end

return EntityNotifications
