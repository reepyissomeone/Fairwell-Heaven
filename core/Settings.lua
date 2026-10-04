--// FAIRWELL HEAVEN
--// Persistent Settings Service
--// Stores user preferences when the runtime provides file APIs.

local HttpService = game:GetService("HttpService")

local Settings = {
	Name = "Settings",
	FileName = "FairwellHeaven_Settings.json",

	Defaults = {
		UpdateInterval = 120,

		Window = {
			Position = {
				XScale = 0.5,
				XOffset = 0,
				YScale = 0.5,
				YOffset = 0
			}
		},

		Features = {}
	},

	Data = nil,
	Persistent = false
}

local function DeepCopy(Value)
	if type(Value) ~= "table" then
		return Value
	end

	local Copy = {}

	for Key, Child in pairs(Value) do
		Copy[Key] = DeepCopy(Child)
	end

	return Copy
end

local function MergeDefaults(Target, Defaults)
	if type(Target) ~= "table" then
		Target = {}
	end

	for Key, DefaultValue in pairs(Defaults) do
		if Target[Key] == nil then
			Target[Key] = DeepCopy(DefaultValue)
		elseif type(DefaultValue) == "table" then
			Target[Key] = MergeDefaults(Target[Key], DefaultValue)
		end
	end

	return Target
end

function Settings:Load()
	self.Data = DeepCopy(self.Defaults)

	if type(isfile) ~= "function"
		or type(readfile) ~= "function"
		or type(writefile) ~= "function" then

		self.Persistent = false
		return false
	end

	local Exists = false

	pcall(function()
		Exists = isfile(self.FileName)
	end)

	if Exists then
		local Success, Raw = pcall(function()
			return readfile(self.FileName)
		end)

		if Success and type(Raw) == "string" and Raw ~= "" then
			local DecodeSuccess, Loaded = pcall(function()
				return HttpService:JSONDecode(Raw)
			end)

			if DecodeSuccess and type(Loaded) == "table" then
				-- Window collapse is runtime-only; never restore or persist it.
				if type(Loaded.Window) == "table" then
					Loaded.Window.Collapsed = nil
				end
				self.Data = MergeDefaults(Loaded, self.Defaults)
			else
				warn("[Fairwell Heaven] Settings file is invalid. Using defaults.")
			end
		end
	end

	self.Persistent = true
	self:Save()

	return true
end

function Settings:Save()
	if not self.Data then
		return false
	end

	if type(writefile) ~= "function" then
		return false
	end

	local Success, ErrorMessage = pcall(function()
		local Raw = HttpService:JSONEncode(self.Data)
		writefile(self.FileName, Raw)
	end)

	if not Success then
		warn("[Fairwell Heaven] Could not save settings:", ErrorMessage)
		return false
	end

	return true
end

function Settings:Get(Key, Default)
	if not self.Data then
		self:Load()
	end

	local Value = self.Data[Key]

	if Value == nil then
		return Default
	end

	return Value
end

function Settings:Set(Key, Value, SaveImmediately)
	if not self.Data then
		self:Load()
	end

	if Key == "Window" and type(Value) == "table" then
		Value = DeepCopy(Value)
		Value.Collapsed = nil
	end

	self.Data[Key] = Value

	if SaveImmediately ~= false then
		self:Save()
	end

	return Value
end

function Settings:GetFeatureEnabled(Name, Default)
	local Features = self:Get("Features", {})

	if Features[Name] == nil then
		return Default
	end

	return Features[Name] == true
end

function Settings:SetFeatureEnabled(Name, Enabled, SaveImmediately)
	local Features = self:Get("Features", {})
	Features[Name] = Enabled == true
	self:Set("Features", Features, SaveImmediately)
end

function Settings:Reset()
	self.Data = DeepCopy(self.Defaults)
	self:Save()
end

function Settings.Start(self)
	self:Load()

	if self.Persistent then
		print("[Fairwell Heaven] Persistent settings enabled.")
	else
		warn("[Fairwell Heaven] Persistent settings unavailable; using session settings.")
	end
end

function Settings.Stop(self)
	self:Save()
end

return Settings
