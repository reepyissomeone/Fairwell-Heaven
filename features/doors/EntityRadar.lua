--// FAIRWELL HEAVEN
--// DOORS Entity Radar
--// Mobile HUD showing nearby detected entities and distance.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local EntityRadar = {
    Name = "DOORS Entity Radar",
    Description = "Shows nearby DOORS entities with live distance on a compact mobile HUD.",
    Game = "DOORS",
    Gui = nil,
    Connection = nil
}

local ALIASES = {
    rush="Rush", rushmoving="Rush", ambush="Ambush", seek="Seek",
    halt="Halt", screech="Screech", eyes="Eyes", figure="Figure",
    dupe="Dupe", grumble="Grumble", giggle="Giggle", sally="Sally"
}

local function norm(v)
    return string.lower(tostring(v or "")):gsub("[%s_%-%./]", "")
end

local function entityName(model)
    local direct = ALIASES[norm(model.Name)]
    if direct then return direct end
    for alias, display in pairs(ALIASES) do
        if #alias >= 5 and string.find(norm(model.Name), alias, 1, true) then
            return display
        end
    end
    return nil
end

local function rootOf(object)
    if object:IsA("BasePart") then return object end
    if object:IsA("Model") then
        return object.PrimaryPart or object:FindFirstChildWhichIsA("BasePart", true)
    end
end

function EntityRadar.Start(self, Hub)
    local Settings = Hub:GetService("Settings")
    if Settings and Settings:GetFeatureEnabled(self.Name, false) == false then return false end

    local player = Players.LocalPlayer
    local guiParent = player:WaitForChild("PlayerGui")

    local old = guiParent:FindFirstChild("FairwellHeaven_EntityRadar")
    if old then old:Destroy() end

    local gui = Instance.new("ScreenGui")
    gui.Name = "FairwellHeaven_EntityRadar"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 999996
    gui.Parent = guiParent

    local frame = Instance.new("Frame")
    frame.AnchorPoint = Vector2.new(1, 0)
    frame.Position = UDim2.new(1, -10, 0, 175)
    frame.Size = UDim2.fromOffset(190, 105)
    frame.BackgroundColor3 = Color3.fromRGB(8, 7, 35)
    frame.BackgroundTransparency = 0.15
    frame.BorderSizePixel = 0
    frame.Parent = gui

    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 9)

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 75, 95)
    stroke.Transparency = 0.2
    stroke.Parent = frame

    local label = Instance.new("TextLabel")
    label.Position = UDim2.fromOffset(9, 7)
    label.Size = UDim2.new(1, -18, 1, -14)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(245,245,250)
    label.TextSize = 11
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Top
    label.TextWrapped = true
    label.Parent = frame

    self.Gui = gui

    local timer = 0
    self.Connection = RunService.Heartbeat:Connect(function(dt)
        timer += dt
        if timer < 0.25 then return end
        timer = 0

        local character = player.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        if not root then return end

        local nearest = {}
        for _, object in ipairs(Workspace:GetDescendants()) do
            if object:IsA("Model") then
                local name = entityName(object)
                if name then
                    local part = rootOf(object)
                    if part then
                        local distance = (root.Position - part.Position).Magnitude
                        if distance <= 250 then
                            table.insert(nearest, {Name=name, Distance=distance})
                        end
                    end
                end
            end
        end

        table.sort(nearest, function(a,b) return a.Distance < b.Distance end)

        local lines = {"ENTITY RADAR"}
        for i = 1, math.min(4, #nearest) do
            local item = nearest[i]
            table.insert(lines, item.Name .. "  [" .. math.floor(item.Distance) .. "m]")
        end

        if #nearest == 0 then
            table.insert(lines, "No nearby entities")
        end

        label.Text = table.concat(lines, "\n")
    end)

    Hub:Log("DOORS Entity Radar started.")
    return true
end

function EntityRadar.Stop(self)
    if self.Connection then self.Connection:Disconnect(); self.Connection=nil end
    if self.Gui then self.Gui:Destroy(); self.Gui=nil end
end

return EntityRadar
