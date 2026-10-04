--// FAIRWELL HEAVEN
--// Core Hub
--// Version 0.4.3

local Hub = {}

Hub.Name = "Fairwell Heaven"
Hub.Version = "0.4.3"
Hub.Prefix = "[Fairwell Heaven]"

Hub.Features = {}
Hub.Enabled = {}
Hub.Services = {}
Hub.LogHistory = {}
Hub.MaxLogHistory = 200

-- Fires whenever Hub:Notify creates a notification.
-- MainUI uses this to let Fairwell speak while the window is minimized.
Hub.NotificationEvent = Instance.new("BindableEvent")

Hub.Game = {
	Name = "Unknown",
	IsDOORS = false,
	PlaceId = game.PlaceId
}

local function AddLog(self, level, ...)
	local Parts = {}
	for _, Value in ipairs({...}) do
		table.insert(Parts, tostring(Value))
	end

	local Message = table.concat(Parts, " ")
	local Entry = {
		Time = os.clock(),
		Timestamp = os.date("%H:%M:%S"),
		Level = level,
		Message = Message
	}

	table.insert(self.LogHistory, Entry)

	while #self.LogHistory > self.MaxLogHistory do
		table.remove(self.LogHistory, 1)
	end

	return Entry
end

function Hub:Log(...)
	local Entry = AddLog(self, "INFO", ...)
	print(self.Prefix, ...)
	return Entry
end

function Hub:Warn(...)
	local Entry = AddLog(self, "WARN", ...)
	warn(self.Prefix, ...)
	return Entry
end

function Hub:Error(...)
	local Entry = AddLog(self, "ERROR", ...)
	warn(self.Prefix, "ERROR:", ...)
	return Entry
end

function Hub:GetLogs()
	local Result = {}
	for Index, Entry in ipairs(self.LogHistory) do
		Result[Index] = Entry
	end
	return Result
end

function Hub:ClearLogs(level)
	if level == nil then
		table.clear(self.LogHistory)
		return
	end

	level = string.upper(tostring(level))

	local Kept = {}
	for _, Entry in ipairs(self.LogHistory) do
		if string.upper(tostring(Entry.Level or "")) ~= level then
			table.insert(Kept, Entry)
		end
	end

	self.LogHistory = Kept
end


------------------------------------------------------------
-- CUSTOM NOTIFICATIONS
------------------------------------------------------------

local function GetNotificationStyle(kind)
	kind = string.upper(tostring(kind or "INFO"))

	local styles = {
		INFO = {
			Color = Color3.fromRGB(27, 147, 227),
			Icon = "i",
			Sound = "rbxassetid://6026984224"
		},
		SUCCESS = {
			Color = Color3.fromRGB(70, 210, 130),
			Icon = "✓",
			Sound = "rbxassetid://6026984224"
		},
		WARNING = {
			Color = Color3.fromRGB(255, 175, 55),
			Icon = "!",
			Sound = "rbxassetid://6026984224"
		},
		ERROR = {
			Color = Color3.fromRGB(255, 75, 90),
			Icon = "×",
			Sound = "rbxassetid://6026984224"
		}
	}

	return styles[kind] or styles.INFO
end

