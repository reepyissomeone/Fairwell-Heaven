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
    local Name = EntityNames[string.lower(Object.Name)]
    if not Name then return end
    local Now = os.clock()
    if self.LastAlert[Name] and Now - self.LastAlert[Name] < COOLDOWN then return end
    self.LastAlert[Name] = Now
    Notify(Name)
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
