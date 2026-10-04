--// FAIRWELL HEAVEN
--// Visual: DOORS Entity Markers

local Workspace = game:GetService("Workspace")

local EntityMarkers = {
    Name = "VISUAL DOORS Entity Markers",
    Description = "Marks active DOORS entities with floating labels.",
    Game = "DOORS",
    Objects = {},
    Connection = nil
}

local Names = {
    rush="RUSH", ambush="AMBUSH", seek="SEEK", halt="HALT",
    screech="SCREECH", eyes="EYES", figure="FIGURE", dupe="DUPE",
    grumble="GRUMBLE", giggle="GIGGLE"
}

local function Normalize(Name)
    return string.lower(tostring(Name):gsub("[%s_%-%./]", ""))
end

local function Detect(Object)
    local Name = Normalize(Object.Name)
    if Names[Name] and Object:IsA("Model") then
        return Names[Name]
    end
    for Key, Display in pairs(Names) do
        if Key ~= "figure" and Key ~= "dupe" and string.find(Name, Key, 1, true) and Object:IsA("Model") then
            return Display
        end
    end
end

local function Add(self, Object, Name)
    if self.Objects[Object] then return end
    local Gui = Instance.new("BillboardGui")
    Gui.Name = "FairwellHeavenEntityMarker"
    Gui.Size = UDim2.fromOffset(140, 30)
    Gui.StudsOffset = Vector3.new(0, 4, 0)
    Gui.AlwaysOnTop = true
    Gui.MaxDistance = 150
    Gui.Adornee = Object
    Gui.Parent = Object

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.fromScale(1, 1)
    Label.BackgroundColor3 = Color3.fromRGB(70, 15, 25)
    Label.BackgroundTransparency = 0.12
    Label.BorderSizePixel = 0
    Label.Text = "⚠ " .. Name
    Label.TextColor3 = Color3.fromRGB(255, 90, 105)
    Label.TextSize = 11
    Label.Font = Enum.Font.GothamBlack
    Label.Parent = Gui

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Label

    self.Objects[Object] = Gui
end

function EntityMarkers.Start(self, Hub)
    local Settings = Hub:GetService("Settings")
    if Settings and Settings:GetFeatureEnabled(self.Name, false) == false then return end
    self.Connection = Workspace.DescendantAdded:Connect(function(Object)
        local Name = Detect(Object)
        if Name then Add(self, Object, Name) end
    end)
    Hub:Log("Visual DOORS Entity Markers started.")
end

function EntityMarkers.Stop(self)
    if self.Connection then self.Connection:Disconnect(); self.Connection=nil end
    for Object, Gui in pairs(self.Objects) do if Gui then Gui:Destroy() end self.Objects[Object]=nil end
end

return EntityMarkers