function Hub:Notify(title, message, kind, duration)
	local Players = game:GetService("Players")
	local TweenService = game:GetService("TweenService")
	local SoundService = game:GetService("SoundService")
	local player = Players.LocalPlayer
	if not player then return false end

	local playerGui = player:FindFirstChildOfClass("PlayerGui")
	if not playerGui then return false end

	-- Fairwell is the notification UI while the companion is active.
	-- Fire the companion event, then suppress and remove the normal card.
	if self.SuppressTopNotifications == true then
		if self.NotificationEvent then
			self.NotificationEvent:Fire(title, message, kind, duration)
		end
		local existing = playerGui:FindFirstChild("FairwellHeaven_Notifications")
		if existing then
			existing:Destroy()
		end
		return true
	end

	local gui = playerGui:FindFirstChild("FairwellHeaven_Notifications")
	if not gui then
		gui = Instance.new("ScreenGui")
		gui.Name = "FairwellHeaven_Notifications"
		gui.ResetOnSpawn = false
		gui.IgnoreGuiInset = true
		gui.DisplayOrder = 999999
		gui.Parent = playerGui

		local container = Instance.new("Frame")
		container.Name = "Container"
		container.AnchorPoint = Vector2.new(1, 0)
		container.Position = UDim2.new(1, -16, 0, 16)
		container.Size = UDim2.new(0, 350, 1, -32)
		container.BackgroundTransparency = 1
		container.Parent = gui

		local constraint = Instance.new("UISizeConstraint")
		constraint.MinSize = Vector2.new(270, 0)
		constraint.MaxSize = Vector2.new(430, 0)
		constraint.Parent = container

		local layout = Instance.new("UIListLayout")
		layout.Padding = UDim.new(0, 10)
		layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
		layout.VerticalAlignment = Enum.VerticalAlignment.Top
		layout.SortOrder = Enum.SortOrder.LayoutOrder
		layout.Parent = container
	end

	local styles = {
		INFO = {Color = Color3.fromRGB(70, 175, 255), Icon = "◆"},
		SUCCESS = {Color = Color3.fromRGB(80, 220, 145), Icon = "✓"},
		WARNING = {Color = Color3.fromRGB(255, 185, 70), Icon = "!"},
		ERROR = {Color = Color3.fromRGB(255, 75, 100), Icon = "×"}
	}
	local style = styles[string.upper(tostring(kind or "INFO"))] or styles.INFO
	duration = math.clamp(tonumber(duration) or 4, 1, 15)

	-- Notify listeners before building the visible notification card.
	-- This keeps Fairwell's minimized speech system independent of the card UI.
	if self.NotificationEvent then
		self.NotificationEvent:Fire(title, message, kind, duration)
	end

	-- Also guard against the companion becoming active between the initial
	-- check and card creation.
	local playerGuiNow = player:FindFirstChildOfClass("PlayerGui")
	local companion = playerGuiNow and playerGuiNow:FindFirstChild("FairwellHeaven_Companion")
	if companion and companion.Enabled == true then
		local existing = playerGuiNow:FindFirstChild("FairwellHeaven_Notifications")
		if existing then existing:Destroy() end
		return true
	end

	local card = Instance.new("Frame")
	card.Size = UDim2.new(1, 0, 0, 82)
	card.BackgroundColor3 = Color3.fromRGB(9, 10, 18)
	card.BackgroundTransparency = 0.03
	card.BorderSizePixel = 0
	card.ClipsDescendants = true
	card.LayoutOrder = math.floor(os.clock() * 1000)
	card.Parent = gui.Container

	local scale = Instance.new("UIScale")
	scale.Scale = 0.92
	scale.Parent = card

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 14)
	corner.Parent = card

	local stroke = Instance.new("UIStroke")
	stroke.Color = style.Color
	stroke.Thickness = 1.5
	stroke.Transparency = 0.2
	stroke.Parent = card

	local glow = Instance.new("Frame")
	glow.Position = UDim2.new(0, 0, 0, 0)
	glow.Size = UDim2.new(0, 5, 1, 0)
	glow.BackgroundColor3 = style.Color
	glow.BorderSizePixel = 0
	glow.Parent = card

	local glowCorner = Instance.new("UICorner")
	glowCorner.CornerRadius = UDim.new(0, 14)
	glowCorner.Parent = glow

	local icon = Instance.new("TextLabel")
	icon.Position = UDim2.new(0, 14, 0.5, -21)
	icon.Size = UDim2.new(0, 42, 0, 42)
	icon.BackgroundColor3 = style.Color
	icon.BackgroundTransparency = 0.82
	icon.Text = style.Icon
	icon.TextColor3 = style.Color
	icon.TextSize = 20
	icon.Font = Enum.Font.GothamBlack
	icon.Parent = card

	local iconCorner = Instance.new("UICorner")
	iconCorner.CornerRadius = UDim.new(0, 11)
	iconCorner.Parent = icon

	local iconStroke = Instance.new("UIStroke")
	iconStroke.Color = style.Color
	iconStroke.Transparency = 0.45
	iconStroke.Parent = icon

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Position = UDim2.new(0, 68, 0, 12)
	titleLabel.Size = UDim2.new(1, -105, 0, 19)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = string.upper(tostring(title or "FAIRWELL HEAVEN"))
	titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	titleLabel.TextSize = 12
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.TextTruncate = Enum.TextTruncate.AtEnd
	titleLabel.Parent = card

	local messageLabel = Instance.new("TextLabel")
	messageLabel.Position = UDim2.new(0, 68, 0, 32)
	messageLabel.Size = UDim2.new(1, -82, 0, 31)
	messageLabel.BackgroundTransparency = 1
	messageLabel.Text = tostring(message or "")
	messageLabel.TextColor3 = Color3.fromRGB(190, 195, 210)
	messageLabel.TextSize = 11
	messageLabel.Font = Enum.Font.Gotham
	messageLabel.TextWrapped = true
	messageLabel.TextXAlignment = Enum.TextXAlignment.Left
	messageLabel.TextYAlignment = Enum.TextYAlignment.Top
	messageLabel.Parent = card

	local closeButton = Instance.new("TextButton")
	closeButton.Position = UDim2.new(1, -29, 0, 7)
	closeButton.Size = UDim2.new(0, 22, 0, 22)
	closeButton.BackgroundTransparency = 1
	closeButton.Text = "×"
	closeButton.TextColor3 = Color3.fromRGB(115, 120, 135)
	closeButton.TextSize = 17
	closeButton.Font = Enum.Font.GothamBold
	closeButton.Parent = card

	local bar = Instance.new("Frame")
	bar.AnchorPoint = Vector2.new(0, 1)
	bar.Position = UDim2.new(0, 0, 1, 0)
	bar.Size = UDim2.new(1, 0, 0, 3)
	bar.BackgroundColor3 = style.Color
	bar.BorderSizePixel = 0
	bar.Parent = card

	local sound = Instance.new("Sound")
	sound.Name = "NotificationSound"
	sound.SoundId = "rbxassetid://6026984224"
	sound.Volume = 0.28
	sound.Parent = SoundService
	pcall(function() sound:Play() end)

	local closed = false
	local function close()
		if closed then return end
		closed = true
		local out = TweenService:Create(card, TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
			Position = UDim2.new(1, 30, 0, 0),
			BackgroundTransparency = 1
		})
		local shrink = TweenService:Create(scale, TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {Scale = 0.9})
		out:Play()
		shrink:Play()
		task.delay(0.25, function()
			if card then card:Destroy() end
			if sound then sound:Destroy() end
		end)
	end

	closeButton.MouseButton1Click:Connect(close)

	card.Position = UDim2.new(1, 30, 0, 0)
	TweenService:Create(card, TweenInfo.new(0.38, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		Position = UDim2.new(0, 0, 0, 0)
	}):Play()
	TweenService:Create(scale, TweenInfo.new(0.38, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Scale = 1
	}):Play()

	TweenService:Create(bar, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
		Size = UDim2.new(0, 0, 0, 3)
	}):Play()

	task.delay(duration, close)
	return true
