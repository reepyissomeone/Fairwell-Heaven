--// FAIRWELL HEAVEN
--// Standalone mini notification tester

local Players = game:GetService("Players")

return {
    Name = "Mini Notification Test",
    Description = "Standalone button for testing minimized Fairwell notifications.",

    Start = function(self, Hub)
        local Player = Players.LocalPlayer
        if not Player then
            return
        end

        local PlayerGui = Player:WaitForChild("PlayerGui")

        local Old = PlayerGui:FindFirstChild("FairwellMiniNotificationTester")
        if Old then
            Old:Destroy()
        end

        local Gui = Instance.new("ScreenGui")
        Gui.Name = "FairwellMiniNotificationTester"
        Gui.ResetOnSpawn = false
        Gui.IgnoreGuiInset = true
        Gui.DisplayOrder = 999998
        Gui.Parent = PlayerGui

        local Button = Instance.new("TextButton")
        Button.Name = "TestButton"
        Button.AnchorPoint = Vector2.new(1, 1)
        Button.Position = UDim2.new(1, -14, 1, -14)
        Button.Size = UDim2.fromOffset(190, 38)
        Button.BackgroundColor3 = Color3.fromRGB(10, 8, 55)
        Button.BackgroundTransparency = 0.08
        Button.BorderSizePixel = 0
        Button.Text = "TEST MINI NOTIFICATION"
        Button.TextColor3 = Color3.fromRGB(27, 147, 227)
        Button.TextSize = 10
        Button.Font = Enum.Font.GothamBold
        Button.Parent = Gui

        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0, 7)
        Corner.Parent = Button

        local Stroke = Instance.new("UIStroke")
        Stroke.Color = Color3.fromRGB(27, 147, 227)
        Stroke.Thickness = 1.5
        Stroke.Parent = Button

        Button.MouseButton1Click:Connect(function()
            if Hub and Hub.Notify then
                Hub:Notify(
                    "MINI NOTIFICATION TEST",
                    "This is a test of Fairwell's minimized notification.",
                    "INFO",
                    4
                )
            end
        end)

        self.Gui = Gui
    end,

    Stop = function(self, Hub)
        if self.Gui then
            self.Gui:Destroy()
            self.Gui = nil
        end
    end
}
