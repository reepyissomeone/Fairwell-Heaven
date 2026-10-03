--// FAIRWELL HEAVEN
--// DOORS Highlights

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local Highlights = {
	Name = "DOORS Highlights",
	Description = "Highlights useful DOORS objects.",
	Game = "DOORS",
	Objects = {},
	Connections = {}
}

local DEFAULT_COLOR = Color3.fromRGB(27, 147, 227)

local function AddHighlight(self, object)
	if not object or self.Objects[object] then
		return
	end

	local Highlight = Instance.new("Highlight")
	Highlight.Name = "FairwellHeavenHighlight"
	Highlight.Adornee = object
	Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	Highlight.FillColor = DEFAULT_COLOR
	Highlight.FillTransparency = 0.75
	Highlight.OutlineColor = DEFAULT_COLOR
	Highlight.OutlineTransparency = 0
	Highlight.Parent = object

	self.Objects[object] = Highlight
end

local function IsUseful(object)
	local name = string.lower(object.Name)
	return name == "door"
		or name == "key"
		or name == "keycard"
		or string.find(name, "key") ~= nil
end

function Highlights:Scan()
	for _, object in ipairs(Workspace:GetDescendants()) do
		if IsUseful(object) and (object:IsA("Model") or object:IsA("BasePart")) then
			AddHighlight(self, object)
		end
	end
end

function Highlights.Start(self, Hub)
	local Settings = Hub:GetService("Settings")
	if Settings and Settings:GetFeatureEnabled(self.Name, true) == false then
		Hub:Log("DOORS Highlights disabled by settings.")
		return
	end

	self:Scan()

	self.DescendantConnection = Workspace.DescendantAdded:Connect(function(object)
		if IsUseful(object) and (object:IsA("Model") or object:IsA("BasePart")) then
			AddHighlight(self, object)
		end
	end)

	Hub:Log("DOORS Highlights started.")
end

function Highlights.Stop(self)
	if self.DescendantConnection then
		self.DescendantConnection:Disconnect()
		self.DescendantConnection = nil
	end

	for object, highlight in pairs(self.Objects) do
		if highlight then
			highlight:Destroy()
		end
		self.Objects[object] = nil
	end
end

return Highlights