end
function Hub:Prompt(title, message, yesText, noText, duration)
	local Players = game:GetService("Players")
	local TweenService = game:GetService("TweenService")
	local SoundService = game:GetService("SoundService")
	local player = Players.LocalPlayer
	if not player then return false, false end

	local playerGui = player:FindFirstChildOfClass("PlayerGui")
	if not playerGui then return false, false end

	local existing = playerGui:FindFirstChild("FairwellHeaven_Prompt")
	if existing then existing:Destroy() end

	local gui = Instance.new("ScreenGui")
	gui.Name = "FairwellHeaven_Prompt"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.DisplayOrder = 1000000
	gui.Parent = playerGui

	local panel = Instance.new("Frame")
	panel.AnchorPoint = Vector2.new(0.5, 0)
	panel.Position = UDim2.new(0.5, 0, 0, -130)
	panel.Size = UDim2.new(0.82, 0, 0, 126)
	panel.BackgroundColor3 = Color3.fromRGB(8, 7, 35)
	panel.BorderSizePixel = 0
	panel.Parent = gui

	local constraint = Instance.new("UISizeConstraint")
	constraint.MinSize = Vector2.new(260, 126)
	constraint.MaxSize = Vector2.new(440, 126)
	constraint.Parent = panel

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = panel

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(27, 147, 227)
	stroke.Thickness = 2
	stroke.Parent = panel

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Position = UDim2.new(0, 16, 0, 10)
	titleLabel.Size = UDim2.new(1, -32, 0, 22)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = string.upper(tostring(title or "Fairwell Heaven"))
	titleLabel.TextColor3 = Color3.fromRGB(27, 147, 227)
	titleLabel.TextSize = 14
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Parent = panel

	local messageLabel = Instance.new("TextLabel")
	messageLabel.Position = UDim2.new(0, 16, 0, 35)
	messageLabel.Size = UDim2.new(1, -32, 0, 24)
	messageLabel.BackgroundTransparency = 1
	messageLabel.Text = tostring(message or "")
	messageLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	messageLabel.TextSize = 12
	messageLabel.Font = Enum.Font.Gotham
	messageLabel.TextXAlignment = Enum.TextXAlignment.Left
	messageLabel.Parent = panel

	local yes = Instance.new("TextButton")
	yes.Position = UDim2.new(0, 16, 1, -45)
	yes.Size = UDim2.new(0.5, -22, 0, 34)
	yes.BackgroundColor3 = Color3.fromRGB(27, 147, 227)
	yes.BorderSizePixel = 0
	yes.Text = string.upper(tostring(yesText or "YES"))
	yes.TextColor3 = Color3.fromRGB(255, 255, 255)
	yes.TextSize = 11
	yes.Font = Enum.Font.GothamBold
	yes.Parent = panel

	local yesCorner = Instance.new("UICorner")
	yesCorner.CornerRadius = UDim.new(0, 6)
	yesCorner.Parent = yes

	local no = Instance.new("TextButton")
	no.Position = UDim2.new(0.5, 6, 1, -45)
	no.Size = UDim2.new(0.5, -22, 0, 34)
	no.BackgroundColor3 = Color3.fromRGB(35, 33, 65)
	no.BorderSizePixel = 0
	no.Text = string.upper(tostring(noText or "NO"))
	no.TextColor3 = Color3.fromRGB(220, 220, 230)
	no.TextSize = 11
	no.Font = Enum.Font.GothamBold
	no.Parent = panel

	local noCorner = Instance.new("UICorner")
	noCorner.CornerRadius = UDim.new(0, 6)
	noCorner.Parent = no

	local sound = Instance.new("Sound")
	sound.Name = "PromptSound"
	sound.SoundId = "rbxassetid://6026984224"
	sound.Volume = 0.45
	sound.Parent = SoundService
	pcall(function() sound:Play() end)

	local finished, answer = false, false
	local function finish(value)
		if finished then return end
		finished, answer = true, value == true
		pcall(function() sound:Play() end)
		TweenService:Create(panel, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Position = UDim2.new(0.5, 0, 0, -130)
		}):Play()
		task.delay(0.23, function()
			if gui then gui:Destroy() end
			if sound then sound:Destroy() end
		end)
	end

	yes.MouseButton1Click:Connect(function() finish(true) end)
	no.MouseButton1Click:Connect(function() finish(false) end)

	TweenService:Create(panel, TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		Position = UDim2.new(0.5, 0, 0, 18)
	}):Play()

	task.delay(math.clamp(tonumber(duration) or 15, 3, 30), function()
		finish(false)
	end)

	while not finished do task.wait() end
	return true, answer
