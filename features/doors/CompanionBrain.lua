--// FAIRWELL HEAVEN
--// Companion Brain
--// Event-driven memory, reactions, personality and player interaction.

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local Brain = {
    Name = "Fairwell Companion Brain",
    Description = "Fairwell's memory, personality, room awareness and event reactions.",
    Game = "DOORS",
    Connections = {},
    Memory = {},
    LastEvent = {},
    LastRoom = nil,
    TapIndex = 0,
    SeenObjects = {},
    SeenEntities = {},
    ActiveEntity = {}
}

local function normalize(name)
    return string.lower(tostring(name):gsub("[%s_%-%./]", ""))
end

local function mainUI(self)
    return self.Hub and self.Hub:GetFeature("Main UI")
end

function Brain:Say(message, state, duration, kind)
    local UI = mainUI(self)
    if UI and type(UI.CompanionNotify) == "function" then
        UI.CompanionNotify("FAIRWELL", message, kind or "INFO", duration or 4, state)
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

function Brain:Expression(name)
    -- Abstract expressions always resolve to sprites that actually exist.
    local map = {
        Suspicious = "confused",
        Listening = "Cthinking",
        Focused = "Cthinking",
        Shocked = "surpised",
        Panicking = "terrified",
        Hiding = "hiding",
        Relieved = "relief",
        Hurt = "hurt",
        Danger = "terrified",
        Happy = "Yippe",
        Talking = "Ctalking",
        Thinking = "Cthinking",
        Alert = "ALERT",
        Nervous = "nervous",
        Confused = "confused",
        Tapped = "Tapped",
        Idle = "Idle"
    }
    return map[name] or name
end

function Brain:React(message, expression, duration, kind)
    local sprite = self:Expression(expression)
    self:SetState(sprite, duration or 3)
    self:Say(message, sprite, duration or 4, kind)
end

function Brain:Cooldown(key, seconds)
    local now = os.clock()
    local last = self.LastEvent[key]
    if last and now - last < seconds then
        return false
    end
    self.LastEvent[key] = now
    return true
end

