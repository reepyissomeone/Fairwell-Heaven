--// FAIRWELL HEAVEN
--// Companion Brain
--// Memory, room awareness, event reactions, personality, anticipation and interaction.

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local Brain = {
    Name = "Fairwell Companion Brain",
    Description = "Fairwell's memory, personality, room awareness and event reactions.",
    Game = "DOORS",
    Connections = {},
    Memory = {},
    LastEvent = {},
    LastRoom = nil,
    FlickerToken = 0,
    TapIndex = 0
}

local function normalize(name)
    return string.lower(tostring(name):gsub("[%s_%-%./]", ""))
end

local function mainUI(self)
    return self.Hub and self.Hub:GetFeature("Main UI")
end

function Brain:Say(message, state, duration)
    local UI = mainUI(self)
    if UI and type(UI.CompanionNotify) == "function" then
        UI.CompanionNotify("FAIRWELL", message, "INFO", duration or 4, state)
    end
end

function Brain:SetState(state, duration)
    local UI = mainUI(self)
    if UI and type(UI.CompanionSetState) == "function" then
        UI.CompanionSetState(state, duration)
    end
end

function Brain:Remember(kind, value)
    self.Memory[kind] = self.Memory[kind] or {}
    table.insert(self.Memory[kind], value)
end

function Brain:Count(kind)
    return self.Memory[kind] and #self.Memory[kind] or 0
end

