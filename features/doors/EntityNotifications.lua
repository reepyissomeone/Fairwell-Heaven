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
    -- Fairwell's Companion Brain handles the actual reaction/hint.
    local Brain = Hub and Hub:GetFeature("Fairwell Companion Brain")
    if Brain and type(Brain.OnEntity) == "function" then
        Brain:OnEntity(Name, Object)
    end
end

local function GetLiveEntities()
    -- DOORS may place Live Entities directly under Workspace or inside
    -- another runtime container. Find the actual container by name without
    -- scanning unrelated entity objects.
    local direct = Workspace:FindFirstChild("Live Entities")
        or Workspace:FindFirstChild("LiveEntities")
    if direct then
        return direct
    end

    for _, descendant in ipairs(Workspace:GetDescendants()) do
        if NormalizeName(descendant.Name) == "liveentities" then
            return descendant
        end
    end

    return nil
end

local function FindEntityInRoot(Root)
    local direct = FindEntityName(Root)
    if direct then
        return direct, Root
    end

    -- Some entity containers have a generic root name and put the actual
    -- entity name on a descendant. Prefer exact matches for reliability.
    for _, descendant in ipairs(Root:GetDescendants()) do
        local normalized = NormalizeName(descendant.Name)
        if EntityNames[normalized] then
            local name = EntityNames[normalized]
            if name == "Figure" or name == "Dupe" then
                if descendant:IsA("Model") then
                    return name, descendant
                end
            else
                return name, descendant
            end
        end
    end

    return nil, nil
end

local function FindMatchingEntity(LiveEntities, WantedName)
    if not LiveEntities then
        return nil
    end

    for _, root in ipairs(LiveEntities:GetChildren()) do
        local name = FindEntityInRoot(root)
        if name == WantedName then
            return root
        end
    end

    return nil
end

local function GetEntityRoot(LiveEntities, Object)
    if not LiveEntities or not Object or Object == LiveEntities then
        return nil
    end

    local root = Object
    while root.Parent and root.Parent ~= LiveEntities do
        root = root.Parent
    end

    return root.Parent == LiveEntities and root or nil
end

local function Detect(self, Object)
    local LiveEntities = GetLiveEntities()
    local Root = GetEntityRoot(LiveEntities, Object)

    if not Root or not Root.Parent then
        return
    end

    local Name, Target = FindEntityInRoot(Root)
    if not Name then
        return
    end

    local Now = os.clock()
    if self.LastAlert[Name] and Now - self.LastAlert[Name] < COOLDOWN then
        return
    end

    self.LastAlert[Name] = Now
    Notify(self.Hub, Name, Target or Root)

    task.delay(4, function()
        if self.Hub and self.LastAlert[Name] == Now then
            local live = GetLiveEntities()
            local stillThere = FindMatchingEntity(live, Name) ~= nil

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
    local LiveEntities = GetLiveEntities()
    if not LiveEntities then
        return
    end

    for _, Object in ipairs(LiveEntities:GetChildren()) do
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
    self.HookedLiveContainers = {}

    local function HookLiveEntities(LiveEntities)
        if not LiveEntities or self.HookedLiveContainers[LiveEntities] then
            return
        end

        self.HookedLiveContainers[LiveEntities] = true

        table.insert(self.Connections, LiveEntities.ChildAdded:Connect(function(Object)
            Detect(self, Object)
        end))

        -- Catch entities whose root is created first and named later,
        -- or whose actual Creak object is inserted one level deeper.
        table.insert(self.Connections, LiveEntities.DescendantAdded:Connect(function(Object)
            Detect(self, Object)
        end))

        ScanExisting(self)
    end

    local LiveEntities = GetLiveEntities()
    if LiveEntities then
        HookLiveEntities(LiveEntities)
    end

    -- Catch Live Entities whether it is created directly under Workspace
    -- or inside another runtime container.
    table.insert(self.Connections, Workspace.DescendantAdded:Connect(function(Object)
        if NormalizeName(Object.Name) == "liveentities" then
            task.defer(function()
                if self.Hub == Hub then
                    HookLiveEntities(Object)
                end
            end)
        end
    end))

    task.defer(function()
        if self.Hub == Hub then
            local live = GetLiveEntities()
            if live then
                HookLiveEntities(live)
            end
            ScanExisting(self)
        end
    end)

    Hub:Log("DOORS Entity Notifications started. Watching Live Entities.")
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