end


------------------------------------------------------------
-- GAME
------------------------------------------------------------

function Hub:SetGame(name, data)
	self.Game.Name = name

	if type(data) == "table" then
		for key, value in pairs(data) do
			self.Game[key] = value
		end
	end

	self:Log("Game detected:", self.Game.Name)
end

function Hub:IsGame(name)
	return self.Game.Name == name
end

function Hub:IsDOORS()
	return self.Game.IsDOORS == true
end

------------------------------------------------------------
-- SERVICES
------------------------------------------------------------

function Hub:RegisterService(name, service)
	if type(name) ~= "string" then
		return false, "Service name must be a string"
	end
	if type(service) ~= "table" then
		return false, "Service must be a table"
	end
	self.Services[name] = service
	return true
end

function Hub:GetService(name)
	return self.Services[name]
end

------------------------------------------------------------
-- FEATURES
------------------------------------------------------------

function Hub:RegisterFeature(name, feature)
	if type(name) ~= "string" then
		return false, "Feature name must be a string"
	end
	if type(feature) ~= "table" then
		return false, "Feature must be a table"
	end
	if self.Features[name] then
		self:Warn("Replacing existing feature:", name)
	end
	self.Features[name] = feature
	return true
end

function Hub:Enable(name)
	local feature = self.Features[name]

	if not feature then
		self:Warn("Feature not found:", name)
		return false
	end

	if feature.Game == "DOORS" and not self:IsDOORS() then
		self:Log("Skipping DOORS-only feature outside DOORS:", name)
		return false
	end

	if self.Enabled[name] then
		self:Log("Already enabled:", name)
		return true
	end

	if feature.Start then
		local success, started = pcall(function()
			return feature.Start(feature, self)
		end)

		if not success then
			self:Error("Failed to start", name, "-", started)
			return false
		end

		-- A feature may return false to decline startup (for example when
		-- its persistent setting is OFF). Do not mark it enabled in that case.
		if started == false then
			self:Log("Skipped startup for disabled feature:", name)
			return true
		end
	end

	self.Enabled[name] = true
	self:Log("Enabled:", name)
	return true