function Brain:OnTap()
    self.TapIndex += 1
    local lines = {
        {"Hey.", "Talking"},
        {"What?", "Confused"},
        {"You keep poking me.", "Tapped"},
        {"I'm watching.", "Thinking"},
        {"We have a game to finish.", "Nervous"},
        {"...yes?", "Talking"},
        {"Don't distract me.", "Alert"},
        {"I'm trying to remember what happened.", "Thinking"}
    }

    if math.random(1, 18) == 1 then
        local rare = {
            {"I remember you.", "Suspicious"},
            {"Don't tap me again.", "Hurt"},
            {"Something feels wrong.", "Nervous"}
        }
        local pick = rare[math.random(1, #rare)]
        self:React(pick[1], pick[2], 3)
        return
    end

    local pick = lines[((self.TapIndex - 1) % #lines) + 1]
    self:React(pick[1], pick[2], 3)
end

function Brain:OnRoom(room)
    if not room then return end
    local number = tonumber(room.Name)
    if not number or self.LastRoom == number then return end

    self.LastRoom = number
    self:Remember("Rooms", number)

    local lower = normalize(room.Name)
    if lower == "seek" or lower == "seekroom" or lower == "seekroom" then
        self:React("Good luck. Stay focused.", "Focused", 4, "WARNING")
        return
    end

    if number == 50 then
        self:React("This is the library. Be careful.", "Listening", 5, "WARNING")
        return
    end

    if number == 100 then
        self:React("Something feels different up here.", "Suspicious", 4, "WARNING")
        return
    end

    -- Only special rooms get automatic room dialogue. Normal rooms stay quiet.
    if number % 10 == 0 then
        self:React("Room " .. tostring(number) .. ". Stay alert.", "Thinking", 3)
    end
end

function Brain:FocusCameraOnEntity(object)
    if not object or not object.Parent then return end

    local camera = Workspace.CurrentCamera
    if not camera then return end

    local target
    if object:IsA("Model") then
        local ok, cf = pcall(function()
            return object:GetPivot()
        end)
        if ok and cf then
            target = cf.Position
        end
    elseif object:IsA("BasePart") then
        target = object.Position
    else
        local part = object:FindFirstChildWhichIsA("BasePart", true)
        if part then target = part.Position end
    end

    if not target then return end

    -- Screech should grab Fairwell's attention immediately.
    -- Briefly take control of the camera, look directly at Screech,
    -- then return control to the normal DOORS camera.
    local previousType = camera.CameraType
    local previousSubject = camera.CameraSubject
    local currentPosition = camera.CFrame.Position

    camera.CameraType = Enum.CameraType.Scriptable
    camera.CFrame = CFrame.lookAt(currentPosition, target)

    task.delay(0.85, function()
        if camera and camera.Parent then
            camera.CameraType = previousType
            if previousSubject and previousSubject.Parent then
                camera.CameraSubject = previousSubject
            end
        end
    end)
end

function Brain:OnEntity(name, object)
    name = tostring(name)
    if not self:Cooldown("Entity:" .. name, 2.5) then return end

    self:Remember("Entities", name)
    self.ActiveEntity[name] = true

    local reactions = {
        Rush = {"HIDE! NOW!", "Hiding", "WARNING"},
        Ambush = {"HIDE AGAIN! IT'S COMING BACK!", "Hiding", "WARNING"},
        Seek = {"Don't stop. Keep moving.", "Danger", "WARNING"},
        Figure = {"Quiet. Don't let it find us.", "Nervous", "WARNING"},
        Screech = {"LOOK THERE!", "Shocked", "WARNING"},
        Creak = {"CREAK?!", "Confused", "WARNING"},
        Halt = {"...What is it doing?", "Confused", "WARNING"},
        Eyes = {"Don't look at it.", "Suspicious", "WARNING"},
        Dupe = {"Wait. Something is wrong with this door.", "Confused", "WARNING"},
        Grumble = {"That thing is too close.", "Nervous", "WARNING"},
        Giggle = {"I heard something laugh.", "Shocked", "WARNING"},
        Sally = {"SALLY?! I don't trust that thing.", "Suspicious", "WARNING"}
    }

    local reaction = reactions[name]
    if reaction then
        if name == "Screech" then
            self:FocusCameraOnEntity(object)
        elseif name == "Creak" then
            self:FocusCameraOnEntity(object)
        end
        self:React(reaction[1], reaction[2], 4, reaction[3])
    end
end

function Brain:OnEntityGone(name)
    name = tostring(name)
    if not self.ActiveEntity[name] then return end
    self.ActiveEntity[name] = nil
    if self:Cooldown("Gone:" .. name, 3) then
        self:React("It's gone. Keep going.", "Relieved", 3, "SUCCESS")
    end
end

function Brain:OnKey(object)
    if not object or not object.Parent then return end
    local id = object:GetDebugId()
    if self.SeenObjects[id] then return end
    self.SeenObjects[id] = true

    self:Remember("Keys", object:GetFullName())
    self:React("A key! Keep that.", "Happy", 3, "SUCCESS")
end

function Brain:OnImportantObject(object)
    if not object or not object.Name then return end
    local name = normalize(object.Name)
    local id = object:GetDebugId()
    if self.SeenObjects[id] then return end

    local item
    if string.find(name, "crucifix", 1, true) then
        item = "Crucifix"
    elseif string.find(name, "lighter", 1, true) then
        item = "Lighter"
    end
    if not item then return end

    self.SeenObjects[id] = true
    self:Remember("ImportantItems", item)
    self:React(
        item == "Crucifix" and "That's useful. Keep it." or "Good. Light could matter later.",
        "Thinking", 3, "INFO"
    )
end

function Brain:OnFlicker()
    if not self:Cooldown("Flicker", 5) then return end
    self:React("The lights are flickering...", "Nervous", 3, "WARNING")
end

function Brain:OnHide()
    self:Remember("Hides", os.clock())
    if self:Cooldown("Hide", 4) then
        self:React("Good. Stay hidden.", "Hiding", 3)
    end
end

function Brain:OnDamage()
    if not self:Cooldown("Damage", 3) then return end
    self:React("OW! Are you okay?!", "Hurt", 3, "ERROR")
end

function Brain:ScanObject(object)
    if not object or not object.Name then return end
    local name = normalize(object.Name)

    if string.find(name, "key", 1, true) and
        (object:IsA("Tool") or object:IsA("Model") or object:IsA("BasePart")) then
        self:OnKey(object)
        return
    end

    self:OnImportantObject(object)
end

function Brain:WatchFlicker(object)
    if not object or not object:IsA("Light") then return end
    local last = object.Enabled
    table.insert(self.Connections, object:GetPropertyChangedSignal("Enabled"):Connect(function()
        local current = object.Enabled
        if last and not current then self:OnFlicker() end
        last = current
    end))
end

function Brain:WatchHideObject(object)
    if not object or not object.Name then return end
    local n = normalize(object.Name)
    if n ~= "wardrobe" and n ~= "closet" and n ~= "hiding" and n ~= "hide" then return end

    local player = Players.LocalPlayer
    local function isLocalCharacterPart(hit)
        return player and player.Character and hit and hit:IsDescendantOf(player.Character)
    end

    -- Watch every physical part so multi-part wardrobes/closets work reliably.
    for _, part in ipairs(object:GetDescendants()) do
        if part:IsA("BasePart") then
            table.insert(self.Connections, part.Touched:Connect(function(hit)
                if isLocalCharacterPart(hit) then
                    self:OnHide()
                end
            end))
        end
    end

    -- DOORS hiding spots may also use a ProximityPrompt instead of touch detection.
    for _, prompt in ipairs(object:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") then
            table.insert(self.Connections, prompt.Triggered:Connect(function(triggeringPlayer)
                if not triggeringPlayer or triggeringPlayer == player then
                    self:OnHide()
                end
            end))
        end
    end
end

function Brain:Start(Hub)
    local Settings = Hub:GetService("Settings")
    if Settings and Settings:GetFeatureEnabled(self.Name, true) == false then return end

    self.Hub = Hub
    self.Connections = {}
    self.Memory = {Rooms = {}, Entities = {}, Keys = {}, ImportantItems = {}, Hides = {}}
    self.LastEvent = {}
    self.LastRoom = nil
    self.TapIndex = 0
    self.SeenObjects = {}
    self.ActiveEntity = {}

    local Doors = Hub:GetService("Doors")
    if Doors and Doors.RoomChanged then
        table.insert(self.Connections, Doors.RoomChanged.Event:Connect(function(room)
            self:OnRoom(room)
        end))
        if Doors.CurrentRoom then self:OnRoom(Doors.CurrentRoom) end
    end

    local UI = mainUI(self)
    if UI then UI.CompanionBrain = self end

    table.insert(self.Connections, Workspace.DescendantAdded:Connect(function(object)
        self:ScanObject(object)
        self:WatchFlicker(object)
        self:WatchHideObject(object)
    end))

    for _, object in ipairs(Workspace:GetDescendants()) do
        self:ScanObject(object)
        self:WatchFlicker(object)
        self:WatchHideObject(object)
    end

    local player = Players.LocalPlayer
    if player then
        local function hookCharacter(char)
            local hum = char:WaitForChild("Humanoid", 5)
            if not hum then return end
            local lastHealth = hum.Health
            table.insert(self.Connections, hum.HealthChanged:Connect(function(health)
                if health < lastHealth then self:OnDamage() end
                lastHealth = health
            end))
        end
        if player.Character then hookCharacter(player.Character) end
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
