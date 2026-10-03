--// FAIRWELL HEAVEN
--// Loading Screen
--// Version 1.0

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer

local LoadingScreen = {
    Name = "Loading Screen",
    Description = "Fairwell Heaven startup loading screen."
}

function LoadingScreen.Start(self, Hub)

    local PlayerGui = Player:WaitForChild("PlayerGui")

    -- Prevent duplicates
    local Existing = PlayerGui:FindFirstChild("FairwellHeaven_Loading")
    if Existing then
        Existing:Destroy()
    end

    --==================================================
    -- COLORS
    --==================================================

    local OUTLINE_COLOR = Color3.fromRGB(27, 147, 227) -- #1B93E3
    local BACKGROUND_COLOR = Color3.fromRGB(16, 13, 105) -- #100D69
    local TEXT_COLOR = Color3.fromRGB(255, 255, 255)

    --==================================================
    -- SCREEN GUI
    --==================================================

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "FairwellHeaven_Loading"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.DisplayOrder = 999999
    ScreenGui.Parent = PlayerGui

    --==================================================
    -- MAIN UI
    --==================================================

    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.AnchorPoint = Vector2.new(0.5, 0.5)
    Main.Position = UDim2.fromScale(0.5, 0.5)
    Main.Size = UDim2.fromScale(0.75, 0.55)
    Main.BackgroundColor3 = BACKGROUND_COLOR
    Main.BorderSizePixel = 0
    Main.Parent = ScreenGui

    -- Rounded corners
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 12)
    Corner.Parent = Main

    --==================================================
    -- BLUE OUTLINE
    --==================================================

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = OUTLINE_COLOR
    Stroke.Thickness = 3
    Stroke.Transparency = 0
    Stroke.Parent = Main

    --==================================================
    -- LOADING TEXT
    --==================================================

    local LoadingText = Instance.new("TextLabel")
    LoadingText.Name = "LoadingText"
    LoadingText.AnchorPoint = Vector2.new(0.5, 0.5)
    LoadingText.Position = UDim2.fromScale(0.5, 0.5)
    LoadingText.Size = UDim2.fromScale(0.8, 0.2)
    LoadingText.BackgroundTransparency = 1
    LoadingText.Text = "LOADING"
    LoadingText.TextColor3 = TEXT_COLOR
    LoadingText.TextScaled = true
    LoadingText.Font = Enum.Font.GothamBold
    LoadingText.Parent = Main

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

        while ScreenGui.Parent do

            LoadingText.Text = "LOADING" .. Dots[Index]

            Index += 1

            if Index > #Dots then
                Index = 1
            end

            task.wait(0.45)
        end
    end)

    --==================================================
    -- FADE IN
    --==================================================

    Main.BackgroundTransparency = 1
    Stroke.Transparency = 1
    LoadingText.TextTransparency = 1

    local FadeInfo = TweenInfo.new(
        0.5,
        Enum.EasingStyle.Quad,
        Enum.EasingDirection.Out
    )

    TweenService:Create(
        Main,
        FadeInfo,
        {BackgroundTransparency = 0}
    ):Play()

    TweenService:Create(
        Stroke,
        FadeInfo,
        {Transparency = 0}
    ):Play()

    TweenService:Create(
        LoadingText,
        FadeInfo,
        {TextTransparency = 0}
    ):Play()

    self.ScreenGui = ScreenGui
    self.Main = Main

    Hub:Log("Loading screen created.")

end

function LoadingScreen.Stop(self, Hub)

    if self.ScreenGui then

        local Main = self.ScreenGui:FindFirstChild("Main")
        local Stroke = Main and Main:FindFirstChildOfClass("UIStroke")
        local Text = Main and Main:FindFirstChild("LoadingText")

        local FadeInfo = TweenInfo.new(
            0.4,
            Enum.EasingStyle.Quad,
            Enum.EasingDirection.In
        )

        if Main then
            TweenService:Create(
                Main,
                FadeInfo,
                {BackgroundTransparency = 1}
            ):Play()
        end

        if Stroke then
            TweenService:Create(
                Stroke,
                FadeInfo,
                {Transparency = 1}
            ):Play()
        end

        if Text then
            TweenService:Create(
                Text,
                FadeInfo,
                {TextTransparency = 1}
            ):Play()
        end

        task.wait(0.45)

        self.ScreenGui:Destroy()
        self.ScreenGui = nil
    end

    Hub:Log("Loading screen removed.")

end

return LoadingScreen