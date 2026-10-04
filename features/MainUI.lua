--// FAIRWELL HEAVEN
--// Main UI - Mobile Rebuild
--// Simple, single-source feature browser.
--// The feature list is generated from Hub:GetFeatures() after registration.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local MainUI = {
    Name = "Main UI",
    Description = "Fairwell Heaven mobile-first main interface."
}

local BLUE = Color3.fromRGB(27, 147, 227)
local BACKGROUND = Color3.fromRGB(6, 4, 43)
local PANEL = Color3.fromRGB(10, 8, 55)
local PANEL2 = Color3.fromRGB(15, 13, 68)
local WHITE = Color3.fromRGB(255, 255, 255)
local GREY = Color3.fromRGB(170, 170, 185)
local GREEN = Color3.fromRGB(65, 205, 125)
local RED = Color3.fromRGB(205, 70, 85)

local INFRASTRUCTURE = {
    ["Main UI"] = true,
    ["Loading Screen"] = true,
    ["UI Repair"] = true,
    ["Mini Notification Test"] = true,
    ["Test Feature"] = true
}

local function new(className, props, parent)
    local object = Instance.new(className)
    for key, value in pairs(props or {}) do
        object[key] = value
    end
    object.Parent = parent
    return object
end

local function corner(parent, radius)
    return new("UICorner", {
        CornerRadius = UDim.new(0, radius or 8)
    }, parent)
end

local function stroke(parent, color, transparency)
    return new("UIStroke", {
        Color = color or BLUE,
        Thickness = 1,
        Transparency = transparency or 0.25
    }, parent)
end

local function label(parent, name, text, position, size, textSize, color)
    return new("TextLabel", {
        Name = name,
        Position = position,
        Size = size,
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = color or WHITE,
        TextSize = textSize or 12,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        TextTruncate = Enum.TextTruncate.AtEnd
    }, parent)
end

local function safeFeatureName(name)
    return "Feature_" .. tostring(name):gsub("[^%w_]", "_")
end

local function isDoorsFeature(info)
    return info
        and info.Feature
        and info.Feature.Game == "DOORS"
end

function MainUI:_GetFeatureList(Hub)
    local result = {}

    for _, info in ipairs(Hub:GetFeatures()) do
        if not INFRASTRUCTURE[info.Name] then
            -- DOORS features stay in the list only when DOORS is active.
            if not isDoorsFeature(info) or Hub:IsDOORS() then
                table.insert(result, info)
            end
        end
    end

    table.sort(result, function(a, b)
        return tostring(a.Name) < tostring(b.Name)
    end)

    return result
end

function MainUI:_FeatureSignature(Hub)
    local names = {}
    for _, info in ipairs(self:_GetFeatureList(Hub)) do
        table.insert(names, tostring(info.Name))
    end
    return table.concat(names, "|")
end

function MainUI:_SetFeature(Hub, name, enabled)
    local Settings = Hub:GetService("Settings")

    if enabled then
        local ok = Hub:Enable(name)
        if ok and Settings then
            Settings:SetFeatureEnabled(name, true, true)
        end
        return ok
    end

    local ok = Hub:Disable(name)
    if Settings then
        Settings:SetFeatureEnabled(name, false, true)
    end
    return ok
end

