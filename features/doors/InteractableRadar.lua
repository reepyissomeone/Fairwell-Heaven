--// FAIRWELL HEAVEN
--// DOORS Interactable Radar

local Feature = {
    Name = "DOORS Interactable Radar",
    Description = "Lists nearby keys, hiding spots, drawers, books, and objectives for mobile play.",
    Game = "DOORS"
}

local TYPES = {
    key = "KEY",
    keycard = "KEYCARD",
    wardrobe = "HIDE",
    closet = "HIDE",
    locker = "HIDE",
    drawer = "DRAWER",
    book = "BOOK",
    generator = "GENERATOR",
    breaker = "BREAKER",
    lever = "LEVER",
    button = "BUTTON"
}

local function classify(name)
    local n = string.lower(tostring(name or ""))
    for token, label in pairs(TYPES) do
        if n == token or string.find(n, token, 1, true) then
            return label
        end
    end
end

function Feature.Start(self, Hub)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local player = Players.LocalPlayer
    local guiParent = player and player:FindFirstChildOfClass("PlayerGui")
    if not guiParent then return false end

    local gui = Instance.new("ScreenGui")
    gui.Name = "FairwellHeaven_InteractableRadar"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 999996
    gui.Parent = guiParent

    local panel = Instance.new("Frame")
    panel.Position = UDim2.new(1, -222, 0, 76)
    panel.Size = UDim2.fromOffset(212, 116)
    panel.BackgroundColor3 = Color3.fromRGB(6, 4, 43)
    panel.BackgroundTransparency = 0.08
    panel.BorderSizePixel = 0
    panel.Parent = gui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = panel

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(27, 147, 227)
    stroke.Transparency = 0.35
    stroke.Parent = panel

    local label = Instance.new("TextLabel")
    label.Position = UDim2.fromOffset(8, 5)
    label.Size = UDim2.new(1, -16, 1, -10)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(235, 235, 245)
    label.TextSize = 9
    label.Font = Enum.Font.Code
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Top
    label.Text = "INTERACTABLES\nScanning..."
    label.Parent = panel

    local doors = Hub:GetService("Doors")
    local elapsed = 0

    self.Connection = RunService.Heartbeat:Connect(function(dt)
        elapsed += dt
        if elapsed < 0.35 then return end
        elapsed = 0

        local room = doors and doors.CurrentRoom
        local root = doors and doors.Root
        if not room or not root then
            label.Text = "INTERACTABLES\nNo current room"
            return
        end

        local found = {}
        for _, object in ipairs(room:GetDescendants()) do
            local kind = classify(object.Name)
            if kind then
                local part
                if object:IsA("BasePart") then
                    part = object
                elseif object:IsA("Model") then
                    part = object.PrimaryPart or object:FindFirstChildWhichIsA("BasePart", true)
                end
                if part then
                    local distance = (part.Position - root.Position).Magnitude
                    if distance <= 80 then
                        found[#found + 1] = {
                            kind = kind,
                            distance = distance
                        }
                    end
                end
            end
        end

        table.sort(found, function(a, b) return a.distance < b.distance end)

        local counts = {}
        for _, item in ipairs(found) do
            counts[item.kind] = (counts[item.kind] or 0) + 1
        end

        local lines = {"INTERACTABLES"}
        local order = {"KEY","KEYCARD","HIDE","DRAWER","BOOK","GENERATOR","BREAKER","LEVER","BUTTON"}
        for _, kind in ipairs(order) do
            if counts[kind] then
                table.insert(lines, string.format("%-9s x%d", kind, counts[kind]))
            end
        end

        if #lines == 1 then
            table.insert(lines, "Nothing nearby")
        end
        label.Text = table.concat(lines, "\n")
    end)

    Hub:Log("DOORS Interactable Radar started.")
    return true
end

function Feature.Stop(self)
    if self.Connection then
        self.Connection:Disconnect()
        self.Connection = nil
    end
    local Players = game:GetService("Players")
    local player = Players.LocalPlayer
    local gui = player and player:FindFirstChildOfClass("PlayerGui")
    local existing = gui and gui:FindFirstChild("FairwellHeaven_InteractableRadar")
    if existing then existing:Destroy() end
end

return Feature
