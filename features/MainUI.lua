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
        Size = UDim2.new(1, 0, 0, 36),
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
        Size = UDim2.fromOffset(58, 26),
        BackgroundColor3 = PANEL2,
        BorderSizePixel = 0,
        TextSize = 9,
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
            TextSize = 9,
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
        PaddingLeft = UDim.new(0, 3),
        PaddingRight = UDim.new(0, 3),
        PaddingTop = UDim.new(0, 3),
        PaddingBottom = UDim.new(0, 5)
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
        Size = UDim2.new(1, 0, 0, 36),
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
            TextSize = 9,
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

    -- Main UI visibility is a UI control, not a feature toggle.
    local visibilityButton = new("TextButton", {
        Name = "ShowMainUI",
        Position = UDim2.fromOffset(5, y),
        Size = UDim2.new(1, -10, 0, 44),
        BackgroundColor3 = PANEL,
        BorderSizePixel = 0,
        Text = "",
        Active = true
    }, page)
    corner(visibilityButton, 7)
    local visibilityStroke = stroke(visibilityButton, GREEN, 0.35)
    local visibilityText = label(
        visibilityButton,
        "Text",
        "SHOW MAIN UI",
        UDim2.fromOffset(10, 0),
        UDim2.new(1, -90, 1, 0),
        11
    )
    visibilityText.Font = Enum.Font.GothamBold
    local visibilityState = label(
        visibilityButton,
        "State",
        "ON",
        UDim2.new(1, -72, 0, 0),
        UDim2.fromOffset(60, 44),
        10,
        GREEN
    )
    visibilityState.TextXAlignment = Enum.TextXAlignment.Center

    local function refreshVisibility()
        local visible = not self.Hidden
        visibilityState.Text = visible and "ON" or "OFF"
        visibilityState.TextColor3 = visible and GREEN or GREY
        visibilityStroke.Color = visible and GREEN or BLUE
    end

    visibilityButton.Activated:Connect(function()
        self:SetVisible(self.Hidden)
        refreshVisibility()
    end)

    refreshVisibility()
    y += 51

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
        TextSize = 9,
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
        "FAIRWELL VISUALS"
    )

    label(
        page,
        "Info",
        "Only visual/overlay features appear here.",
        UDim2.new(1, -10, 0, 30),
        UDim2.fromOffset(5, 43),
        10,
        GREY
    )

    local VISUAL_FEATURES = {
        ["VISUAL FPS Counter"] = true,
        ["VISUAL Clock"] = true,
        ["VISUAL Crosshair"] = true,
        ["VISUAL Performance HUD"] = true,
        ["VISUAL DOORS Item Labels"] = true,
        ["VISUAL DOORS Entity Markers"] = true,
    }

    local y = 80
    for _, info in ipairs(self:_GetFeatureList(Hub)) do
        if VISUAL_FEATURES[info.Name] then
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

    if y == 80 then
        label(
            page,
            "Empty",
            "No visual features are registered.",
            UDim2.new(1, -10, 0, 50),
            UDim2.fromOffset(5, 80),
            10,
            GREY
        ).TextXAlignment = Enum.TextXAlignment.Center
    end
end

