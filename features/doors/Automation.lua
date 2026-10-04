--// FAIRWELL HEAVEN
--// DOORS Automation
--// Conservative local automation: prompts and nearby tool pickup.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Automation = {
    Name = "DOORS Automation",
    Description = "Automatically interacts with nearby prompts and picks up nearby tools.",
    Game = "DOORS",
    Connection = nil,
    CurrentRoom = nil,
    Cooldown = 0
}

local MAX_DISTANCE = 12

local function Root()
    local Character = Players.LocalPlayer and Players.LocalPlayer.Character
    return Character and Character:FindFirstChild("HumanoidRootPart")
end

local function PromptDistance(Prompt)
    local RootPart = Root()
    local Parent = Prompt.Parent
    local Part = Parent and (Parent:IsA("BasePart") and Parent or Parent:FindFirstChildWhichIsA("BasePart", true))
    if not RootPart or not Part then return math.huge end
    return (RootPart.Position - Part.Position).Magnitude
end

local function TryPrompt(Prompt)
    if not Prompt.Enabled then return false end
    if PromptDistance(Prompt) > MAX_DISTANCE then return false end
    local Success = pcall(function()
        if fireproximityprompt then
            fireproximityprompt(Prompt)
        else
            Prompt:InputHoldBegin()
            task.wait(math.max(Prompt.HoldDuration, 0.05))
            Prompt:InputHoldEnd()
        end
    end)
    return Success
end

local function TryPickup(Object)
    if not Object:IsA("Tool") then return false end
    local RootPart = Root()
    local Handle = Object:FindFirstChild("Handle")
    if not RootPart or not Handle or not Handle:IsA("BasePart") then return false end
    if (RootPart.Position - Handle.Position).Magnitude > MAX_DISTANCE then return false end

    local Character = Players.LocalPlayer.Character
    if Character and Object.Parent == Workspace then
        pcall(function() Object.Parent = Character end)
        return true
    end
    return false
end

function Automation.Start(self, Hub)
    local Settings = Hub:GetService("Settings")
    if Settings and Settings:GetFeatureEnabled(self.Name, false) == false then return false end

    local Doors = Hub:GetService("Doors")
    if not Doors then return false end

    self.CurrentRoom = Doors.CurrentRoom
    self.Cooldown = 0

    self.Connection = RunService.Heartbeat:Connect(function(DeltaTime)
        self.Cooldown -= DeltaTime
        if self.Cooldown > 0 then return end
        self.Cooldown = 0.35

        local Room = Doors.CurrentRoom
        if not Room then return end
        self.CurrentRoom = Room

        local Prompts = {}
        for _, Object in ipairs(Room:GetDescendants()) do
            if Object:IsA("ProximityPrompt") then
                table.insert(Prompts, Object)
            end
        end

        for _, Prompt in ipairs(Prompts) do
            if TryPrompt(Prompt) then break end
        end

        for _, Object in ipairs(Room:GetDescendants()) do
            if TryPickup(Object) then break end
        end
    end)

    Hub:Log("DOORS Automation started.")
end

function Automation.Stop(self)
    if self.Connection then self.Connection:Disconnect(); self.Connection=nil end
    self.CurrentRoom=nil
end

return Automation
