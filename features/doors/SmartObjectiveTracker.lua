--// FAIRWELL HEAVEN
--// DOORS Smart Objective Tracker
--// Informational objective HUD for mobile play.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Feature = {
    Name = "DOORS Smart Objective Tracker",
    Description = "Tracks useful room objectives such as keys, breakers, books, anchors, generators and exit-related objects.",
    Game = "DOORS",
    Connection = nil,
    Gui = nil
}

local function norm(v)
    return string.lower(tostring(v or "")):gsub("[%s_%-%./]", "")
end

local function scan(room)
    local counts = {
        KEY=0, BOOK=0, BREAKER=0, ANCHOR=0, GENERATOR=0, BUTTON=0, LEVER=0, EXIT=0
    }
    if not room then return counts end

    for _, object in ipairs(room:GetDescendants()) do
        local n = norm(object.Name)
        if string.find(n, "key", 1, true) then counts.KEY += 1 end
        if string.find(n, "book", 1, true) then counts.BOOK += 1 end
        if string.find(n, "breaker", 1, true) then counts.BREAKER += 1 end
        if string.find(n, "anchor", 1, true) then counts.ANCHOR += 1 end
        if string.find(n, "generator", 1, true) then counts.GENERATOR += 1 end
        if string.find(n, "button", 1, true) then counts.BUTTON += 1 end
        if string.find(n, "lever", 1, true) then counts.LEVER += 1 end
        if string.find(n, "exit", 1, true) then counts.EXIT += 1 end
    end
    return counts
end

function Feature.Start(self, Hub)
    local Settings = Hub:GetService("Settings")
    if Settings and Settings:GetFeatureEnabled(self.Name, false) == false then return false end

    local player = Players.LocalPlayer
    local pg = player and player:FindFirstChildOfClass("PlayerGui")
    if not pg then return false end

    local old = pg:FindFirstChild("FairwellHeaven_ObjectiveTracker")
    if old then old:Destroy() end

    local gui = Instance.new("ScreenGui")
    gui.Name = "FairwellHeaven_ObjectiveTracker"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 999995
    gui.Parent = pg

    local frame = Instance.new("Frame")
    frame.AnchorPoint = Vector2.new(0, 1)
    frame.Position = UDim2.new(0, 10, 1, -82)
    frame.Size = UDim2.fromOffset(205, 116)
    frame.BackgroundColor3 = Color3.fromRGB(6, 4, 43)
    frame.BackgroundTransparency = 0.12
    frame.BorderSizePixel = 0
    frame.Parent = gui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(27, 147, 227)
    stroke.Transparency = 0.3
    stroke.Parent = frame

    local label = Instance.new("TextLabel")
    label.Position = UDim2.fromOffset(9, 7)
    label.Size = UDim2.new(1, -18, 1, -14)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(240, 240, 248)
    label.TextSize = 10
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Top
    label.TextWrapped = true
    label.Text = "OBJECTIVES\nScanning..."
    label.Parent = frame

    self.Gui = gui
    local doors = Hub:GetService("Doors")
    local timer = 0
    local lastRoom

    local function refresh()
        local room = doors and doors.CurrentRoom
        local c = scan(room)
        local roomNumber = room and room.Name or "?"
        local lines = {"OBJECTIVES  •  ROOM " .. tostring(roomNumber)}

        local order = {
            {"KEY", "Keys"}, {"BOOK", "Books"}, {"BREAKER", "Breakers"},
            {"ANCHOR", "Anchors"}, {"GENERATOR", "Generators"},
            {"BUTTON", "Buttons"}, {"LEVER", "Levers"}, {"EXIT", "Exit"}
        }

        for _, item in ipairs(order) do
            if c[item[1]] > 0 then
                table.insert(lines, item[2] .. ": " .. tostring(c[item[1]]))
            end
        end

        if #lines == 1 then
            table.insert(lines, "No obvious objective objects")
        end

        label.Text = table.concat(lines, "\n")
    end

    refresh()

    self.Connection = RunService.Heartbeat:Connect(function(dt)
        timer += dt
        local room = doors and doors.CurrentRoom
        local roomKey = room
        if roomKey ~= lastRoom then
            lastRoom = roomKey
            refresh()
            timer = 0
            return
        end
        if timer >= 0.75 then
            timer = 0
            refresh()
        end
    end)

    Hub:Log("DOORS Smart Objective Tracker started.")
    return true
end

function Feature.Stop(self)
    if self.Connection then self.Connection:Disconnect(); self.Connection=nil end
    if self.Gui then self.Gui:Destroy(); self.Gui=nil end
end

return Feature
