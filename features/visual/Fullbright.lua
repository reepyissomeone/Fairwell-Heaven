--// FAIRWELL HEAVEN
--// Visual: Fullbright

local Lighting = game:GetService("Lighting")

local Fullbright = {
    Name = "VISUAL Fullbright",
    Description = "Keeps the local lighting bright and readable.",
    Connection = nil,
    Saved = nil
}

function Fullbright.Start(self, Hub)
    local Settings = Hub:GetService("Settings")
    if Settings and Settings:GetFeatureEnabled(self.Name, false) == false then
        return false
    end

    if self.Connection then
        self.Connection:Disconnect()
        self.Connection = nil
    end

    self.Saved = {
        Brightness = Lighting.Brightness,
        ClockTime = Lighting.ClockTime,
        FogEnd = Lighting.FogEnd,
        GlobalShadows = Lighting.GlobalShadows,
        Ambient = Lighting.Ambient,
        OutdoorAmbient = Lighting.OutdoorAmbient
    }

    local function Apply()
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
        Lighting.Ambient = Color3.new(1, 1, 1)
        Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
    end

    Apply()
    self.Connection = Lighting.Changed:Connect(function()
        if self.Connection then
            Apply()
        end
    end)

    Hub:Log("Visual Fullbright started.")
end

function Fullbright.Stop(self)
    if self.Connection then
        self.Connection:Disconnect()
        self.Connection = nil
    end

    if self.Saved then
        for Property, Value in pairs(self.Saved) do
            pcall(function()
                Lighting[Property] = Value
            end)
        end
        self.Saved = nil
    end
end

return Fullbright
