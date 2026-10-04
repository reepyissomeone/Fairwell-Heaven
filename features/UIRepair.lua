--// FAIRWELL HEAVEN UI REPAIR
--// Runtime compatibility patch for MainUI v4.x

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

return {
    Name = "UI Repair",
    Description = "Repairs MainUI visibility, tab layout, settings controls, and mini Fairwell cleanup.",

    Start = function(self, Hub)
        local Player = Players.LocalPlayer
        if not Player then return end

        local PlayerGui = Player:WaitForChild("PlayerGui")
        local Gui = PlayerGui:WaitForChild("FairwellHeaven_MainUI", 8)
        if not Gui then
            Hub:Log("UI Repair: Main UI was not created in time.", "WARN")
            return
        end

        Gui.Enabled = true
        Gui.DisplayOrder = 1000000

        local MiniBack = PlayerGui:FindFirstChild("FairwellMiniNotificationBack")
        local MiniFront = PlayerGui:FindFirstChild("FairwellMiniNotificationFront")
        if MiniBack then MiniBack.DisplayOrder = 999999 end
        if MiniFront then MiniFront.DisplayOrder = 1000001 end

        local Window = Gui:FindFirstChild("Window")
        local Tabs = Window and Window:FindFirstChild("Tabs")
        if Tabs then
            local layout = {
                { "MainTab", 0 },
                { "DevTab", 1/5 },
                { "FairwellChatTab", 2/5 },
                { "VisualTab", 3/5 },
                { "SettingsTab", 4/5 }
            }
            for _, item in ipairs(layout) do
                local button = Tabs:FindFirstChild(item[1])
                if button and button:IsA("GuiButton") then
                    button.Position = UDim2.new(item[2], 0, 0, 0)
                    button.Size = UDim2.new(1/5, 0, 1, 0)
                end
            end
        end

        local SettingsScroll = Gui:FindFirstChild("Window")
            and Gui.Window:FindFirstChild("Content")
            and Gui.Window.Content:FindFirstChild("SettingsScroll")

        local Settings = Hub:GetService("Settings")

        local function addToggle(text, feature, y, default)
            if not SettingsScroll or SettingsScroll:FindFirstChild("Repair_" .. feature) then return end

            local b = Instance.new("TextButton")
            b.Name = "Repair_" .. feature
            b.Position = UDim2.new(0, 5, 0, y)
            b.Size = UDim2.new(1, -10, 0, 38)
            b.BackgroundColor3 = Color3.fromRGB(10, 8, 55)
            b.BorderSizePixel = 0
            b.TextColor3 = Color3.fromRGB(255, 255, 255)
            b.TextSize = 13
            b.Font = Enum.Font.Gotham
            b.TextXAlignment = Enum.TextXAlignment.Left
            b.ZIndex = 2
            b.Parent = SettingsScroll

            local stroke = Instance.new("UIStroke")
            stroke.Color = Color3.fromRGB(27, 147, 227)
            stroke.Thickness = 1
            stroke.Parent = b

            local function refresh()
                local enabled = default
                if Settings then
                    enabled = Settings:GetFeatureEnabled(feature, default)
                end
                b.Text = "  " .. text .. "    [" .. (enabled and "ON" or "OFF") .. "]"
            end

            refresh()
            b.MouseButton1Click:Connect(function()
                local enabled = default
                if Settings then enabled = Settings:GetFeatureEnabled(feature, default) end
                if Settings then Settings:SetFeatureEnabled(feature, not enabled, true) end
                if not enabled then Hub:Enable(feature) else Hub:Disable(feature) end
                refresh()
            end)
        end

        addToggle("DOORS HIGHLIGHTS", "DOORS Highlights", 122, true)
        addToggle("ENTITY NOTIFICATIONS", "DOORS Entity Notifications", 166, true)
        addToggle("ROOM HUD", "DOORS Room HUD", 210, true)

        local function cleanup()
            for _, name in ipairs({"FairwellMiniNotificationBack", "FairwellMiniNotificationFront"}) do
                local item = PlayerGui:FindFirstChild(name)
                if item then item:Destroy() end
            end
        end

        self.ChildConnection = PlayerGui.ChildAdded:Connect(function(child)
            if child.Name == "FairwellMiniNotificationBack" then
                child.DisplayOrder = 999999
            elseif child.Name == "FairwellMiniNotificationFront" then
                child.DisplayOrder = 1000001
            end
        end)

        self.CleanupWatcher = PlayerGui.ChildRemoved:Connect(function(child)
            if child == Gui or child.Name == "FairwellHeaven_MainUI" then
                cleanup()
                if self.CleanupWatcher then
                    self.CleanupWatcher:Disconnect()
                    self.CleanupWatcher = nil
                end
            end
        end)

        self.GuardConnection = RunService.Heartbeat:Connect(function()
            if not Gui.Parent then return end
            if not Gui.Enabled then Gui.Enabled = true end
        end)

        Hub:Log("UI Repair initialized.", "SUCCESS")
    end,

    Stop = function(self)
        if self.DestroyConnection then
            self.DestroyConnection:Disconnect()
            self.DestroyConnection = nil
        end
        if self.ChildConnection then
            self.ChildConnection:Disconnect()
            self.ChildConnection = nil
        end
        if self.GuardConnection then
            self.GuardConnection:Disconnect()
            self.GuardConnection = nil
        end
    end
}
