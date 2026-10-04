--// FAIRWELL HEAVEN
--// DOORS Entity Protection
--// Client-side defensive helpers. Does not modify movement speed.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Protection = {
    Name = "DOORS Entity Protection",
    Description = "Attempts safe local protections against common DOORS entity effects.",
    Game = "DOORS",
    Connection = nil,
    CharacterConnection = nil,
    Protected = {}
}

local function Normalize(Name)
    return string.lower(tostring(Name):gsub("[%s_%-%./]", ""))
end

local function FindEntity(Object)
    local Name = Normalize(Object.Name)
    local Map = {
        screech="Screech", eyes="Eyes", halt="Halt", ["a90"]="A-90",
        rush="Rush", ambush="Ambush", seek="Seek", giggle="Giggle"
    }
    if Map[Name] then return Map[Name] end
    for Key, Display in pairs(Map) do
        if string.find(Name, Key, 1, true) then return Display end
    end
end

local function TryNeutralize(Object)
    -- Only alter local visual/effect containers. Never destroy the entity itself.
    local Name = Normalize(Object.Name)
    if Name == "screech" or Name == "eyes" or Name == "halt" or Name == "a90" then
        for _, Descendant in ipairs(Object:GetDescendants()) do
            if Descendant:IsA("BillboardGui") or Descendant:IsA("Beam") then
                pcall(function() Descendant.Enabled = false end)
            elseif Descendant:IsA("ParticleEmitter") then
                pcall(function() Descendant.Enabled = false end)
            end
        end
    end
end

local function OnDescendant(self, Object)
    if not Object:IsA("Model") then return end
    local Entity = FindEntity(Object)
    if not Entity then return end

    self.Protected[Object] = Entity
    TryNeutralize(Object)

    if self.Hub and self.Hub.Notify then
        self.Hub:Notify("DOORS • PROTECTION", Entity .. " detected", "WARNING", 2)
    end
end

function Protection.Start(self, Hub)
    local Settings = Hub:GetService("Settings")
    if Settings and Settings:GetFeatureEnabled(self.Name, false) == false then return false end

    self.Hub = Hub
    table.clear(self.Protected)

    self.Connection = Workspace.DescendantAdded:Connect(function(Object)
        task.defer(function() OnDescendant(self, Object) end)
    end)

    self.CharacterConnection = Players.LocalPlayer.CharacterAdded:Connect(function()
        table.clear(self.Protected)
    end)

    Hub:Log("DOORS Entity Protection started.")
end

function Protection.Stop(self)
    if self.Connection then self.Connection:Disconnect(); self.Connection=nil end
    if self.CharacterConnection then self.CharacterConnection:Disconnect(); self.CharacterConnection=nil end
    table.clear(self.Protected)
    self.Hub=nil
end

return Protection
