--// FAIRWELL HEAVEN
--// DOORS Entity Notifications
--// New-spawn detection with cooldown and no startup spam

local Workspace = game:GetService("Workspace")
local StarterGui = game:GetService("StarterGui")

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

local function NormalizeName(Name)
    return string.lower(tostring(Name):gsub("[%s_%-%./]", ""))
end

local function FindEntityName(Object)
    local Name = NormalizeName(Object.Name)

    -- Exact names.
    if EntityNames[Name] then
        return EntityNames[Name]
    end

    -- Common DOORS variants such as RushMoving / AmbushMoving.
    for Key, DisplayName in pairs(EntityNames) do
        if string.find(Name, Key, 1, true) then
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

local function Notify(Name)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "Fairwell Heaven • DOORS",
            Text = Name .. " detected!",
            Duration = 4
        })
    end)
end

local function Detect(self, Object)
    local Name = FindEntityName(Object)

    if Name then
        local Now = os.clock()
        if self.LastAlert[Name] and Now - self.LastAlert[Name] < COOLDOWN then
            return
        end
        self.LastAlert[Name] = Now
        Notify(Name)
        return
    end

    if IsLever(Object) then
        local Now = os.clock()
        if self.LastAlert.Lever and Now - self.LastAlert.Lever < COOLDOWN then
            return
        end
        self.LastAlert.Lever = Now
        Notify("Lever")
    end
end

function EntityNotifications.Start(self, Hub)
    local Settings = Hub:GetService("Settings")
    if Settings and Settings:GetFeatureEnabled(self.Name, true) == false then return end
    self.LastAlert = {}
    self.Connection = Workspace.DescendantAdded:Connect(function(Object)
        Detect(self, Object)
    end)
    Hub:Log("DOORS Entity Notifications started.")
end

function EntityNotifications.Stop(self)
    if self.Connection then self.Connection:Disconnect(); self.Connection=nil end
    table.clear(self.LastAlert)
end

return EntityNotifications
