--// FAIRWELL HEAVEN
--// Loading Screen
--// Version 1.1

local Players = game:GetService("Players")

local LoadingScreen = {
    Name = "Loading Screen",
    Description = "Fairwell Heaven startup loading screen."
}

function LoadingScreen.Start(self, Hub)

    print("[Fairwell Heaven] LoadingScreen.Start()")

    local Player = Players.LocalPlayer

    if not Player then
        warn("[Fairwell Heaven] LocalPlayer not found.")
        return
    end

    local PlayerGui = Player:WaitForChild("PlayerGui")

    --==================================================
    -- REMOVE OLD SCREEN
    --==================================================

    local Old = PlayerGui:FindFirstChild("FairwellHeaven_Loading")

    if Old then
        Old:Destroy()
    end

    --==================================================
    -- COLORS
    --==================================================

    -- Outline: #1B93E3
    local OUTLINE_COLOR = Color3.fromRGB(27, 147, 227)

    -- Inside: #06042B
    local BACKGROUND_COLOR = Color3.fromRGB(6, 4, 43)

    local TEXT_COLOR = Color3.fromRGB(255, 255, 255)

    --==================================================
    -- SCREEN GUI
    --==================================================

    local Gui = Instance.new("ScreenGui")

    Gui.Name = "FairwellHeaven_Loading"
    Gui.ResetOnSpawn = false
    Gui.IgnoreGuiInset = true
    Gui.DisplayOrder = 999999

    Gui.Parent = PlayerGui

    --==================================================
    -- MAIN PANEL
    --==================================================

    local Main = Instance.new("Frame")

    Main.Name = "Main"

    Main.AnchorPoint = Vector2.new(0.5, 0.5)
    Main.Position = UDim2.fromScale(0.5, 0.5)

    Main.Size = UDim2.fromScale(0.75, 0.5)

    Main.BackgroundColor3 = BACKGROUND_COLOR

    Main.BorderSizePixel = 0

    Main.Parent = Gui

    --==================================================
    -- BLUE OUTLINE
    --==================================================

    local Outline = Instance.new("UIStroke")

    Outline.Name = "Outline"

    Outline.Color = OUTLINE_COLOR

    Outline.Thickness = 4

    Outline.Parent = Main

    --==================================================
    -- LOADING TEXT
    --==================================================

    local Text = Instance.new("TextLabel")

    Text.Name = "Loading"

    Text.AnchorPoint = Vector2.new(0.5, 0.5)
    Text.Position = UDim2.fromScale(0.5, 0.5)

    Text.Size = UDim2.fromScale(0.8, 0.2)

    Text.BackgroundTransparency = 1

    Text.Text = "LOADING"

    Text.TextColor3 = TEXT_COLOR

    Text.TextScaled = true

    Text.Font = Enum.Font.GothamBold

    Text.Parent = Main

    --==================================================
    -- LOADING DOT ANIMATION
    --==================================================

    task.spawn(function()

        local Dots = {
            "",
            ".",
            "..",
            "..."
        }

        local Index = 1

        while Gui.Parent do

            Text.Text = "LOADING" .. Dots[Index]

            Index += 1

            if Index > #Dots then
                Index = 1
            end

            task.wait(0.45)
        end

    end)

    --==================================================
    -- STORE REFERENCES
    --==================================================

    self.Gui = Gui
    self.Main = Main

    print("[Fairwell Heaven] Loading UI created successfully.")

end

function LoadingScreen.Stop(self, Hub)

    if not self.Gui then
        return
    end

    self.Gui:Destroy()

    self.Gui = nil
    self.Main = nil

    print("[Fairwell Heaven] Loading UI removed.")

end

return LoadingScreen