function MainUI:_CreateChatPage(Hub)
    local page = self:_CreateSimplePage("FairwellChat", "FAIRWELL CHAT")

    label(page, "Info", "Fairwell is here. Talk to him.", UDim2.new(1, -10, 0, 30), UDim2.fromOffset(5, 43), 10, GREY)

    local stage = new("Frame", {
        Name = "FairwellStage",
        Position = UDim2.fromOffset(5, 78),
        Size = UDim2.new(1, -10, 0, 270),
        BackgroundColor3 = Color3.fromRGB(4, 3, 30),
        BorderSizePixel = 0,
        ClipsDescendants = true
    }, page)
    corner(stage, 9)
    stroke(stage, BLUE, 0.2)

    label(stage, "StageHeader", "FAIRWELL", UDim2.fromOffset(12, 8), UDim2.fromOffset(90, 24), 14, WHITE).Font = Enum.Font.GothamBold
    label(stage, "StageStatus", "● ONLINE", UDim2.fromOffset(94, 10), UDim2.fromOffset(100, 20), 9, GREEN).Font = Enum.Font.GothamBold

    local bubble = new("TextLabel", {
        Name = "SpeechBubble",
        Position = UDim2.new(0, 194, 0, 42),
        Size = UDim2.new(1, -204, 0, 58),
        BackgroundColor3 = PANEL,
        BorderSizePixel = 0,
        Text = "",
        TextColor3 = WHITE,
        TextSize = 10,
        Font = Enum.Font.Gotham,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center
    }, stage)
    corner(bubble, 8)
    stroke(bubble, BLUE, 0.35)
    new("UIPadding", {
        PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10),
        PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 6)
    }, bubble)

    local messages = new("ScrollingFrame", {
        Name = "Messages",
        Position = UDim2.new(0, 194, 0, 108),
        Size = UDim2.new(1, -204, 0, 150),
        BackgroundColor3 = Color3.fromRGB(5, 4, 32),
        BackgroundTransparency = 0.15,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = BLUE,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new(0, 0, 0, 0)
    }, stage)
    corner(messages, 7)
    new("UIPadding", {
        PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 6),
        PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6)
    }, messages)
    new("UIListLayout", {Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder}, messages)

    local avatarFrame = new("Frame", {
        Name = "AvatarFrame",
        Position = UDim2.fromOffset(10, 42),
        Size = UDim2.fromOffset(170, 212),
        BackgroundColor3 = Color3.fromRGB(7, 8, 24),
        BackgroundTransparency = 0.12,
        BorderSizePixel = 0
    }, stage)
    corner(avatarFrame, 10)
    stroke(avatarFrame, BLUE, 0.45)

    local wall = new("Frame", {
        Name = "FairwellWall",
        Position = UDim2.fromOffset(8, 60),
        Size = UDim2.new(0, 7, 0, 150),
        BackgroundColor3 = Color3.fromRGB(18, 22, 42),
        BorderSizePixel = 0
    }, stage)
    stroke(wall, Color3.fromRGB(35, 110, 150), 0.35)

    local artwork = new("ImageLabel", {
        Name = "FairwellArtwork",
        Position = UDim2.fromOffset(10, 44),
        Size = UDim2.fromOffset(170, 210),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Image = "",
        ScaleType = Enum.ScaleType.Fit
    }, stage)
    corner(artwork, 10)

    label(stage, "AvatarName", "@fairwelladmi • ARTWORK", UDim2.fromOffset(10, 238), UDim2.fromOffset(170, 22), 9, GREY).TextXAlignment = Enum.TextXAlignment.Center

    local base = "https://raw.githubusercontent.com/reepyissomeone/Fairwell-Heaven/main/assets/Fairwell/"
    local urls = {
        Silent = base .. "Silent.png",
        Talking = base .. "talking.png",
        Thinking = base .. "thinking.png"
    }
    local files = {
        Silent = "FairwellHeaven/assets/Fairwell/Silent.png",
        Talking = "FairwellHeaven/assets/Fairwell/talking.png",
        Thinking = "FairwellHeaven/assets/Fairwell/thinking.png"
    }
    local images = {}

    local function assetLoader()
        if type(getcustomasset) == "function" then return getcustomasset end
        if type(getsynasset) == "function" then return getsynasset end
        if type(getcustomassetfromfile) == "function" then return getcustomassetfromfile end
        return nil
    end

    local function ensureFolder(path)
        if type(makefolder) ~= "function" then return end
        local current = ""
        for part in string.gmatch(path, "[^/]+") do
            current = current == "" and part or current .. "/" .. part
            pcall(makefolder, current)
        end
    end

    local function loadArtwork(state)
        local loader = assetLoader()
        if not loader then
            Hub:Log("Custom asset loader unavailable; Fairwell artwork cannot display.", "WARN")
            return
        end
        local path, url = files[state], urls[state]
        local ok, result = pcall(function()
            ensureFolder("FairwellHeaven/assets/Fairwell")
            if type(isfile) == "function" and isfile(path) then
                return loader(path)
            end
            if type(writefile) ~= "function" then error("writefile unavailable") end
            local downloaded = game:HttpGet(url .. "?cache=" .. tostring(math.floor(os.clock() * 1000000)))
            if type(downloaded) ~= "string" or downloaded == "" then error("download failed") end
            writefile(path, downloaded)
            return loader(path)
        end)
        if ok and type(result) == "string" and result ~= "" then
            images[state] = result
        else
            Hub:Log("Failed to load Fairwell " .. state .. " artwork.", "WARN")
        end
    end

    for _, state in ipairs({"Silent", "Talking", "Thinking"}) do
        loadArtwork(state)
    end

    local status = stage:FindFirstChild("StageStatus")
    local function setArtwork(state)
        state = images[state] and state or (images.Silent and "Silent" or state)
        if images[state] then artwork.Image = images[state] end
        status.Text = state == "Talking" and "● TALKING" or state == "Thinking" and "● THINKING" or "● ONLINE"
    end
    setArtwork("Silent")

    local speechId = 0
    local function speak(text)
        speechId += 1
        local id = speechId
        setArtwork("Talking")
        bubble.Text = tostring(text)
        task.delay(math.max(1.5, math.min(5, #tostring(text) * 0.055)), function()
            if id == speechId and stage.Parent then setArtwork("Silent") end
        end)
    end

    local function addMessage(author, text, color)
        local row = new("TextLabel", {
            Name = "Message",
            Size = UDim2.new(1, -4, 0, 30),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Text = tostring(author) .. ": " .. tostring(text),
            TextColor3 = color or WHITE,
            TextSize = 9,
            Font = Enum.Font.Gotham,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Center
        }, messages)
        task.defer(function()
            if messages.Parent then
                messages.CanvasPosition = Vector2.new(0, math.max(0, messages.AbsoluteCanvasSize.Y))
            end
        end)
    end

    local input = new("TextBox", {
        Name = "Input",
        Position = UDim2.fromOffset(5, 356),
        Size = UDim2.new(1, -72, 0, 36),
        BackgroundColor3 = PANEL,
        BorderSizePixel = 0,
        ClearTextOnFocus = false,
        PlaceholderText = "Talk to Fairwell...",
        Text = "",
        TextColor3 = WHITE,
        PlaceholderColor3 = GREY,
        TextSize = 10,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left
    }, page)
    corner(input, 6)
    stroke(input, BLUE, 0.45)

    local send = new("TextButton", {
        Name = "Send",
        Position = UDim2.new(1, -62, 0, 356),
        Size = UDim2.fromOffset(57, 36),
        BackgroundColor3 = BLUE,
        BorderSizePixel = 0,
        Text = "SEND",
        TextColor3 = WHITE,
        TextSize = 9,
        Font = Enum.Font.GothamBold,
        Active = true
    }, page)
    corner(send, 6)

    local function reply(message)
        local lower = string.lower(message)
        local replies = {
            {"hello", "Hello. I was wondering when you'd show up."},
            {"hi", "Hi. I'm Fairwell. What's going on?"},
            {"hey", "Hey. I'm listening."},
            {"who are you", "I'm Fairwell. The one sitting in the corner of this UI."},
            {"fairwell", "You called? I'm right here."},
            {"help", "Try /help if you want to see the chat commands."},
            {"doors", "DOORS detected. Keep an eye on that next room."},
            {"scary", "Good. It would be boring if everything felt safe."},
            {"thanks", "You're welcome."},
            {"thank", "You're welcome."},
            {"bye", "See you later."}
        }
        for _, entry in ipairs(replies) do
            if lower == entry[1] or string.find(lower, "%f[%a]" .. entry[1] .. "%f[%A]") then
                return entry[2]
            end
        end
        return "I heard you. Tell me more."
    end

    speak("Hey! I'm Fairwell. Talk to me.")
    addMessage("FAIRWELL", "Hey! I'm Fairwell. Talk to me.", BLUE)

    local function sendMessage()
        local message = input.Text:gsub("^%s+", ""):gsub("%s+$", "")
        if message == "" then return end
        input.Text = ""
        local lower = message:lower()

        if lower == "/help" then
            local text = "/clear • clears chat | /status • hub status | /help • commands"
            speak(text); addMessage("FAIRWELL", text, BLUE); return
        elseif lower == "/clear" then
            for _, child in ipairs(messages:GetChildren()) do
                if child:IsA("TextLabel") and child.Name == "Message" then child:Destroy() end
            end
            local text = "Chat cleared. I'm still here."
            speak(text); addMessage("FAIRWELL", text, BLUE); return
        elseif lower == "/status" then
            local text = "Hub online • " .. tostring(Hub.Version or "unknown") .. " • " .. tostring(Hub.Game.Name or "Unknown")
            speak(text); addMessage("FAIRWELL", text, BLUE); return
        end

        addMessage(Players.LocalPlayer and Players.LocalPlayer.Name or "YOU", message, GREEN)
        setArtwork("Thinking")
        task.delay(0.35, function()
            if not messages.Parent then return end
            local response = reply(message)
            speak(response)
            addMessage("FAIRWELL", response, BLUE)
        end)
    end

    send.Activated:Connect(sendMessage)
    input.FocusLost:Connect(function(enterPressed)
        if enterPressed then sendMessage() end
    end)

    return page
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

    if not window or not handle then
        return
    end

    local dragging = false
    local dragStart = nil
    local startPosition = nil

    local function begin(input)
        local inputType = input.UserInputType
        if inputType ~= Enum.UserInputType.Touch
            and inputType ~= Enum.UserInputType.MouseButton1 then
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

    local function move(input)
        if not dragging or not dragStart or not startPosition then
            return
        end

        local inputType = input.UserInputType
        if inputType ~= Enum.UserInputType.Touch
            and inputType ~= Enum.UserInputType.MouseMovement then
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
    handle.InputChanged:Connect(move)

    UserInputService.InputChanged:Connect(function(input)
        if dragging then
            move(input)
        end
    end)
end

function MainUI:_CreateCompanion(Hub)
    local player = Players.LocalPlayer
    if not player then return false end
    local playerGui = player:WaitForChild("PlayerGui")

    local old = playerGui:FindFirstChild("FairwellHeaven_Companion")
    if old then old:Destroy() end

    local gui = new("ScreenGui", {
        Name = "FairwellHeaven_Companion",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        DisplayOrder = 1000003,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    }, playerGui)

    local holder = new("Frame", {
        Name = "Companion",
        AnchorPoint = Vector2.new(1, 1),
        Position = UDim2.new(1, -16, 1, -16),
        Size = UDim2.fromOffset(82, 82),
        BackgroundTransparency = 1
    }, gui)

    local button = new("ImageButton", {
        Name = "Fairwell",
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Image = "",
        ScaleType = Enum.ScaleType.Fit,
        AutoButtonColor = false,
        Active = true,
        ZIndex = 20
    }, holder)

    local bubble = new("TextLabel", {
        Name = "Notification",
        AnchorPoint = Vector2.new(1, 1),
        Position = UDim2.new(0, -8, 0, -4),
        Size = UDim2.fromOffset(210, 62),
        BackgroundColor3 = PANEL,
        BorderSizePixel = 0,
        Text = "",
        TextColor3 = WHITE,
        TextSize = 10,
        Font = Enum.Font.Gotham,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        Visible = false,
        ZIndex = 30
    }, holder)
    corner(bubble, 9)
    stroke(bubble, BLUE, 0.15)
    new("UIPadding", {
        PaddingLeft = UDim.new(0, 9),
        PaddingRight = UDim.new(0, 9),
        PaddingTop = UDim.new(0, 5),
        PaddingBottom = UDim.new(0, 5)
    }, bubble)

    local title = new("TextLabel", {
        Name = "NotificationTitle",
        Position = UDim2.fromOffset(8, -19),
        Size = UDim2.fromOffset(194, 18),
        BackgroundTransparency = 1,
        Text = "",
        TextColor3 = BLUE,
        TextSize = 9,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Visible = false,
        ZIndex = 31
    }, bubble)

    local base = "https://raw.githubusercontent.com/reepyissomeone/Fairwell-Heaven/main/assets/Fairwell/"
    local urls = {
        Idle = base .. "Idle.png",
        ALERT = base .. "ALERT.png",
        Ctalking = base .. "Ctalking.png",
        Cthinking = base .. "Cthinking.png",
        Yippe = base .. "Yippe.png",
        uhoh = base .. "uhoh.png"
    }
    local files = {
        Idle = "FairwellHeaven/assets/Fairwell/Idle.png",
        ALERT = "FairwellHeaven/assets/Fairwell/ALERT.png",
        Ctalking = "FairwellHeaven/assets/Fairwell/Ctalking.png",
        Cthinking = "FairwellHeaven/assets/Fairwell/Cthinking.png",
        Yippe = "FairwellHeaven/assets/Fairwell/Yippe.png",
        uhoh = "FairwellHeaven/assets/Fairwell/uhoh.png"
    }
    local images = {}

    local function assetLoader()
        if type(getcustomasset) == "function" then return getcustomasset end
        if type(getsynasset) == "function" then return getsynasset end
        if type(getcustomassetfromfile) == "function" then return getcustomassetfromfile end
        return nil
    end

    local function ensureFolder(path)
        if type(makefolder) ~= "function" then return end
        local current = ""
        for part in string.gmatch(path, "[^/]+") do
            current = current == "" and part or current .. "/" .. part
            pcall(makefolder, current)
        end
    end

    local function loadAsset(state)
        local loader = assetLoader()
        if not loader then return end

        local path, url = files[state], urls[state]
        local ok, result = pcall(function()
            ensureFolder("FairwellHeaven/assets/Fairwell")
            if type(isfile) == "function" and isfile(path) then
                return loader(path)
            end
            if type(writefile) ~= "function" then
                error("writefile unavailable")
            end
            local downloaded = game:HttpGet(
                url .. "?cache=" .. tostring(math.floor(os.clock() * 1000000))
            )
            if type(downloaded) ~= "string" or downloaded == "" then
                error("asset download failed")
            end
            writefile(path, downloaded)
            return loader(path)
        end)

        if ok and type(result) == "string" and result ~= "" then
            images[state] = result
        end
    end

    -- Asset downloads happen in the background so the main window can
    -- render immediately even when GitHub/custom-asset APIs are slow.
    task.spawn(function()
        for _, state in ipairs({"Idle", "ALERT", "Ctalking", "Cthinking", "Yippe", "uhoh"}) do
            loadAsset(state)
        end
    end)

    local stateToken = 0
    local function setState(state, duration)
        stateToken += 1
        local token = stateToken

        if images[state] then
            button.Image = images[state]
        elseif images.Idle then
            button.Image = images.Idle
        end

        if duration then
            task.delay(duration, function()
                if token == stateToken and holder.Parent then
                    if images.Idle then
                        button.Image = images.Idle
                    end
                end
            end)
        end
    end

    setState("Idle")

    local function showNotification(noticeTitle, message, kind, duration)
        if not gui.Parent or not self.Hidden then
            return
        end

        local normalized = string.upper(tostring(kind or "INFO"))
        local state = "Cthinking"
        local accent = BLUE

        if normalized == "SUCCESS" then
            state = "Yippe"
            accent = GREEN
        elseif normalized == "WARNING" then
            state = "ALERT"
            accent = Color3.fromRGB(255, 185, 70)
        elseif normalized == "ERROR" then
            state = "uhoh"
            accent = RED
        elseif normalized == "INFO" then
            state = "Ctalking"
        end

        duration = math.clamp(tonumber(duration) or 4, 1, 15)
        setState(state, math.min(duration, 3))

        title.Text = string.upper(tostring(noticeTitle or "FAIRWELL"))
        title.TextColor3 = accent
        title.Visible = true
        bubble.Text = tostring(message or "")
        bubble.Visible = true

        task.delay(duration, function()
            if not bubble.Parent then return end
            bubble.Visible = false
            title.Visible = false
        end)
    end

    self.CompanionGui = gui
    self.CompanionHolder = holder
    self.CompanionButton = button
    self.CompanionBubble = bubble
    self.CompanionSetState = setState
    self.CompanionNotify = showNotification

    button.Activated:Connect(function()
        self:SetVisible(true)
    end)

    -- Touch/mouse dragging. Activated remains available for tapping.
    local dragging = false
    local dragStart
    local startPosition

    local function beginDrag(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1
            and input.UserInputType ~= Enum.UserInputType.Touch then
            return
        end

        dragging = true
        dragStart = input.Position
        startPosition = holder.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end

    local function updateDrag(input)
        if not dragging then return end
        local delta = input.Position - dragStart
        holder.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end

    button.InputBegan:Connect(beginDrag)
    UserInputService.InputChanged:Connect(updateDrag)

    -- MainUI may have been hidden before the companion finished loading.
    gui.Enabled = self.Hidden == true
    if not self.Hidden then
        gui.Enabled = false
    end

    return true
end

function MainUI:SetVisible(visible)
    visible = visible == true
    self.Hidden = not visible

    if self.Gui and self.Gui.Parent then
        self.Gui:SetAttribute("FairwellHidden", not visible)
        self.Gui.Enabled = visible
    end

    if self.CompanionGui and self.CompanionGui.Parent then
        self.CompanionGui.Enabled = not visible
    end

    if visible and self.CompanionBubble then
        self.CompanionBubble.Visible = false
        local title = self.CompanionBubble:FindFirstChild("NotificationTitle")
        if title then title.Visible = false end
    end
end

function MainUI:Start(Hub)
    if self.Gui and self.Gui.Parent then
        self:SetVisible(true)
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
    self.Hidden = false

    -- Dedicated floating mobile toggle. This is separate from the main
    -- window so it remains easy to find and use.
    local toggle = new("TextButton", {
        Name = "FairwellToggle",
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 10, 0.5, 0),
        Size = UDim2.fromOffset(52, 52),
        BackgroundColor3 = PANEL,
        BorderSizePixel = 0,
        Text = "FW",
        TextColor3 = WHITE,
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        Active = true,
        ZIndex = 100
    }, gui)
    corner(toggle, 12)
    stroke(toggle, BLUE, 0.05)

    local toggleHint = label(
        toggle,
        "Hint",
        "MENU",
        UDim2.new(0, 0, 1, -15),
        UDim2.new(1, 0, 0, 12),
        7,
        GREY
    )
    toggleHint.TextXAlignment = Enum.TextXAlignment.Center

    toggle.Activated:Connect(function()
        self:SetVisible(not self.Hidden)
    end)

    self.ToggleButton = toggle

    -- Companion assets are optional. Never let a custom-asset API or
    -- network request block the main UI from appearing.
    task.spawn(function()
        local ok, err = pcall(function()
            self:_CreateCompanion(Hub)
        end)
        if not ok then
            Hub:Warn("Companion startup failed:", err)
        end
    end)

    local window = new("Frame", {
        Name = "Window",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromScale(0.72, 0.72),
        BackgroundColor3 = BACKGROUND,
        BorderSizePixel = 0,
        ClipsDescendants = true
    }, gui)
    corner(window, 12)
    stroke(window, BLUE, 0.1)

    local constraint = new("UISizeConstraint", {
        Name = "MobileSize",
        MinSize = Vector2.new(260, 330),
        MaxSize = Vector2.new(700, 620)
    }, window)

    self.Window = window

    local top = new("Frame", {
        Name = "TopBar",
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = PANEL,
        BorderSizePixel = 0
    }, window)

    -- Dedicated invisible touch surface for reliable mobile dragging.
    -- It sits behind the title/minimize/close controls so those buttons
    -- remain tappable while the rest of the top bar can be dragged.
    local dragSurface = new("TextButton", {
        Name = "DragSurface",
        Size = UDim2.new(1, -42, 1, 0),
        Position = UDim2.fromOffset(0, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        Active = true,
        ZIndex = 1
    }, top)

    self.DragHandle = dragSurface

    label(
        top,
        "Title",
        "FAIRWELL HEAVEN",
        UDim2.fromOffset(12, 0),
        UDim2.new(1, -12, 1, 0),
        14,
        WHITE
    ).Font = Enum.Font.GothamBold

    local close = new("TextButton", {
        Name = "Close",
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -8, 0.5, 0),
        Size = UDim2.fromOffset(28, 26),
        BackgroundColor3 = Color3.fromRGB(65, 20, 35),
        BorderSizePixel = 0,
        Text = "×",
        TextColor3 = WHITE,
        TextSize = 13,
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
    pages.Chat = self:_CreateChatPage(Hub)
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
        self:SetVisible(false)
    end)

    -- Refresh every 0.75s instead of every frame.
    self.RefreshLoop = task.spawn(function()
        while self.Gui == gui and gui.Parent do
            self:_UpdateStatus(Hub)
            self:_BuildFeatureList(Hub, false)
            task.wait(0.75)
        end
    end)

    -- Companion Mode notification bridge.
    if Hub.NotificationEvent then
        self.NotificationConnection =
            Hub.NotificationEvent.Event:Connect(function(title, message, kind, duration)
                if self.CompanionNotify then
                    self.CompanionNotify(title, message, kind, duration)
                end
            end)
    end

    Hub:Log("Main UI rebuilt for mobile.")
    return true
end

function MainUI:Stop()
    if self.CompanionGui then
        self.CompanionGui:Destroy()
        self.CompanionGui = nil
    end
    self.CompanionHolder = nil
    self.CompanionButton = nil
    self.CompanionBubble = nil
    self.CompanionSetState = nil
    self.CompanionNotify = nil

    if self.ToggleButton then
        self.ToggleButton:Destroy()
        self.ToggleButton = nil
    end

    self.DragHandle = nil
    self.Hidden = false

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
