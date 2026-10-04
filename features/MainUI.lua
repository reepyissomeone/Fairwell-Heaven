--// FAIRWELL HEAVEN
--// Main UI - Mobile Rebuild
--// Simple, single-source feature browser.
--// The feature list is generated from Hub:GetFeatures() after registration.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

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
    ["Test Feature"] = true,
    ["Developer Diagnostics"] = true,
    ["Fairwell Dev Lab"] = true
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

function MainUI:_CreateLogsPage(Hub)
    local page = self:_CreateSimplePage("DevScroll", "DEV CENTER")

    local status = label(
        page,
        "Status",
        "Runtime diagnostics and developer log.",
        UDim2.new(1, -10, 0, 42),
        UDim2.fromOffset(5, 43),
        10,
        GREY
    )
    status.TextWrapped = true

    local diagnostics = Hub:GetFeature("Developer Diagnostics")

    local reportBox = new("TextBox", {
        Name = "DiagnosticReport",
        Position = UDim2.fromOffset(5, 88),
        Size = UDim2.new(1, -10, 0, 220),
        BackgroundColor3 = PANEL,
        BorderSizePixel = 0,
        TextColor3 = WHITE,
        PlaceholderColor3 = GREY,
        Text = "",
        PlaceholderText = "Diagnostic report will appear here.",
        TextSize = 9,
        Font = Enum.Font.Code,
        TextWrapped = false,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        ClearTextOnFocus = false,
        MultiLine = true,
        Active = true
    }, page)
    corner(reportBox, 7)
    stroke(reportBox, BLUE, 0.45)

    local refresh = new("TextButton", {
        Name = "RefreshDiagnostics",
        Position = UDim2.fromOffset(5, 316),
        Size = UDim2.new(0.48, -7, 0, 40),
        BackgroundColor3 = PANEL,
        BorderSizePixel = 0,
        Text = "RUN DIAGNOSTICS",
        TextColor3 = WHITE,
        TextSize = 9,
        Font = Enum.Font.GothamBold,
        Active = true
    }, page)
    corner(refresh, 7)
    stroke(refresh, GREEN, 0.35)

    local copy = new("TextButton", {
        Name = "CopyDiagnostics",
        Position = UDim2.new(0.52, 2, 0, 316),
        Size = UDim2.new(0.48, -7, 0, 40),
        BackgroundColor3 = PANEL,
        BorderSizePixel = 0,
        Text = "COPY REPORT",
        TextColor3 = WHITE,
        TextSize = 9,
        Font = Enum.Font.GothamBold,
        Active = true
    }, page)
    corner(copy, 7)
    stroke(copy, BLUE, 0.45)

    local logHeader = label(
        page,
        "LogHeader",
        "LIVE LOG",
        UDim2.new(1, -10, 0, 28),
        UDim2.fromOffset(5, 369),
        13,
        BLUE
    )
    logHeader.Font = Enum.Font.GothamBold

    local logBox = new("TextLabel", {
        Name = "LiveLog",
        Position = UDim2.fromOffset(5, 403),
        Size = UDim2.new(1, -10, 0, 320),
        BackgroundColor3 = PANEL,
        BorderSizePixel = 0,
        Text = "",
        TextColor3 = WHITE,
        TextSize = 9,
        Font = Enum.Font.Code,
        TextWrapped = false,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top
    }, page)
    corner(logBox, 7)
    stroke(logBox, BLUE, 0.55)

    local function buildLogs()
        local lines = {}
        local logs = Hub:GetLogs()
        local startIndex = math.max(1, #logs - 49)
        for i = startIndex, #logs do
            local entry = logs[i]
            table.insert(lines, string.format(
                "[%s] %s %s",
                tostring(entry.Timestamp or "??:??:??"),
                tostring(entry.Level or "INFO"),
                tostring(entry.Message or "")
            ))
        end
        logBox.Text = table.concat(lines, "\n")
    end

    local function buildReport()
        if diagnostics and type(diagnostics.GenerateReport) == "function" then
            local ok, report = pcall(function()
                return diagnostics:GenerateReport(Hub)
            end)
            if ok then
                reportBox.Text = tostring(report)
                return true
            end
            reportBox.Text = "Diagnostics failed:\n" .. tostring(report)
            return false
        end
        reportBox.Text = "Developer Diagnostics feature is unavailable."
        return false
    end

    refresh.Activated:Connect(function()
        buildReport()
        buildLogs()
    end)

    copy.Activated:Connect(function()
        if reportBox.Text == "" then
            buildReport()
        end

        local clipboard = nil
        pcall(function()
            if type(setclipboard) == "function" then
                clipboard = setclipboard
            elseif type(toclipboard) == "function" then
                clipboard = toclipboard
            end
        end)

        if clipboard then
            local ok = pcall(clipboard, reportBox.Text)
            if ok then
                Hub:Notify("DEV CENTER", "Diagnostic report copied.", "SUCCESS", 2)
            else
                Hub:Notify("DEV CENTER", "Clipboard access failed.", "WARNING", 2)
            end
        else
            reportBox:CaptureFocus()
            reportBox.SelectionStart = 1
            reportBox.CursorPosition = #reportBox.Text + 1
            Hub:Notify("DEV CENTER", "Clipboard unavailable. Select/copy the report manually.", "INFO", 3)
        end
    end)

    buildReport()
    buildLogs()

    self.DevRefresh = function()
        if page.Parent then
            buildLogs()
        end
    end

    return page
end


function MainUI:_CreateGamePage(Hub)
    local page = self:_CreateSimplePage("GameScroll", "GAME")

    local intro = label(page, "Intro", "Fairwell's hidden game area.", UDim2.new(1,-10,0,40), UDim2.fromOffset(5,43), 10, GREY)
    intro.TextWrapped = true

    local title = new("TextButton", {
        Name = "GameTitleSecret",
        Position = UDim2.fromOffset(5,88),
        Size = UDim2.new(1,-10,0,48),
        BackgroundColor3 = PANEL,
        BorderSizePixel = 0,
        Text = "PLAY FAIRWELL",
        TextColor3 = WHITE,
        TextSize = 13,
        Font = Enum.Font.GothamBold,
        Active = true,
        AutoButtonColor = false
    }, page)
    corner(title,7)
    stroke(title,BLUE,0.55)

    local status = label(page, "Status", "Find the secret.", UDim2.new(1,-10,0,34), UDim2.fromOffset(5,143), 9, GREY)
    status.TextXAlignment = Enum.TextXAlignment.Center

    local secret = new("Frame", {
        Name = "SecretFeatureConsole",
        Position = UDim2.fromOffset(5,185),
        Size = UDim2.new(1,-10,0,360),
        BackgroundColor3 = PANEL,
        BorderSizePixel = 0,
        Visible = false
    }, page)
    corner(secret,8)
    stroke(secret,GREEN,0.25)

    label(secret,"SecretHeader","PRIVATE FEATURE NOTES",UDim2.fromOffset(10,8),UDim2.new(1,-20,0,28),13,GREEN).Font=Enum.Font.GothamBold

    local featureName = new("TextBox", {
        Name="FeatureName", Position=UDim2.fromOffset(10,48), Size=UDim2.new(1,-20,0,40),
        BackgroundColor3=BACKGROUND, BorderSizePixel=0, Text="", PlaceholderText="Feature name",
        TextColor3=WHITE, PlaceholderColor3=GREY, TextSize=10, Font=Enum.Font.Gotham,
        ClearTextOnFocus=false
    }, secret)
    corner(featureName,6); stroke(featureName,BLUE,0.5)

    local prompt = new("TextBox", {
        Name="FeatureRequest", Position=UDim2.fromOffset(10,96), Size=UDim2.new(1,-20,0,145),
        BackgroundColor3=BACKGROUND, BorderSizePixel=0, Text="",
        PlaceholderText="Type what you want Fairwell to add...",
        TextColor3=WHITE, PlaceholderColor3=GREY, TextSize=10, Font=Enum.Font.Gotham,
        TextWrapped=true, TextXAlignment=Enum.TextXAlignment.Left, TextYAlignment=Enum.TextYAlignment.Top,
        ClearTextOnFocus=false, MultiLine=true
    }, secret)
    corner(prompt,6); stroke(prompt,BLUE,0.5)

    local save = new("TextButton", {
        Name="SaveFeature", Position=UDim2.fromOffset(10,253), Size=UDim2.new(1,-20,0,42),
        BackgroundColor3=GREEN, BorderSizePixel=0, Text="SAVE FEATURE IDEA",
        TextColor3=WHITE, TextSize=10, Font=Enum.Font.GothamBold, Active=true
    }, secret)
    corner(save,6)

    local saved = label(secret,"Saved","Ideas are kept locally on this device when file access is available.",UDim2.new(1,-20,0,50),UDim2.fromOffset(10,302),9,GREY)
    saved.TextWrapped=true
    saved.TextYAlignment=Enum.TextYAlignment.Top

    local taps, lastTap, unlocked = 0, 0, false

    title.Activated:Connect(function()
        local now=os.clock()
        if now-lastTap>2.5 then taps=0 end
        lastTap=now
        taps+=1
        if taps>=9 then
            taps=0
            unlocked=true
            secret.Visible=true
            status.Text="..."
            status.TextColor3=GREEN
            title.Text="GAME UNLOCKED"
        end
    end)

    save.Activated:Connect(function()
        if not unlocked then return end
        local name=featureName.Text:gsub("^%s+",""):gsub("%s+$","")
        local request=prompt.Text:gsub("^%s+",""):gsub("%s+$","")
        if name=="" or request=="" then
            saved.Text="Enter a feature name and description first."
            saved.TextColor3=RED
            return
        end

        local record={FeatureName=name,Description=request,Target="DOORS",Created=os.date("!%Y-%m-%dT%H:%M:%SZ")}
        local wrote=false

        if type(writefile)=="function" then
            pcall(function()
                if type(isfolder)=="function" and type(makefolder)=="function" then
                    if not isfolder("FairwellHeaven") then makefolder("FairwellHeaven") end
                    if not isfolder("FairwellHeaven/Dev") then makefolder("FairwellHeaven/Dev") end
                elseif type(makefolder)=="function" then
                    pcall(makefolder,"FairwellHeaven")
                    pcall(makefolder,"FairwellHeaven/Dev")
                end

                local HttpService=game:GetService("HttpService")
                local path="FairwellHeaven/Dev/feature_ideas.json"
                local list={}
                if type(isfile)=="function" and isfile(path) then
                    local ok,decoded=pcall(function() return HttpService:JSONDecode(readfile(path)) end)
                    if ok and type(decoded)=="table" then list=decoded end
                end
                table.insert(list,record)
                writefile(path,HttpService:JSONEncode(list))
                wrote=true
            end)
        end

        saved.Text=wrote and "Saved privately to this device." or "Saved for this session. File saving is unavailable here."
        saved.TextColor3=GREEN
        featureName.Text=""
        prompt.Text=""
    end)

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
        {"GameTab", "GAME", 3},
        {"FairwellChatTab", "CHAT", 4},
        {"VisualTab", "VISUAL", 5},
        {"SettingsTab", "SETTINGS", 6}
    }

    self.Tabs = {}

    for _, data in ipairs(definitions) do
        local button = new("TextButton", {
            Name = data[1],
            Size = UDim2.new(1 / 5, 0, 1, 0),
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
        if data[1] == "GameTab" then
            button.Visible = false
        end
    end

    self.GameTabRevealed = false
end

function MainUI:_RevealGameTab()
    if self.GameTabRevealed or not self.Tabs or not self.Tabs.GameTab then
        return
    end

    self.GameTabRevealed = true
    self.Tabs.GameTab.Visible = true

    for _, button in pairs(self.Tabs) do
        button.Size = UDim2.new(1 / 6, 0, 1, 0)
    end
end

function MainUI:_CreateSettingsPage(Hub)
    local page = self:_CreateSimplePage(
        "SettingsScroll",
        "SETTINGS"
    )

    local unload = new("TextButton", {
        Name = "UnloadFairwell",
        Position = UDim2.fromOffset(5, 52),
        Size = UDim2.new(1, -10, 0, 44),
        BackgroundColor3 = RED,
        BorderSizePixel = 0,
        Text = "UNLOAD FAIRWELL",
        TextColor3 = WHITE,
        TextSize = 12,
        Font = Enum.Font.GothamBold,
        Active = true
    }, page)
    corner(unload, 8)
    stroke(unload, RED, 0.1)

    local unloadHint = label(
        page,
        "UnloadHint",
        "Stops all features and removes the Fairwell UI.",
        UDim2.new(1, -20, 0, 30),
        UDim2.fromOffset(5, 101),
        9,
        GREY
    )
    unloadHint.TextXAlignment = Enum.TextXAlignment.Center

    unload.Activated:Connect(function()
        local runtimeHub = self.Hub or Hub
        if not runtimeHub then return end

        -- Hard-kill the current Fairwell runtime.
        -- Shutdown disconnects every registered feature and destroys Fairwell UI.
        runtimeHub._Killed = true
        if type(runtimeHub.Shutdown) == "function" then
            runtimeHub:Shutdown()
        end
    end)

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

    local base = "https://raw.githubusercontent.com/reepyissomeone/Fairwell-Heaven/main/assets/Fairwell/Companion/"
    local urls = {
        Idle=base.."Idle.png", Ctalking=base.."Ctalking.png", Cthinking=base.."Cthinking.png",
        Yippe=base.."Yippe.png", uhoh=base.."uhoh.png", Tapped=base.."Tapped.png",
        Scared=base.."Scared.png", confused=base.."confused.png", nervous=base.."nervous.png",
        hiding=base.."hiding.png", hurt=base.."hurt.png", relief=base.."relief.png",
        surpised=base.."surpised.png", terrified=base.."terrified.png", ALERT=base.."ALERT.png"
    }
    local files = {
        Idle="FairwellHeaven/assets/Fairwell/Companion/Idle.png", Ctalking="FairwellHeaven/assets/Fairwell/Companion/Ctalking.png",
        Cthinking="FairwellHeaven/assets/Fairwell/Companion/Cthinking.png", Yippe="FairwellHeaven/assets/Fairwell/Companion/Yippe.png",
        uhoh="FairwellHeaven/assets/Fairwell/Companion/uhoh.png", Tapped="FairwellHeaven/assets/Fairwell/Companion/Tapped.png",
        Scared="FairwellHeaven/assets/Fairwell/Companion/Scared.png", confused="FairwellHeaven/assets/Fairwell/Companion/confused.png",
        nervous="FairwellHeaven/assets/Fairwell/Companion/nervous.png", hiding="FairwellHeaven/assets/Fairwell/Companion/hiding.png",
        hurt="FairwellHeaven/assets/Fairwell/Companion/hurt.png", relief="FairwellHeaven/assets/Fairwell/Companion/relief.png",
        surpised="FairwellHeaven/assets/Fairwell/Companion/surpised.png", terrified="FairwellHeaven/assets/Fairwell/Companion/terrified.png",
        ALERT="FairwellHeaven/assets/Fairwell/Companion/ALERT.png"
    }
    local images = {}
    local function assetLoader()
        if type(getcustomasset)=="function" then return getcustomasset end
        if type(getsynasset)=="function" then return getsynasset end
        if type(getcustomassetfromfile)=="function" then return getcustomassetfromfile end
        return nil
    end
    local function ensureFolder(path)
        if type(makefolder)~="function" then return end
        local current=""
        for part in string.gmatch(path,"[^/]+") do
            current=current=="" and part or current.."/"..part
            pcall(makefolder,current)
        end
    end
    local function loadArtwork(state)
        local loader=assetLoader()
        if not loader then return end
        local path,url=files[state],urls[state]
        if not path or not url then return end
        local ok,result=pcall(function()
            ensureFolder("FairwellHeaven/assets/Fairwell")
            if type(isfile)=="function" and isfile(path) then return loader(path) end
            if type(writefile)~="function" then error("writefile unavailable") end
            local downloaded=game:HttpGet(url.."?cache="..tostring(math.floor(os.clock()*1000000)))
            if type(downloaded)~="string" or downloaded=="" then error("download failed") end
            writefile(path,downloaded)
            return loader(path)
        end)
        if ok and type(result)=="string" and result~="" then images[state]=result end
    end
    task.spawn(function()
        for _,state in ipairs({"Idle","Ctalking","Cthinking","Yippe","uhoh","Tapped","Scared","confused","nervous","hiding","hurt","relief","surpised","terrified","ALERT"}) do loadArtwork(state) end
    end)
    local function setArtwork(state)
        state=images[state] and state or "Idle"
        if images[state] then artwork.Image=images[state]
        elseif images.Idle then artwork.Image=images.Idle end
        status.Text="● "..string.upper(state)
    end
    setArtwork("Idle")
    local speechId=0
    local function speak(text,state)
        speechId+=1
        local id=speechId
        setArtwork(state or "Ctalking")
        bubble.Text=tostring(text)
        task.delay(math.max(1.5,math.min(6,#tostring(text)*0.055)),function()
            if id==speechId and stage.Parent then setArtwork("Idle") end
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

    local function generateChatReply(message)
        local brain=self.Hub and self.Hub:GetFeature("Fairwell Companion Brain")
        if brain and type(brain.GenerateThought)=="function" then
            local ok,thought,expression,kind=pcall(function()
                return brain:GenerateThought("Chat",{Message=message})
            end)
            if ok and type(thought)=="string" and thought~="" then
                return thought,expression or "Ctalking",kind or "INFO"
            end
        end
        return "I hear you. Tell me more.","Cthinking","INFO"
    end

    speak("Hey! I'm Fairwell. Talk to me.","Ctalking")
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

        if lower == "im bored" then
            self:_RevealGameTab()
            local text = "Bored? ...Fine. I know a game."
            speak(text, "Yippe")
            addMessage("FAIRWELL", text, BLUE)
            return
        end

        setArtwork("Cthinking")
        task.delay(0.25 + math.random() * 0.45, function()
            if not messages.Parent then return end
            local response, expression = generateChatReply(message)
            speak(response, expression)
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
        Game = "GameTab",
        Visual = "VisualTab",
        Settings = "SettingsTab",
        DevLab = "DevLabTab"
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

    local squish = new("UIScale", {
        Scale = 1
    }, button)

    local squishBusy = false
    local function playSquish()
        if squishBusy or not squish.Parent then
            return
        end

        squishBusy = true
        squish.Scale = 1

        local down = TweenService:Create(
            squish,
            TweenInfo.new(0.07, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {Scale = 0.88}
        )
        local up = TweenService:Create(
            squish,
            TweenInfo.new(0.16, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
            {Scale = 1}
        )

        down:Play()
        down.Completed:Wait()
        if not squish.Parent then
            squishBusy = false
            return
        end
        up:Play()
        up.Completed:Wait()
        squishBusy = false
    end

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

    local base = "https://raw.githubusercontent.com/reepyissomeone/Fairwell-Heaven/main/assets/Fairwell/Companion/"
    local urls = {
        Idle = base .. "Idle.png",
        ALERT = base .. "ALERT.png",
        Ctalking = base .. "Ctalking.png",
        Cthinking = base .. "Cthinking.png",
        Yippe = base .. "Yippe.png",
        uhoh = base .. "uhoh.png",
        Tapped = base .. "Tapped.png",
        Scared = base .. "Scared.png",
        confused = base .. "confused.png",
        nervous = base .. "nervous.png",
        hiding = base .. "hiding.png",
        hurt = base .. "hurt.png",
        relief = base .. "relief.png",
        surpised = base .. "surpised.png",
        terrified = base .. "terrified.png",
    }
    local files = {
        Idle = "FairwellHeaven/assets/Fairwell/Companion/Idle.png",
        ALERT = "FairwellHeaven/assets/Fairwell/Companion/ALERT.png",
        Ctalking = "FairwellHeaven/assets/Fairwell/Companion/Ctalking.png",
        Cthinking = "FairwellHeaven/assets/Fairwell/Companion/Cthinking.png",
        Yippe = "FairwellHeaven/assets/Fairwell/Companion/Yippe.png",
        uhoh = "FairwellHeaven/assets/Fairwell/Companion/uhoh.png",
        Tapped = "FairwellHeaven/assets/Fairwell/Companion/Tapped.png",
        Scared = "FairwellHeaven/assets/Fairwell/Companion/Scared.png",
        confused = "FairwellHeaven/assets/Fairwell/Companion/confused.png",
        nervous = "FairwellHeaven/assets/Fairwell/Companion/nervous.png",
        hiding = "FairwellHeaven/assets/Fairwell/Companion/hiding.png",
        hurt = "FairwellHeaven/assets/Fairwell/Companion/hurt.png",
        relief = "FairwellHeaven/assets/Fairwell/Companion/relief.png",
        surpised = "FairwellHeaven/assets/Fairwell/Companion/surpised.png",
        terrified = "FairwellHeaven/assets/Fairwell/Companion/terrified.png",
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
        for _, state in ipairs({"Idle", "ALERT", "Ctalking", "Cthinking", "Yippe", "uhoh", "Tapped", "Scared", "confused", "nervous", "hiding", "hurt", "relief", "surpised", "terrified"}) do
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

    -- Companion dialogue is persistent and queued.
    -- A message stays visible until the player taps Fairwell.
    local dialogueQueue = {}
    local dialogueShowing = false
    local activeDialogue = nil

    -- Only show one dialogue at a time. New text is ALWAYS queued while
    -- another message is visible; nothing is allowed to overwrite it.

    local function resolveDialogue(noticeTitle, message, kind, forcedState)
        local normalized = string.upper(tostring(kind or "INFO"))
        local state = tostring(forcedState or "")
        local accent = BLUE

        if state == "" then
            state = "Cthinking"
        end

        if forcedState == nil and normalized == "SUCCESS" then
            state = "Yippe"
            accent = GREEN
        elseif forcedState == nil and normalized == "WARNING" then
            state = "ALERT"
            accent = Color3.fromRGB(255, 185, 70)
        elseif forcedState == nil and normalized == "ERROR" then
            state = "uhoh"
            accent = RED
        elseif forcedState == nil and normalized == "INFO" then
            state = "Ctalking"
        end

        return {
            title = string.upper(tostring(noticeTitle or "FAIRWELL")),
            message = tostring(message or ""),
            state = state,
            accent = accent
        }
    end

    local function showNextDialogue()
        if dialogueShowing or #dialogueQueue == 0 then return end
        if not gui.Parent or not self.Hidden or self.CompanionEnabled ~= true then
            return
        end

        local entry = table.remove(dialogueQueue, 1)
        activeDialogue = entry
        dialogueShowing = true

        setState(entry.state)

        -- These are the only writes to the dialogue text. Because this
        -- function refuses to run while dialogueShowing is true, a new
        -- notification can never replace the current message.
        title.Text = entry.title
        title.TextColor3 = entry.accent
        title.Visible = true
        bubble.Text = entry.message
        bubble.Visible = true
    end

    local function showNotification(noticeTitle, message, kind, duration, forcedState)
        if not gui.Parent or not self.Hidden or self.CompanionEnabled ~= true then
            return
        end

        local entry = resolveDialogue(noticeTitle, message, kind, forcedState)

        -- Never replace the visible message. Append every new message to
        -- the queue, including messages fired during the same frame.
        table.insert(dialogueQueue, entry)

        if not dialogueShowing then
            showNextDialogue()
        end
    end

    self.CompanionGui = gui
    self.CompanionHolder = holder
    self.CompanionButton = button
    self.CompanionBubble = bubble
    self.CompanionSetState = setState
    self.CompanionNotify = showNotification
    self.CompanionTap = function()
        if not self.CompanionEnabled then
            return
        end

        -- A tap dismisses the current dialogue first. If more dialogue is
        -- queued, the next message appears immediately. Tapping while no
        -- dialogue is showing keeps the normal companion interaction.
        if dialogueShowing then
            dialogueShowing = false
            activeDialogue = nil
            bubble.Visible = false
            title.Visible = false
            setState("Tapped", 1.5)

            -- Advance ONLY after the player dismissed the previous text.
            showNextDialogue()
            return
        end

        setState("Tapped", 1.5)
        local Brain = self.Hub and self.Hub:GetFeature("Fairwell Companion Brain")
        if Brain and type(Brain.OnTap) == "function" then
            Brain:OnTap()
        end
    end

    -- Tapping Fairwell does NOT open the main menu.
    -- FW is the only control that toggles the menu.
    button.Activated:Connect(function()
        task.spawn(playSquish)
        if self.CompanionTap then
            self.CompanionTap()
        end
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
    gui.Enabled = self.CompanionEnabled == true and self.Hidden == true
    if not self.Hidden then
        gui.Enabled = false
    end

    -- From this point onward, Fairwell owns notifications whenever the
    -- companion is actually visible.
    if self.Hub then
        self.Hub.SuppressTopNotifications =
            self.CompanionEnabled == true and self.Hidden == true
    end

    return true
end

function MainUI:SetVisible(visible)
    visible = visible == true
    self.Hidden = not visible

    if self.Hub then
        self.Hub.SuppressTopNotifications =
            self.CompanionEnabled == true and not visible
    end

    if self.Gui and self.Gui.Parent then
        self.Gui:SetAttribute("FairwellHidden", not visible)
        self.Gui.Enabled = visible
    end

    if self.CompanionGui and self.CompanionGui.Parent then
        self.CompanionGui.Enabled = self.CompanionEnabled == true and not visible
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
    self.CompanionEnabled = true
    self.Hub = Hub
    Hub.SuppressTopNotifications = false

    -- Floating mobile toggle lives in its OWN ScreenGui.
    -- This keeps it visible even when the main window is hidden.
    local oldToggleGui = playerGui:FindFirstChild("FairwellHeaven_Toggle")
    if oldToggleGui then
        oldToggleGui:Destroy()
    end

    local toggleGui = new("ScreenGui", {
        Name = "FairwellHeaven_Toggle",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        DisplayOrder = 1000005,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    }, playerGui)

    local toggle = new("TextButton", {
        Name = "FairwellToggle",
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 10, 0.5, 0),
        Size = UDim2.fromOffset(58, 58),
        BackgroundColor3 = PANEL,
        BorderSizePixel = 0,
        Text = "FW",
        TextColor3 = WHITE,
        TextSize = 15,
        Font = Enum.Font.GothamBold,
        Active = true,
        ZIndex = 100
    }, toggleGui)
    corner(toggle, 14)
    stroke(toggle, BLUE, 0.02)

    local toggleHint = label(
        toggle,
        "Hint",
        "MENU",
        UDim2.new(0, 0, 1, -16),
        UDim2.new(1, 0, 0, 13),
        7,
        GREY
    )
    toggleHint.TextXAlignment = Enum.TextXAlignment.Center

    toggle.Activated:Connect(function()
        self:SetVisible(self.Hidden)
    end)

    self.ToggleGui = toggleGui
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
    pages.Logs = self:_CreateLogsPage(Hub)
    pages.Game = self:_CreateGamePage(Hub)
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
    self.Tabs.GameTab.Activated:Connect(function()
        self:_Switch("Game")
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
            if self.DevRefresh then self.DevRefresh() end
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

    if self.ToggleGui then
        self.ToggleGui:Destroy()
        self.ToggleGui = nil
    elseif self.ToggleButton then
        self.ToggleButton:Destroy()
    end
    self.ToggleButton = nil
    self.DragHandle = nil
    self.Hidden = false
    self.CompanionEnabled = false
    self.GameTabRevealed = false

    if self.Hub then
        self.Hub.SuppressTopNotifications = false
        self.Hub = nil
    end

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
