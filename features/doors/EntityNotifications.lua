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
    screech="Screech", eyes="Eyes", figure="Figure", dupe="Dupe",
    grumble="Grumble", giggle="Giggle"
}

local EntitySprites = {
    Rush = "Scared",
    Ambush = "nervous",
    Seek = "Scared",
    Halt = "confused",
    Screech = "Tapped",
    Eyes = "confused",
    Figure = "nervous",
    Dupe = "confused",
    Grumble = "nervous",
    Giggle = "confused"
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

local function Notify(Hub, Name)
    local MainUI = Hub and Hub:GetFeature("Main UI")
    local Sprite = EntitySprites[Name]

    if MainUI and type(MainUI.CompanionNotify) == "function" then
        MainUI.CompanionNotify(
            "FAIRWELL",
            Name .. " detected!",
            "WARNING",
            4,
            Sprite
        )
        return
    end

    if Hub and type(Hub.Notify) == "function" then
        Hub:Notify(
            "DOORS • ENTITY DETECTED",
            Name .. " detected!",
            "WARNING",
            4
        )
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
    Notify(self.Hub, Name)
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