function MainUI:_CreateFeatureButton(Hub, info, list, order)
    local name = info.Name

    local button = new("TextButton", {
        Name = safeFeatureName(name),
        Size = UDim2.new(1, 0, 0, 54),
        BackgroundColor3 = PANEL,
        BorderSizePixel = 0,
        AutoButtonColor = true,
        Text = "",
        LayoutOrder = order,
        Active = true
    }, list)

    corner(button, 8)
    local border = stroke(button, BLUE, 0.45)

    local title = label(
        button,
        "Title",
        tostring(name),
        UDim2.new(0, 12, 0, 4),
        UDim2.new(1, -105, 0, 22),
        12,
        WHITE
    )
    title.Font = Enum.Font.GothamBold

    local description = tostring(
        info.Feature.Description
        or "No description available."
    )

    local sub = label(
        button,
        "Description",
        description,
        UDim2.new(0, 12, 0, 27),
        UDim2.new(1, -105, 0, 20),
        9,
        GREY
    )

    local state = new("TextLabel", {
        Name = "State",
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -10, 0.5, 0),
        Size = UDim2.fromOffset(70, 30),
        BackgroundColor3 = PANEL2,
        BorderSizePixel = 0,
        TextSize = 10,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Center
    }, button)
    corner(state, 7)

    local function refresh()
        if not button.Parent then
            return
        end

        local enabled = Hub:IsEnabled(name)

        if enabled then
            state.Text = "ON"
            state.TextColor3 = WHITE
            state.BackgroundColor3 = GREEN
            border.Color = GREEN
            border.Transparency = 0.05
        else
            state.Text = "OFF"
            state.TextColor3 = GREY
            state.BackgroundColor3 = PANEL2
            border.Color = BLUE
            border.Transparency = 0.45
        end
    end

    refresh()

    button.Activated:Connect(function()
        local enabled = Hub:IsEnabled(name)

        -- Do not let a failed enable make the button claim it is ON.
        self:_SetFeature(Hub, name, not enabled)
        refresh()
    end)

    return {
        Button = button,
        Refresh = refresh
    }
end

function MainUI:_BuildFeatureList(Hub, force)
    if not self.FeatureList or not self.FeatureList.Parent then
        return
    end

    local signature = self:_FeatureSignature(Hub)

    if not force and signature == self.FeatureSignature then
        for _, entry in pairs(self.FeatureButtons or {}) do
            entry.Refresh()
        end
        return
    end

    self.FeatureSignature = signature
    self.FeatureButtons = {}

    for _, child in ipairs(self.FeatureList:GetChildren()) do
        if child:IsA("GuiButton") or child.Name == "EmptyFeatures" then
            child:Destroy()
        end
    end

    local features = self:_GetFeatureList(Hub)

    if #features == 0 then
        local empty = new("TextLabel", {
            Name = "EmptyFeatures",
            Size = UDim2.new(1, -12, 0, 90),
            BackgroundTransparency = 1,
            Text = Hub:IsDOORS()
                and "No features are currently registered."
                or "No global features are available.",
            TextColor3 = GREY,
            TextSize = 12,
            Font = Enum.Font.Gotham,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Center,
            TextYAlignment = Enum.TextYAlignment.Center
        }, self.FeatureList)
        return
    end

    for index, info in ipairs(features) do
        self.FeatureButtons[info.Name] =
            self:_CreateFeatureButton(
                Hub,
                info,
                self.FeatureList,
                index
            )
    end
end

