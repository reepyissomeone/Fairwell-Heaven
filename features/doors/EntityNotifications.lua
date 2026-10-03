--// FAIRWELL HEAVEN
--// DOORS Entity Notifications

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local StarterGui = game:GetService("StarterGui")

local EntityNotifications = {
	Name = "DOORS Entity Notifications",
	Description = "Notifies when common DOORS entities appear.",
	Game = "DOORS",
	Seen = {},
	Connection = nil
}

local EntityNames = {
	rush = "Rush",
	ambush = "Ambush",
	seek = "Seek",
	halt = "Halt",
	screech = "Screech",
	eyes = "Eyes",
	figure = "Figure",
	dupe = "Dupe",
	grumble = "Grumble",
	giggle = "Giggle"
}

local function Notify(name)
	pcall(function()
		StarterGui:SetCore("SendNotification", {
			Title = "Fairwell Heaven • DOORS",
			Text = name .. " detected!",
			Duration = 4
		})
	end)
end

local function Detect(self, object)
	local key = string.lower(object.Name)
	local entity = EntityNames[key]
	if not entity then
		return
	end

	if self.Seen[object] then
		return
	end

	self.Seen[object] = true
	Notify(entity)
end

function EntityNotifications.Start(self, Hub)
	local Settings = Hub:GetService("Settings")
	if Settings and Settings:GetFeatureEnabled(self.Name, true) == false then
		Hub:Log("DOORS Entity Notifications disabled by settings.")
		return
	end

	for _, object in ipairs(Workspace:GetDescendants()) do
		Detect(self, object)
	end

	self.Connection = Workspace.DescendantAdded:Connect(function(object)
		Detect(self, object)
	end)

	Hub:Log("DOORS Entity Notifications started.")
end

function EntityNotifications.Stop(self)
	if self.Connection then
		self.Connection:Disconnect()
		self.Connection = nil
	end
	table.clear(self.Seen)
end

return EntityNotifications
