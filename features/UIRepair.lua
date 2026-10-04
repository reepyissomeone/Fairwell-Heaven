--// FAIRWELL HEAVEN
--// UI Repair - lightweight compatibility guard
--// MainUI is now authoritative; this module must not build a second feature list.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

return {
    Name = "UI Repair",
    Description = "Keeps the mobile UI visible and correctly sized.",

    Start = function(self, Hub)
        local player = Players.LocalPlayer
        if not player then
            return false
        end

        local playerGui = player:WaitForChild("PlayerGui")
        local gui = playerGui:WaitForChild("FairwellHeaven_MainUI", 10)

        if not gui then
            Hub:Warn("UI Repair: Main UI was not created.")
            return false
        end

        self.Gui = gui
        gui.Enabled = true
        gui.DisplayOrder = 1000002
        gui.IgnoreGuiInset = true
        gui.ResetOnSpawn = false

        local window = gui:FindFirstChild("Window")
        if not window then
            Hub:Warn("UI Repair: Window missing.")
            return false
        end

        window.Size = UDim2.fromScale(0.72, 0.72)

        local constraint = window:FindFirstChild("MobileSize")
        if not constraint then
            constraint = Instance.new("UISizeConstraint")
            constraint.Name = "MobileSize"
            constraint.MinSize = Vector2.new(260, 330)
            constraint.MaxSize = Vector2.new(700, 620)
            constraint.Parent = window
        end

        -- Only guard the UI's existence/visibility. Do not rebuild controls
        -- every frame; MainUI owns the feature list.
        self.GuardConnection = RunService.Heartbeat:Connect(function()
            if not self.Gui or not self.Gui.Parent then
                return
            end

            -- MainUI owns visibility. Never reopen a deliberately hidden UI.
            if self.Gui:GetAttribute("FairwellHidden") == true then
                return
            end

            if not self.Gui.Enabled then
                self.Gui.Enabled = true
            end
        end)

        Hub:Log("UI Repair initialized. Main UI owns feature rendering.", "SUCCESS")
        return true
    end,

    Stop = function(self)
        if self.GuardConnection then
            self.GuardConnection:Disconnect()
            self.GuardConnection = nil
        end

        self.Gui = nil
    end
}