end

function Hub:Disable(name)
	local feature = self.Features[name]

	if not feature then
		self:Warn("Feature not found:", name)
		return false
	end

	if not self.Enabled[name] then
		return true
	end

	if feature.Stop then
		local success, err = pcall(function()
			feature.Stop(feature, self)
		end)

		if not success then
			self:Error("Failed to stop", name, "-", err)
		end
	end

	self.Enabled[name] = nil
	self:Log("Disabled:", name)
	return true
end

function Hub:Shutdown()
	if self._ShuttingDown then
		return
	end

	self._ShuttingDown = true

	-- Invalidate background loops only when this Hub owns the current runtime.
	pcall(function()
		local Env = _G
		if type(getgenv) == "function" then
			Env = getgenv()
		end
		local CurrentId = tonumber(Env.__FAIRWELL_HEAVEN_RUNTIME_ID)
		if CurrentId and self._RuntimeId and CurrentId == self._RuntimeId then
			Env.__FAIRWELL_HEAVEN_RUNTIME_ID = CurrentId + 1
		end
	end)

	self:Log("Shutting down...")

	local names = {}
	for name in pairs(self.Enabled) do
		table.insert(names, name)
	end

	for _, name in ipairs(names) do
		self:Disable(name)
	end

	table.clear(self.Services)
	table.clear(self.Features)
	table.clear(self.Enabled)

	self:Log("Shutdown complete.")
end

function Hub:IsEnabled(name)
	return self.Enabled[name] == true
end

function Hub:GetFeature(name)
	return self.Features[name]
end

function Hub:GetFeatures()
	local result = {}

	for name, feature in pairs(self.Features) do
		table.insert(result, {
			Name = name,
			Feature = feature,
			Enabled = self:IsEnabled(name)
		})
	end

	return result
end

function Hub:GetFeatureCount()
	local count = 0
	for _ in pairs(self.Features) do
		count += 1
	end
	return count
end

Hub:Log(Hub.Name .. " v" .. Hub.Version .. " initialized.")

return Hub