function Brain:OnTap()
    self.TapIndex += 1

    local lines = {
        {"Hey.", "Ctalking"},
        {"What?", "confused"},
        {"You keep poking me.", "Tapped"},
        {"I'm watching.", "Cthinking"},
        {"We have a game to finish.", "nervous"},
        {"...yes?", "Ctalking"},
        {"Don't distract me.", "ALERT"},
        {"I'm trying to remember what happened.", "Cthinking"}
    }

    -- Small chance of a rare response.
    if math.random(1, 18) == 1 then
        local rare = {
            {"I remember you.", "Scared"},
            {"Don't tap me again.", "uhoh"},
            {"Something feels wrong.", "nervous"}
        }
        local pick = rare[math.random(1, #rare)]
        self:Say(pick[1], pick[2], 3)
        return
    end

    local pick = lines[((self.TapIndex - 1) % #lines) + 1]
    self:Say(pick[1], pick[2], 3)
end

function Brain:OnRoom(room)
    if not room then return end

    local number = tonumber(room.Name)
    if not number or self.LastRoom == number then return end

    self.LastRoom = number
    self:Remember("Rooms", number)

    -- Special rooms get priority.
    local roomName = normalize(room.Name)
    if roomName == "seek" or roomName == "seekroom" or roomName == "seekroom" then
        self:SetState("nervous", 2)
        self:Say("Good luck. Stay focused.", "nervous", 4)
        return
    end

    if number == 50 then
        self:SetState("Cthinking", 2)
        self:Say("This is the library. Be careful.", "Cthinking", 5)
        return
    end

    if number % 10 == 0 then
        self:SetState("Cthinking", 2)
        self:Say("Room " .. tostring(number) .. "... I wonder what's next.", "Cthinking", 4)
    elseif math.random(1, 5) == 1 then
        self:SetState("Ctalking", 2)
        self:Say("Room " .. tostring(number) .. ". Keep looking.", "Ctalking", 3)
    end
end

function Brain:OnEntity(name)
    name = tostring(name)
    self:Remember("Entities", name)

    local reactions = {
        Rush = {"HIDE! NOW!", "Scared"},
        Ambush = {"HIDE AGAIN! IT'S COMING BACK!", "nervous"},
        Seek = {"Don't stop. Keep moving.", "Scared"},
        Figure = {"Quiet. Don't let it find us.", "nervous"},
        Screech = {"WHAT WAS THAT?!", "Tapped"},
        Halt = {"...What is it doing?", "confused"},
        Eyes = {"Don't look at it.", "confused"},
        Dupe = {"Wait. Something is wrong with this door.", "confused"},
        Grumble = {"That thing is too close.", "nervous"},
        Giggle = {"I heard something laugh.", "confused"}
    }

    local reaction = reactions[name]
    if not reaction then return end

    self:SetState(reaction[2], 2.5)
    self:Say(reaction[1], reaction[2], 4)
end

function Brain:OnKey(object)
    if not object then return end
    self:Remember("Keys", object:GetFullName())
    self:SetState("Yippe", 1.5)
    self:Say("A key! Keep that.", "Yippe", 3)
end

function Brain:OnImportantObject(object)
    if not object then return end
    local name = normalize(object.Name)

    if string.find(name, "crucifix", 1, true) then
        self:Remember("ImportantItems", "Crucifix")
        self:Say("That's useful. Keep it.", "Cthinking", 3)
    elseif string.find(name, "lighter", 1, true) then
        self:Remember("ImportantItems", "Lighter")
        self:Say("Good. Light could matter later.", "Cthinking", 3)
    end
end

function Brain:OnFlicker()
    local now = os.clock()
    if self.LastEvent.Flicker and now - self.LastEvent.Flicker < 5 then
        return
    end

    self.LastEvent.Flicker = now
    self.FlickerToken += 1
    self:SetState("nervous", 2)
    self:Say("The lights are flickering...", "nervous", 3)
end

function Brain:OnHide()
    self:Remember("Hides", os.clock())
    if math.random(1, 3) == 1 then
        self:SetState("nervous", 2)
        self:Say("Good. Stay hidden.", "nervous", 3)
    end
end

function Brain:OnDamage()
    self:SetState("uhoh", 2)
    self:Say("Ow. Are you okay?", "uhoh", 3)
end

function Brain:ScanObject(object)
    if not object or not object.Name then return end
    local name = normalize(object.Name)

    if string.find(name, "key", 1, true) then
        -- Avoid repeatedly treating every Key-related descendant as a pickup.
        if object:IsA("Tool") or object:IsA("Model") or object:IsA("BasePart") then
            self:OnKey(object)
        end
        return
    end

    self:OnImportantObject(object)
end

function Brain:WatchFlicker(object)
    if not object or not object:IsA("Light") then return end

    local last = object.Enabled
    local connection
    connection = object:GetPropertyChangedSignal("Enabled"):Connect(function()
        local current = object.Enabled
        if last == true and current == false then
            self:OnFlicker()
        end
        last = current
    end)

    table.insert(self.Connections, connection)
end

function Brain:Start(Hub)
    local Settings = Hub:GetService("Settings")
    if Settings and Settings:GetFeatureEnabled(self.Name, true) == false then
        return
    end

    self.Hub = Hub
    self.Connections = {}
    self.Memory = {
        Rooms = {},
        Entities = {},
        Keys = {},
        ImportantItems = {},
        Hides = {}
    }
    self.LastEvent = {}
    self.LastRoom = nil
    self.TapIndex = 0

    local Doors = Hub:GetService("Doors")
    if Doors and Doors.RoomChanged then
        table.insert(self.Connections, Doors.RoomChanged.Event:Connect(function(room)
            self:OnRoom(room)
        end))
    end

    local UI = mainUI(self)
    if UI then
        UI.CompanionBrain = self
    end

    table.insert(self.Connections, Workspace.DescendantAdded:Connect(function(object)
        self:ScanObject(object)
        self:WatchFlicker(object)
    end))

    for _, object in ipairs(Workspace:GetDescendants()) do
        self:WatchFlicker(object)
    end

    local player = Players.LocalPlayer
    if player then
        local character = player.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")

        local function hookCharacter(char)
            local hum = char:WaitForChild("Humanoid", 5)
            if hum then
                table.insert(self.Connections, hum.HealthChanged:Connect(function(health)
                    if health < hum.MaxHealth then
                        self:OnDamage()
                    end
                end))
            end
        end

        if character then
            hookCharacter(character)
        end

        table.insert(self.Connections, player.CharacterAdded:Connect(hookCharacter))
    end

    Hub:Log("Fairwell Companion Brain started.")
end

function Brain:Stop()
    for _, connection in ipairs(self.Connections or {}) do
        pcall(function() connection:Disconnect() end)
    end

    self.Connections = {}
    self.Hub = nil
    self.Memory = {}
    self.LastEvent = {}
end

return Brain
