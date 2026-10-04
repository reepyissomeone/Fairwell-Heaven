--// FAIRWELL HEAVEN
--// DOORS Entity Notifications
--// New-spawn detection with cooldown and no startup spam

local Workspace = game:GetService("Workspace")

local EntityNotifications = {
    Name = "DOORS Entity Notifications",
    Description = "Notifies when common DOORS entities appear.",
    Game = "DOORS",
    Connection = nil,
    LastAlert = {}
}

local EntityNames = {
    rush="Rush", ambush="Ambush", seek="Seek", halt="Halt",
    screech="Screech", eyes="Eyes", figure="Figure", dupe="Dupe",
    grumble="Grumble", giggle="Giggle"
}

-- These names are the NEW companion sprites in:
-- assets/Fairwell/Companion/
-- Do not use the older Fairwell reaction sprites here.
local EntitySprites = {
    -- New face sprites currently in assets/Fairwell/Companion/
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
        if Object:IsA("Model") then
            return EntityNames[Name]
        end
        return nil
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

local function IsLever(Object)
    local Name = NormalizeName(Object.Name)
    return Name == "lever"
        or Name == "levers"
        or string.find(Name, "lever", 1, true) ~= nil
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
        return
    end

    Hub:Warn("DOORS entity detected: " .. Name)
end

local function Detect(self, Object)
    local Name = FindEntityName(Object)

    if Name then
        local Now = os.clock()
        if self.LastAlert[Name] and Now - self.LastAlert[Name] < COOLDOWN then
            return
        end
        self.LastAlert[Name] = Now
        Notify(self.Hub, Name)
        return
    end

    if IsLever(Object) then
        local Now = os.clock()
        if self.LastAlert.Lever and Now - self.LastAlert.Lever < COOLDOWN then
            return
        end
        self.LastAlert.Lever = Now
        Notify(self.Hub, "Lever")
    end
end

function EntityNotifications.Start(self, Hub)
    local Settings = Hub:GetService("Settings")
    if Settings and Settings:GetFeatureEnabled(self.Name, true) == false then return end
    self.LastAlert = {}
    self.Hub = Hub
    self.Connection = Workspace.DescendantAdded:Connect(function(Object)
        Detect(self, Object)
    end)
    Hub:Log("DOORS Entity Notifications started.")
end

function EntityNotifications.Stop(self)
    if self.Connection then self.Connection:Disconnect(); self.Connection=nil end
    table.clear(self.LastAlert)
    self.Hub = nil
end

return EntityNotifications
