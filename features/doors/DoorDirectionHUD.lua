--// FAIRWELL HEAVEN
--// DOORS Door Direction HUD

local Feature = {
    Name = "DOORS Door Direction",
    Description = "Shows the next door's direction and distance on a compact mobile HUD.",
    Game = "DOORS"
}

local function findDoor(room)
    if not room then return nil end
    local direct = room:FindFirstChild("Door")
    if direct and direct:IsA("BasePart") then return direct end
    if direct and direct:IsA("Model") then
        local part = direct.PrimaryPart or direct:FindFirstChildWhichIsA("BasePart", true)
        if part then return part end
    end
    for _, object in ipairs(room:GetDescendants()) do
        if string.lower(object.Name) == "door" then
            if object:IsA("BasePart") then return object end
            if object:IsA("Model") then
                local part = object.PrimaryPart or object:FindFirstChildWhichIsA("BasePart", true)
                if part then return part end
            end
        end
    end
end

function Feature.Start(self, Hub)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local player = Players.LocalPlayer
    local guiParent = player and player:FindFirstChildOfClass("PlayerGui")
    if not guiParent then return false end

    local gui = Instance.new("ScreenGui")
    gui.Name = "FairwellHeaven_DoorDirection"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 999997
    gui.Parent = guiParent

    local frame = Instance.new("Frame")
    frame.AnchorPoint = Vector2.new(0.5, 1)
    frame.Position = UDim2.new(0.5, 0, 1, -18)
    frame.Size = UDim2.fromOffset(210, 42)
    frame.BackgroundColor3 = Color3.fromRGB(6, 4, 43)
    frame.BackgroundTransparency = 0.12
    frame.BorderSizePixel = 0
    frame.Parent = gui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(27, 147, 227)
    stroke.Transparency = 0.3
    stroke.Parent = frame

    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, -12, 1, 0)
    text.Position = UDim2.fromOffset(6, 0)
    text.BackgroundTransparency = 1
    text.TextColor3 = Color3.fromRGB(255, 255, 255)
    text.TextSize = 11
    text.Font = Enum.Font.GothamBold
    text.TextXAlignment = Enum.TextXAlignment.Center
    text.Text = "DOOR  •  --"
    text.Parent = frame

    local doors = Hub:GetService("Doors")
    self.Connection = RunService.Heartbeat:Connect(function()
        if not gui.Parent or not doors then return end
        local root = doors.Root
        local room = doors.CurrentRoom
        local door = findDoor(room)
        if not root or not door then
            text.Text = "DOOR  •  --"
            return
        end

        local delta = door.Position - root.Position
        local horizontal = Vector3.new(delta.X, 0, delta.Z)
        local distance = horizontal.Magnitude

        if distance < 0.1 then
            text.Text = "DOOR  •  HERE"
            return
        end

        local localDir = root.CFrame:VectorToObjectSpace(horizontal.Unit)
        local direction
        if math.abs(localDir.Z) > math.abs(localDir.X) then
            direction = localDir.Z < 0 and "AHEAD" or "BEHIND"
        else
            direction = localDir.X > 0 and "RIGHT" or "LEFT"
        end

        text.Text = string.format("DOOR  •  %s  •  %d studs", direction, math.floor(distance + 0.5))
    end)

    Hub:Log("DOORS Door Direction started.")
    return true
end

function Feature.Stop(self)
    if self.Connection then
        self.Connection:Disconnect()
        self.Connection = nil
    end
    local Players = game:GetService("Players")
    local player = Players.LocalPlayer
    local gui = player and player:FindFirstChildOfClass("PlayerGui")
    local existing = gui and gui:FindFirstChild("FairwellHeaven_DoorDirection")
    if existing then existing:Destroy() end
end

return Feature
