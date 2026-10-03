--// FAIRWELL HEAVEN
--// Core Hub
--// Version 0.3.1

local Hub = {}

Hub.Name = "Fairwell Heaven"
Hub.Version = "0.3.1"
Hub.Prefix = "[Fairwell Heaven]"

Hub.Features = {}
Hub.Enabled = {}
Hub.Services = {}
Hub.LogHistory = {}
Hub.MaxLogHistory = 200

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

function Hub:ClearLogs()
	table.clear(self.LogHistory)
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
		local success, err = pcall(function()
			feature.Start(feature, self)
		end)

		if not success then
			self:Error("Failed to start", name, "-", err)
			return false
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