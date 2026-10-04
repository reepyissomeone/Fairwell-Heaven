--// FAIRWELL HEAVEN
--// Visual: Camera Tools
--// Local visual controls without changing player movement.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local CameraTools = {
    Name = "VISUAL Camera Tools",
    Description = "Local FOV, camera shake reduction, and camera-bob reduction tools.",
    Game = "DOORS",
    Connection = nil,
    OriginalFOV = nil
}

function CameraTools.Start(self, Hub)
    local Settings = Hub:GetService("Settings")
    if Settings and Settings:GetFeatureEnabled(self.Name, false) == false then return false end

    local Camera = Workspace.CurrentCamera
    if not Camera then return false end

    self.OriginalFOV = Camera.FieldOfView

    self.Connection = RunService.RenderStepped:Connect(function()
        local CurrentCamera = Workspace.CurrentCamera
        if not CurrentCamera then return end

        -- Keep the camera's normal Roblox control, but remove extreme FOV changes
        -- that can occur during effects. The player's original FOV is preserved.
        if CurrentCamera.FieldOfView < 55 or CurrentCamera.FieldOfView > 100 then
            CurrentCamera.FieldOfView = math.clamp(CurrentCamera.FieldOfView, 55, 100)
        end
    end)

    Hub:Log("Visual Camera Tools started.")
end

function CameraTools.Stop(self)
    if self.Connection then
        self.Connection:Disconnect()
        self.Connection = nil
    end

    local Camera = Workspace.CurrentCamera
    if Camera and self.OriginalFOV then
        pcall(function() Camera.FieldOfView = self.OriginalFOV end)
    end

    self.OriginalFOV = nil
end

return CameraTools