function MainUI:_CreateFeaturePage(Hub)
    local page = new("ScrollingFrame", {
        Name = "MainScroll",
        Position = UDim2.fromOffset(8, 8),
        Size = UDim2.new(1, -16, 1, -16),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 5,
        ScrollBarImageColor3 = BLUE,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Active = true
    }, self.Content)

    new("UIPadding", {
        PaddingLeft = UDim.new(0, 4),
        PaddingRight = UDim.new(0, 4),
        PaddingTop = UDim.new(0, 4),
        PaddingBottom = UDim.new(0, 8)
    }, page)

    label(
        page,
        "Header",
        "FAIRWELL HEAVEN",
        UDim2.new(1, -8, 0, 30),
        UDim2.fromOffset(0, 32),
        18,
        BLUE
    ).Position = UDim2.fromOffset(4, 4)

    label(
        page,
        "Hint",
        "Tap any feature below to toggle it.",
        UDim2.new(1, -8, 0, 22),
        UDim2.fromOffset(0, 22),
        10,
        GREY
    ).Position = UDim2.fromOffset(4, 38)

    local status = new("Frame", {
        Name = "Status",
        Position = UDim2.fromOffset(4, 66),
        Size = UDim2.new(1, -8, 0, 92),
        BackgroundColor3 = PANEL,
        BorderSizePixel = 0
    }, page)
    corner(status, 8)
    stroke(status, BLUE, 0.55)

    self.GameLabel = label(
        status,
        "Game",
        "Game: Unknown",
        UDim2.fromOffset(10, 7),
        UDim2.new(1, -20, 0, 22),
        11
    )

    self.PlaceLabel = label(
        status,
        "Place",
        "Place ID: " .. tostring(game.PlaceId),
        UDim2.fromOffset(10, 30),
        UDim2.new(1, -20, 0, 22),
        10,
        GREY
    )

    self.CountLabel = label(
        status,
        "Count",
        "Features: 0",
        UDim2.fromOffset(10, 53),
        UDim2.new(1, -20, 0, 22),
        10,
        GREY
    )

    label(
        page,
        "FeatureHeader",
        "FEATURES",
        UDim2.new(1, -8, 0, 28),
        UDim2.fromOffset(4, 169),
        15,
        BLUE
    ).Font = Enum.Font.GothamBold

    local list = new("ScrollingFrame", {
        Name = "FeatureList",
        Position = UDim2.fromOffset(4, 202),
        Size = UDim2.new(1, -8, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 0,
        ScrollingEnabled = false,
        CanvasSize = UDim2.new(0, 0, 0, 0)
    }, page)

    local layout = new("UIListLayout", {
        Padding = UDim.new(0, 7),
        SortOrder = Enum.SortOrder.LayoutOrder
    }, list)

    self.FeatureList = list
    self.Status = status

    return page
end

function MainUI:_CreateSimplePage(name, titleText)
    local page = new("ScrollingFrame", {
        Name = name,
        Position = UDim2.fromOffset(8, 8),
        Size = UDim2.new(1, -16, 1, -16),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 5,
        ScrollBarImageColor3 = BLUE,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = false
    }, self.Content)

    label(
        page,
        "Title",
        titleText,
        UDim2.new(1, -10, 0, 32),
        UDim2.fromOffset(5, 5),
        16,
        BLUE
    ).Font = Enum.Font.GothamBold

    return page
end

function MainUI:_CreateTabs()
    local tabs = new("Frame", {
        Name = "Tabs",
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, 0, 0, 44),
        BackgroundColor3 = PANEL,
        BorderSizePixel = 0
    }, self.Window)

    local layout = new("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        SortOrder = Enum.SortOrder.LayoutOrder
    }, tabs)

    local definitions = {
        {"MainTab", "MAIN", 1},
        {"DevTab", "LOGS", 2},
        {"FairwellChatTab", "CHAT", 3},
        {"VisualTab", "VISUAL", 4},
        {"SettingsTab", "SETTINGS", 5}
    }

    self.Tabs = {}

    for _, data in ipairs(definitions) do
        local button = new("TextButton", {
            Name = data[1],
            Size = UDim2.new(0.2, 0, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Text = data[2],
            TextColor3 = GREY,
            TextSize = 10,
            Font = Enum.Font.GothamBold,
            LayoutOrder = data[3],
            Active = true
        }, tabs)

        self.Tabs[data[1]] = button
    end
end

function MainUI:_CreateSettingsPage(Hub)
    local page = self:_CreateSimplePage(
        "SettingsScroll",
        "SETTINGS"
    )

    local info = label(
        page,
        "Info",
        "Settings are saved when you toggle a feature.",
        UDim2.new(1, -10, 0, 34),
        UDim2.fromOffset(5, 43),
        10,
        GREY
    )
    info.TextWrapped = true

    local y = 84
    local settings = Hub:GetService("Settings")

    local function addSetting(textValue, featureName)
        local button = new("TextButton", {
            Name = safeFeatureName(featureName),
            Position = UDim2.fromOffset(5, y),
            Size = UDim2.new(1, -10, 0, 44),
            BackgroundColor3 = PANEL,
            BorderSizePixel = 0,
            Text = "",
            Active = true
        }, page)
        corner(button, 7)
        stroke(button, BLUE, 0.55)
        button:SetAttribute("FeatureName", featureName)

        local title = label(
            button,
            "Text",
            textValue,
            UDim2.fromOffset(10, 0),
            UDim2.new(1, -90, 1, 0),
            11
        )
        title.Font = Enum.Font.GothamBold

        local state = label(
            button,
            "State",
            "OFF",
            UDim2.new(1, -72, 0, 0),
            UDim2.fromOffset(60, 44),
            10,
            GREY
        )
        state.TextXAlignment = Enum.TextXAlignment.Center

        local function refresh()
            local enabled = Hub:IsEnabled(featureName)
            state.Text = enabled and "ON" or "OFF"
            state.TextColor3 = enabled and GREEN or GREY
        end

        refresh()

        button.Activated:Connect(function()
            local enabled = Hub:IsEnabled(featureName)
            self:_SetFeature(Hub, featureName, not enabled)
            refresh()
        end)

        y += 51
    end

    for _, infoData in ipairs(self:_GetFeatureList(Hub)) do
        addSetting(infoData.Name, infoData.Name)
    end

    local reset = new("TextButton", {
        Name = "ResetSettings",
        Position = UDim2.fromOffset(5, y + 8),
        Size = UDim2.new(1, -10, 0, 44),
        BackgroundColor3 = RED,
        BorderSizePixel = 0,
        Text = "RESET FEATURE SETTINGS",
        TextColor3 = WHITE,
        TextSize = 11,
        Font = Enum.Font.GothamBold
    }, page)
    corner(reset, 7)

    reset.Activated:Connect(function()
        if settings and settings.Reset then
            settings:Reset()
        end

        -- Runtime state must match the reset state.
        for _, infoData in ipairs(Hub:GetFeatures()) do
            if not INFRASTRUCTURE[infoData.Name] then
                Hub:Disable(infoData.Name)
            end
        end

        self.FeatureSignature = nil
        self:_BuildFeatureList(Hub, true)
        Hub:Notify(
            "SETTINGS",
            "Feature settings were reset.",
            "SUCCESS",
            3
        )
    end)
end

function MainUI:_CreateVisualPage(Hub)
    local page = self:_CreateSimplePage(
        "VisualScroll",
        "VISUAL FEATURES"
    )

    label(
        page,
        "Info",
        "Visual features are shown here when available.",
        UDim2.new(1, -10, 0, 30),
        UDim2.fromOffset(5, 43),
        10,
        GREY
    )

    -- Visual page uses the same authoritative feature objects.
    local y = 80
    for _, info in ipairs(self:_GetFeatureList(Hub)) do
        if tostring(info.Name):find("VISUAL") or tostring(info.Name):find("DOORS") then
            local button = new("TextButton", {
                Name = "Visual_" .. safeFeatureName(info.Name),
                Position = UDim2.fromOffset(5, y),
                Size = UDim2.new(1, -10, 0, 42),
                BackgroundColor3 = PANEL,
                BorderSizePixel = 0,
                Text = "",
                Active = true
            }, page)
            corner(button, 7)
            stroke(button, BLUE, 0.55)

            local textLabel = label(
                button,
                "Text",
                info.Name,
                UDim2.fromOffset(10, 0),
                UDim2.new(1, -100, 1, 0),
                10
            )
            textLabel.Font = Enum.Font.GothamBold

            local state = label(
                button,
                "State",
                "OFF",
                UDim2.new(1, -80, 0, 0),
                UDim2.fromOffset(65, 42),
                10,
                GREY
            )
            state.TextXAlignment = Enum.TextXAlignment.Center

            local function refresh()
                local enabled = Hub:IsEnabled(info.Name)
                state.Text = enabled and "ON" or "OFF"
                state.TextColor3 = enabled and GREEN or GREY
            end

            refresh()

            button.Activated:Connect(function()
                self:_SetFeature(Hub, info.Name, not Hub:IsEnabled(info.Name))
                refresh()
            end)

            y += 48
        end
    end
end

function MainUI:_Switch(pageName)
    for name, page in pairs(self.Pages or {}) do
        page.Visible = name == pageName
    end

    for name, button in pairs(self.Tabs or {}) do
        button.TextColor3 = GREY
    end

    local tabMap = {
        Main = "MainTab",
        Logs = "DevTab",
        Chat = "FairwellChatTab",
        Visual = "VisualTab",
        Settings = "SettingsTab"
    }

    local tab = self.Tabs and self.Tabs[tabMap[pageName]]
    if tab then
        tab.TextColor3 = BLUE
    end

    self.CurrentPage = pageName
end

function MainUI:_UpdateStatus(Hub)
    if not self.GameLabel then
        return
    end

    self.GameLabel.Text =
        "Game: " .. tostring(Hub.Game.Name)

    local features = self:_GetFeatureList(Hub)
    local enabled = 0

    for _, info in ipairs(features) do
        if Hub:IsEnabled(info.Name) then
            enabled += 1
        end
    end

    self.CountLabel.Text =
        "Features: " .. tostring(#features)
        .. "  •  Enabled: " .. tostring(enabled)

    if self.Status then
        self.Status.BackgroundColor3 =
            Hub:IsDOORS() and Color3.fromRGB(9, 18, 48) or PANEL
    end
end

function MainUI:_StartDragging()
    local window = self.Window
    local handle = self.DragHandle

    local dragging = false
    local dragStart
    local startPosition

    local function begin(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1
            and input.UserInputType ~= Enum.UserInputType.Touch then
            return
        end

        dragging = true
        dragStart = input.Position
        startPosition = window.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end

    local function update(input)
        if not dragging then
            return
        end

        local delta = input.Position - dragStart
        window.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end

    handle.InputBegan:Connect(begin)
    UserInputService.InputChanged:Connect(update)
end

function MainUI:Start(Hub)
    if self.Gui and self.Gui.Parent then
        self.Gui.Enabled = true
        return true
    end

    local player = Players.LocalPlayer
    if not player then
        return false
    end

    local playerGui = player:WaitForChild("PlayerGui")

    -- Remove only the old copy belonging to this UI.
    local oldGui = playerGui:FindFirstChild("FairwellHeaven_MainUI")
    if oldGui then
        oldGui:Destroy()
    end

    local gui = new("ScreenGui", {
        Name = "FairwellHeaven_MainUI",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        DisplayOrder = 1000002,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    }, playerGui)

    self.Gui = gui

    local window = new("Frame", {
        Name = "Window",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromScale(0.92, 0.78),
        BackgroundColor3 = BACKGROUND,
        BorderSizePixel = 0,
        ClipsDescendants = true
    }, gui)
    corner(window, 12)
    stroke(window, BLUE, 0.1)

    local constraint = new("UISizeConstraint", {
        Name = "MobileSize",
        MinSize = Vector2.new(300, 390),
        MaxSize = Vector2.new(900, 720)
    }, window)

    self.Window = window

    local top = new("Frame", {
        Name = "TopBar",
        Size = UDim2.new(1, 0, 0, 44),
        BackgroundColor3 = PANEL,
        BorderSizePixel = 0
    }, window)

    self.DragHandle = top

    label(
        top,
        "Title",
        "FAIRWELL HEAVEN",
        UDim2.fromOffset(12, 0),
        UDim2.new(1, -55, 1, 0),
        14,
        WHITE
    ).Font = Enum.Font.GothamBold

    local close = new("TextButton", {
        Name = "Close",
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -8, 0.5, 0),
        Size = UDim2.fromOffset(32, 30),
        BackgroundColor3 = Color3.fromRGB(65, 20, 35),
        BorderSizePixel = 0,
        Text = "×",
        TextColor3 = WHITE,
        TextSize = 20,
        Font = Enum.Font.GothamBold
    }, top)
    corner(close, 7)

    local content = new("Frame", {
        Name = "Content",
        Position = UDim2.fromOffset(0, 44),
        Size = UDim2.new(1, 0, 1, -44),
        BackgroundTransparency = 1
    }, window)

    self.Content = content

    self:_CreateTabs()

    local pages = {}
    pages.Main = self:_CreateFeaturePage(Hub)
    pages.Logs = self:_CreateSimplePage("DevScroll", "LOGS")
    pages.Chat = self:_CreateSimplePage("ChatScroll", "FAIRWELL CHAT")
    pages.Visual = self:_CreateVisualPage(Hub)
    pages.Settings = self:_CreateSimplePage("SettingsScroll", "SETTINGS")

    -- Replace the placeholder settings page with the actual one.
    pages.Settings:Destroy()
    self:_CreateSettingsPage(Hub)
    pages.Settings = content:FindFirstChild("SettingsScroll")

    self.Pages = pages

    self:_BuildFeatureList(Hub, true)
    self:_UpdateStatus(Hub)

    -- Tab buttons are wired once here. Pages are never duplicated.
    self.Tabs.MainTab.Activated:Connect(function()
        self:_Switch("Main")
    end)
    self.Tabs.DevTab.Activated:Connect(function()
        self:_Switch("Logs")
    end)
    self.Tabs.FairwellChatTab.Activated:Connect(function()
        self:_Switch("Chat")
    end)
    self.Tabs.VisualTab.Activated:Connect(function()
        self:_Switch("Visual")
    end)
    self.Tabs.SettingsTab.Activated:Connect(function()
        self:_Switch("Settings")
    end)

    self:_Switch("Main")
    self:_StartDragging()

    close.Activated:Connect(function()
        gui.Enabled = false
    end)

    -- Refresh every 0.75s instead of every frame.
    self.RefreshLoop = task.spawn(function()
        while self.Gui == gui and gui.Parent do
            self:_UpdateStatus(Hub)
            self:_BuildFeatureList(Hub, false)
            task.wait(0.75)
        end
    end)

    -- Fairwell notification support while minimized.
    if Hub.NotificationEvent then
        self.NotificationConnection =
            Hub.NotificationEvent.Event:Connect(function(title, message)
                if not gui.Parent or gui.Enabled then
                    return
                end

                local notice = new("TextLabel", {
                    Name = "MiniNotification",
                    AnchorPoint = Vector2.new(1, 1),
                    Position = UDim2.new(1, -12, 1, -12),
                    Size = UDim2.new(0.8, 0, 0, 52),
                    BackgroundColor3 = PANEL,
                    BorderSizePixel = 0,
                    Text = tostring(title or "FAIRWELL")
                        .. "\\n"
                        .. tostring(message or ""),
                    TextColor3 = WHITE,
                    TextSize = 10,
                    Font = Enum.Font.Gotham,
                    TextWrapped = true,
                    ZIndex = 50
                }, gui)
                corner(notice, 8)
                stroke(notice, BLUE, 0.2)

                task.delay(4, function()
                    if notice then
                        notice:Destroy()
                    end
                end)
            end)
    end

    Hub:Log("Main UI rebuilt for mobile.")
    return true
end

function MainUI:Stop()
    if self.NotificationConnection then
        self.NotificationConnection:Disconnect()
        self.NotificationConnection = nil
    end

    self.Gui = nil

    if self.RefreshLoop then
        task.cancel(self.RefreshLoop)
        self.RefreshLoop = nil
    end

    if self.Window then
        self.Window = nil
    end

    self.Content = nil
    self.FeatureList = nil
    self.FeatureButtons = nil
    self.FeatureSignature = nil
end

return MainUI
