--// FAIRWELL HEAVEN
--// DOORS Jumpscare Mute
--// Client-side audio suppression for common jumpscare sounds.

local SoundService = game:GetService("SoundService")
local Workspace = game:GetService("Workspace")

local JumpscareMute = {
    Name = "DOORS Jumpscare Mute",
    Description = "Suppresses common client-side jumpscare audio while leaving normal game audio alone.",
    Game = "DOORS",
    Connection = nil,
    DisabledSounds = {}
}

local function looksLikeJumpscare(sound)
    local n = string.lower(tostring(sound.Name or ""))
    return string.find(n, "jumpscare", 1, true)
        or string.find(n, "screech", 1, true)
        or string.find(n, "scare", 1, true)
        or string.find(n, "ambush", 1, true)
end

function JumpscareMute.Apply(self, sound)
    if not sound or not sound:IsA("Sound") or not looksLikeJumpscare(sound) then
        return
    end

    if self.DisabledSounds[sound] == nil then
        self.DisabledSounds[sound] = sound.Volume
    end

    sound.Volume = 0
end

function JumpscareMute.Start(self, Hub)
    self.DisabledSounds = {}

    for _, object in ipairs(Workspace:GetDescendants()) do
        if object:IsA("Sound") then
            self:Apply(object)
        end
    end

    self.Connection = Workspace.DescendantAdded:Connect(function(object)
        if object:IsA("Sound") then
            task.defer(function()
                if self.Hub then self:Apply(object) end
            end)
        end
    end)

    self.Hub = Hub
    Hub:Log("DOORS Jumpscare Mute started.")
    return true
end

function JumpscareMute.Stop(self)
    if self.Connection then self.Connection:Disconnect(); self.Connection=nil end

    for sound, volume in pairs(self.DisabledSounds) do
        if sound and sound.Parent then
            sound.Volume = volume
        end
    end

    self.DisabledSounds = {}
    self.Hub = nil
end

return JumpscareMute
