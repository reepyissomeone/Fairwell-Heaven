--// FAIRWELL HEAVEN
--// DOORS Entity Notifications
--// Rebuilt entity detector: model-first, container-aware, debounced

local Workspace = game:GetService("Workspace")

local EntityNotifications = {
    Name = "DOORS Entity Notifications",
    Description = "Detects DOORS entities from runtime models and containers.",
    Game = "DOORS",
    Connections = {},
    LastAlert = {},
    Detected = {}
}

local ENTITY_ALIASES = {
    rush = "Rush",
    rushmoving = "Rush",
    ambush = "Ambush",
    seek = "Seek",
    halt = "Halt",
    screech = "Screech",
    creak = "Creak",
    eyes = "Eyes",
    figure = "Figure",
    dupe = "Dupe",
    grumble = "Grumble",
    giggle = "Giggle",
    sally = "Sally"
}

local COOLDOWN = 1.25

local function Normalize(value)
    return string.lower(tostring(value or "")):gsub("[%s_%-%./]", "")
end

local function IsEntityName(value)
    local n = Normalize(value)
    if ENTITY_ALIASES[n] then
        return ENTITY_ALIASES[n]
    end

    -- Runtime variants such as RushMoving, Rush_Model, etc.
    for alias, display in pairs(ENTITY_ALIASES) do
        if #alias >= 5 and string.find(n, alias, 1, true) then
            return display
        end
    end

    return nil
end

local function GetRootModel(object)
    if not object then return nil end
    if object:IsA("Model") then return object end
    return object:FindFirstAncestorOfClass("Model")
end

local function ResolveEntity(object)
    if not object or not object.Parent then
        return nil, nil
    end

    -- 1. The object itself.
    local direct = IsEntityName(object.Name)
    if direct and (object:IsA("Model") or object:IsA("Folder")) then
        return direct, object
    end

    -- 2. Walk upward. This catches Workspace.RushMoving descendants.
    local cursor = object
    while cursor and cursor ~= Workspace do
        local name = IsEntityName(cursor.Name)
        if name and cursor:IsA("Model") then
            return name, cursor
        end
        cursor = cursor.Parent
    end

    -- 3. Search the nearest model's descendants.
    local model = GetRootModel(object)
    if not model then return nil, nil end

    local modelName = IsEntityName(model.Name)
    if modelName then
        return modelName, model
    end

    for _, child in ipairs(model:GetDescendants()) do
        local name = IsEntityName(child.Name)
        if name then
            if child:IsA("Model") then
                return name, child
            end
            return name, model
        end
    end

    return nil, nil
end

local function Notify(self, name, object)
    local brain = self.Hub and self.Hub:GetFeature("Fairwell Companion Brain")
    if brain and type(brain.OnEntity) == "function" then
        brain:OnEntity(name, object)
    end
end

local function MarkDetected(self, name, object)
    if not name or not object or not object.Parent then return end

    self.Detected[object] = true
    self.LastAlert[name] = os.clock()

    Notify(self, name, object)

    task.delay(5, function()
        if not self.Hub then return end

        if not object.Parent then
            self.Detected[object] = nil

            local brain = self.Hub:GetFeature("Fairwell Companion Brain")
            if brain and type(brain.OnEntityGone) == "function" then
                brain:OnEntityGone(name)
            end
        end
    end)
end

local function TryDetect(self, object)
    local name, target = ResolveEntity(object)
    if not name or not target then return end
    if self.Detected[target] then return end

    local last = self.LastAlert[name]
    if last and os.clock() - last < COOLDOWN then
        return
    end

    MarkDetected(self, name, target)
end

local function ScanTree(self, root)
    if not root then return end

    -- Check models/folders first instead of every BasePart.
    if root:IsA("Model") or root:IsA("Folder") then
        TryDetect(self, root)
    end

    for _, child in ipairs(root:GetDescendants()) do
        if child:IsA("Model") or child:IsA("Folder") then
            TryDetect(self, child)
        end
    end
end

local function FindLiveEntities()
    local direct = Workspace:FindFirstChild("Live Entities")
        or Workspace:FindFirstChild("LiveEntities")

    if direct then return direct end

    for _, object in ipairs(Workspace:GetDescendants()) do
        if Normalize(object.Name) == "liveentities" then
            return object
        end
    end

    return nil
end

local function HookContainer(self, container)
    if not container or self.Hooked[container] then return end
    self.Hooked[container] = true

    table.insert(self.Connections, container.ChildAdded:Connect(function(object)
        task.defer(function()
            if self.Hub then
                TryDetect(self, object)
                ScanTree(self, object)
            end
        end)
    end))

    table.insert(self.Connections, container.DescendantAdded:Connect(function(object)
        if object:IsA("Model") or object:IsA("Folder") then
            task.defer(function()
                if self.Hub then
                    TryDetect(self, object)
                end
            end)
        end
    end))

    ScanTree(self, container)
end

function EntityNotifications.Start(self, Hub)
    local Settings = Hub:GetService("Settings")
    if Settings and Settings:GetFeatureEnabled(self.Name, true) == false then
        return
    end

    self.Hub = Hub
    self.Connections = {}
    self.LastAlert = {}
    self.Detected = {}
    self.Hooked = {}

    -- Existing containers/entities.
    local live = FindLiveEntities()
    if live then
        HookContainer(self, live)
    end

    ScanTree(self, Workspace)

    -- Future entities and containers.
    table.insert(self.Connections, Workspace.DescendantAdded:Connect(function(object)
        if not self.Hub then return end

        local normalized = Normalize(object.Name)

        if normalized == "liveentities" then
            task.defer(function()
                if self.Hub then
                    HookContainer(self, object)
                end
            end)
            return
        end

        -- Only process models/folders. Their descendants are handled by
        -- ResolveEntity, avoiding thousands of unnecessary BasePart checks.
        if object:IsA("Model") or object:IsA("Folder") then
            task.defer(function()
                if self.Hub then
                    TryDetect(self, object)
                    ScanTree(self, object)
                end
            end)
        end
    end))

    Hub:Log("DOORS Entity Notifications started. Model-first detection active.")
end

function EntityNotifications.Stop(self)
    for _, connection in ipairs(self.Connections or {}) do
        pcall(function()
            connection:Disconnect()
        end)
    end

    self.Connections = {}
    self.LastAlert = {}
    self.Detected = {}
    self.Hooked = {}
    self.Hub = nil
end

return EntityNotifications
