--// FAIRWELL HEAVEN
--// UI Repair / Mobile UI Compatibility
--// Rebuilds the feature controls after the entire manifest is registered.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local BLUE = Color3.fromRGB(27, 147, 227)
local PANEL = Color3.fromRGB(10, 8, 55)
local BACKGROUND = Color3.fromRGB(6, 4, 43)
local WHITE = Color3.fromRGB(255, 255, 255)
local GREY = Color3.fromRGB(170, 170, 185)

local Infrastructure = {
    ["Main UI"] = true,
    ["Loading Screen"] = true,
    ["UI Repair"] = true,
    ["Mini Notification Test"] = true,
    ["Test Feature"] = true
}

local function IsDoorsFeature(Info)
    return Info
        and Info.Feature
        and Info.Feature.Game == "DOORS"
end

local function SafeDestroyChildren(Container)
    for _, Child in ipairs(Container:GetChildren()) do
        if Child:IsA("GuiButton") or Child:IsA("TextLabel") or Child:IsA("Frame") then
            Child:Destroy()
        end
    end
end

return {
    Name = "UI Repair",
    Description = "Mobile-safe feature browser, tab repair, and UI compatibility layer.",

    Start = function(self, Hub)
        local Player = Players.LocalPlayer
        if not Player then
            return false
        end

        local PlayerGui = Player:WaitForChild("PlayerGui")
        local Gui = PlayerGui:WaitForChild("FairwellHeaven_MainUI", 10)

        if not Gui then
            Hub:Warn("UI Repair: Main UI was not created.")
            return false
        end

        self.Gui = Gui
        Gui.Enabled = true
        Gui.DisplayOrder = 1000002
        Gui.IgnoreGuiInset = true
        Gui.ResetOnSpawn = false

        local Window = Gui:FindFirstChild("Window")
        local Content = Window and Window:FindFirstChild("Content")
        local MainScroll = Content and Content:FindFirstChild("MainScroll")
        local Tabs = Window and Window:FindFirstChild("Tabs")

        if not Window or not Content or not MainScroll or not Tabs then
            Hub:Warn("UI Repair: Main UI structure is incomplete.")
            return false
        end

        --==================================================
        -- MOBILE WINDOW
        --==================================================

        Window.Size = UDim2.fromScale(0.92, 0.78)
        Window.ClipsDescendants = true

        local SizeConstraint = Window:FindFirstChild("FairwellMobileSize")
        if not SizeConstraint then
            SizeConstraint = Instance.new("UISizeConstraint")
            SizeConstraint.Name = "FairwellMobileSize"
            SizeConstraint.MinSize = Vector2.new(300, 360)
            SizeConstraint.MaxSize = Vector2.new(900, 760)
            SizeConstraint.Parent = Window
        end

        --==================================================
        -- FIVE NON-OVERLAPPING TABS
        --==================================================

        local TabLayout = {
            {"MainTab", 0},
            {"DevTab", 1 / 5},
            {"FairwellChatTab", 2 / 5},
            {"VisualTab", 3 / 5},
            {"SettingsTab", 4 / 5}
        }

        for _, Item in ipairs(TabLayout) do
            local Button = Tabs:FindFirstChild(Item[1])
            if Button and Button:IsA("GuiButton") then
                Button.Position = UDim2.new(Item[2], 0, 0, 0)
                Button.Size = UDim2.new(1 / 5, 0, 1, 0)
                Button.Active = true
            end
        end

        --==================================================
        -- MAIN PAGE FEATURE BROWSER
        --==================================================

        local Status = MainScroll:FindFirstChild("Status")
        if Status then
            Status.Position = UDim2.new(0, 5, 0, 330)
        end

        local Section = MainScroll:FindFirstChild("Repair_FeaturesSection")

        if not Section then
            Section = Instance.new("Frame")
            Section.Name = "Repair_FeaturesSection"
            Section.Position = UDim2.new(0, 5, 0, 5)
            Section.Size = UDim2.new(1, -10, 0, 315)
            Section.BackgroundColor3 = PANEL
            Section.BackgroundTransparency = 0.04
            Section.BorderSizePixel = 0
            Section.ZIndex = 3
            Section.Parent = MainScroll

            local Corner = Instance.new("UICorner")
            Corner.CornerRadius = UDim.new(0, 10)
            Corner.Parent = Section

            local Stroke = Instance.new("UIStroke")
            Stroke.Color = BLUE
            Stroke.Thickness = 1
            Stroke.Parent = Section

            local Title = Instance.new("TextLabel")
            Title.Name = "Title"
            Title.Size = UDim2.new(1, -16, 0, 28)
            Title.Position = UDim2.fromOffset(8, 6)
            Title.BackgroundTransparency = 1
            Title.Text = "FEATURES"
            Title.TextColor3 = BLUE
            Title.TextSize = 15
            Title.Font = Enum.Font.GothamBold
            Title.TextXAlignment = Enum.TextXAlignment.Left
            Title.ZIndex = 4
            Title.Parent = Section

            local Hint = Instance.new("TextLabel")
            Hint.Name = "Hint"
            Hint.Size = UDim2.new(1, -16, 0, 22)
            Hint.Position = UDim2.fromOffset(8, 34)
            Hint.BackgroundTransparency = 1
            Hint.Text = "Tap a feature to turn it ON or OFF • Scroll for more"
            Hint.TextColor3 = GREY
            Hint.TextSize = 10
            Hint.Font = Enum.Font.Gotham
            Hint.TextXAlignment = Enum.TextXAlignment.Left
            Hint.ZIndex = 4
            Hint.Parent = Section

            local List = Instance.new("ScrollingFrame")
            List.Name = "FeatureList"
            List.Position = UDim2.fromOffset(6, 62)
            List.Size = UDim2.new(1, -12, 1, -68)
            List.BackgroundColor3 = BACKGROUND
            List.BackgroundTransparency = 0.15
            List.BorderSizePixel = 0
            List.ScrollBarThickness = 6
            List.ScrollBarImageColor3 = BLUE
            List.ScrollingDirection = Enum.ScrollingDirection.Y
            List.ScrollingEnabled = true
            List.Active = true
            List.AutomaticCanvasSize = Enum.AutomaticSize.Y
            List.CanvasSize = UDim2.new(0, 0, 0, 0)
            List.ZIndex = 4
            List.Parent = Section

            local ListCorner = Instance.new("UICorner")
            ListCorner.CornerRadius = UDim.new(0, 7)
            ListCorner.Parent = List

            local Padding = Instance.new("UIPadding")
            Padding.PaddingTop = UDim.new(0, 5)
            Padding.PaddingBottom = UDim.new(0, 5)
            Padding.PaddingLeft = UDim.new(0, 5)
            Padding.PaddingRight = UDim.new(0, 5)
            Padding.Parent = List

            local Layout = Instance.new("UIListLayout")
            Layout.Name = "FeatureLayout"
            Layout.Padding = UDim.new(0, 5)
            Layout.SortOrder = Enum.SortOrder.LayoutOrder
            Layout.Parent = List
        end

        local List = Section:FindFirstChild("FeatureList")
        if not List then
            return false
        end

        local Settings = Hub:GetService("Settings")
        local Buttons = {}
        local LastSignature = ""

        local function FeatureSignature()
            local Parts = {}
            for _, Info in ipairs(Hub:GetFeatures()) do
                if not Infrastructure[Info.Name] then
                    local DoorsOnly = IsDoorsFeature(Info)
                    if not DoorsOnly or Hub:IsDOORS() then
                        table.insert(Parts, Info.Name .. "|" .. (DoorsOnly and "D" or "G"))
                    end
                end
            end
            table.sort(Parts)
            return table.concat(Parts, "||")
        end

        local function BuildFeatures()
            local Signature = FeatureSignature()
            if Signature == LastSignature and next(Buttons) then
                for Name, Button in pairs(Buttons) do
                    if Button and Button.Parent then
                        Button.Text = "  " .. Name .. "    [" .. (Hub:IsEnabled(Name) and "ON" or "OFF") .. "]"
                    end
                end
                return
            end

            LastSignature = Signature
            table.clear(Buttons)
            SafeDestroyChildren(List)

            local Features = Hub:GetFeatures()
            table.sort(Features, function(A, B)
                return A.Name < B.Name
            end)

            local Order = 0
            for _, Info in ipairs(Features) do
                if not Infrastructure[Info.Name] then
                    local DoorsOnly = IsDoorsFeature(Info)
                    local ShowFeature = not DoorsOnly or Hub:IsDOORS()

                    if ShowFeature then
                        Order += 1

                        local Button = Instance.new("TextButton")
                        Button.Name = "FeatureButton_" .. tostring(Order)
                        Button.Size = UDim2.new(1, -2, 0, 44)
                        Button.BackgroundColor3 = Color3.fromRGB(6, 4, 43)
                        Button.BorderSizePixel = 0
                        Button.TextColor3 = WHITE
                        Button.TextSize = 11
                        Button.Font = Enum.Font.GothamBold
                        Button.TextXAlignment = Enum.TextXAlignment.Left
                        Button.TextWrapped = false
                        Button.Active = true
                        Button.AutoButtonColor = true
                        Button.LayoutOrder = Order
                        Button.ZIndex = 5
                        Button.Parent = List

                        local Corner = Instance.new("UICorner")
                        Corner.CornerRadius = UDim.new(0, 7)
                        Corner.Parent = Button

                        local Stroke = Instance.new("UIStroke")
                        Stroke.Color = BLUE
                        Stroke.Thickness = 1
                        Stroke.Transparency = 0.25
                        Stroke.Parent = Button

                        local function Refresh()
                            if Button.Parent then
                                Button.Text =
                                    "  " .. Info.Name
                                    .. "    ["
                                    .. (Hub:IsEnabled(Info.Name) and "ON" or "OFF")
                                    .. "]"
                            end
                        end

                        Refresh()

                        Button.Activated:Connect(function()
                            local Enabled = Hub:IsEnabled(Info.Name)

                            if Settings then
                                Settings:SetFeatureEnabled(
                                    Info.Name,
                                    not Enabled,
                                    true
                                )
                            end

                            if Enabled then
                                Hub:Disable(Info.Name)
                            else
                                Hub:Enable(Info.Name)
                            end

                            Refresh()
                        end)

                        Buttons[Info.Name] = Button
                    end
                end
            end

            if Order == 0 then
                local Empty = Instance.new("TextLabel")
                Empty.Name = "NoFeatures"
                Empty.Size = UDim2.new(1, -10, 0, 70)
                Empty.BackgroundTransparency = 1
                Empty.Text = Hub:IsDOORS()
                    and "No user features were registered."
                    or "DOORS features appear when you are inside DOORS."
                Empty.TextColor3 = GREY
                Empty.TextSize = 12
                Empty.Font = Enum.Font.Gotham
                Empty.TextWrapped = true
                Empty.TextXAlignment = Enum.TextXAlignment.Center
                Empty.TextYAlignment = Enum.TextYAlignment.Center
                Empty.ZIndex = 5
                Empty.Parent = List
            end
        end

        BuildFeatures()

        -- Rebuild if a late feature registration or game-state change occurs.
        self.RefreshConnection = RunService.Heartbeat:Connect(function()
            if not Gui.Parent then
                return
            end
            BuildFeatures()
        end)

        --==================================================
        -- DOORS-ONLY SETTINGS REPAIR
        --==================================================

        local SettingsScroll = Content:FindFirstChild("SettingsScroll")

        local function SetDoorsVisibility()
            if not SettingsScroll then
                return
            end

            for _, Child in ipairs(SettingsScroll:GetChildren()) do
                if Child:IsA("GuiButton") then
                    local Name = Child.Name
                    if Name == "Repair_DOORS Highlights"
                        or Name == "Repair_DOORS Entity Notifications"
                        or Name == "Repair_DOORS Room HUD" then
                        Child.Visible = Hub:IsDOORS()
                    end
                end
            end
        end

        SetDoorsVisibility()

        self.DoorsVisibilityConnection = RunService.Heartbeat:Connect(function()
            if not Gui.Parent then
                return
            end
            SetDoorsVisibility()
        end)

        --==================================================
        -- MINI NOTIFICATION LAYERS
        --==================================================

        local function RepairMiniLayers()
            local MiniBack = PlayerGui:FindFirstChild("FairwellMiniNotificationBack")
            local MiniFront = PlayerGui:FindFirstChild("FairwellMiniNotificationFront")

            if MiniBack then
                MiniBack.DisplayOrder = 999999
            end

            if MiniFront then
                MiniFront.DisplayOrder = 1000001
            end
        end

        RepairMiniLayers()

        self.ChildConnection = PlayerGui.ChildAdded:Connect(function(Child)
            if Child.Name == "FairwellMiniNotificationBack"
                or Child.Name == "FairwellMiniNotificationFront" then
                task.defer(RepairMiniLayers)
            end
        end)

        self.CleanupWatcher = PlayerGui.ChildRemoved:Connect(function(Child)
            if Child == Gui or Child.Name == "FairwellHeaven_MainUI" then
                local Back = PlayerGui:FindFirstChild("FairwellMiniNotificationBack")
                local Front = PlayerGui:FindFirstChild("FairwellMiniNotificationFront")

                if Back then Back:Destroy() end
                if Front then Front:Destroy() end
            end
        end)

        self.GuardConnection = RunService.Heartbeat:Connect(function()
            if Gui.Parent and not Gui.Enabled then
                Gui.Enabled = true
            end
        end)

        Hub:Log("UI Repair initialized. Mobile feature browser ready.", "SUCCESS")
        return true
    end,

    Stop = function(self)
        if self.RefreshConnection then
            self.RefreshConnection:Disconnect()
            self.RefreshConnection = nil
        end

        if self.DoorsVisibilityConnection then
            self.DoorsVisibilityConnection:Disconnect()
            self.DoorsVisibilityConnection = nil
        end

        if self.ChildConnection then
            self.ChildConnection:Disconnect()
            self.ChildConnection = nil
        end

        if self.CleanupWatcher then
            self.CleanupWatcher:Disconnect()
            self.CleanupWatcher = nil
        end

        if self.GuardConnection then
            self.GuardConnection:Disconnect()
            self.GuardConnection = nil
        end
    end
}
