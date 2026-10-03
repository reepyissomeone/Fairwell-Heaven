--// FAIRWELL HEAVEN
--// Main Loader
--// Client-Side

local BASE_URL =
	"https://raw.githubusercontent.com/reepyissomeone/Fairwell-Heaven/main/"

------------------------------------------------------------
-- HELPERS
------------------------------------------------------------

local function RequireFunction(name, value)

	if type(value) ~= "function" then

		error(
			"[Fairwell Heaven] "
			.. name
			.. " is not available."
		)

	end

	return value

end

local HttpGet =
	RequireFunction(
		"game:HttpGet",
		game.HttpGet
	)

local Compile =
	loadstring or load

if type(Compile) ~= "function" then

	error(
		"[Fairwell Heaven] "
		.. "No Lua compiler is available."
	)

end

------------------------------------------------------------
-- LOAD MODULE
------------------------------------------------------------

local function LoadModule(path)

	print(
		"[Fairwell Heaven] Downloading:",
		path
	)

	local success, source =
		pcall(function()

			return HttpGet(
				game,
				BASE_URL .. path
			)

		end)

	if not success then

		warn(
			"[Fairwell Heaven] Download failed:",
			path
		)

		warn(source)

		return nil

	end

	if type(source) ~= "string"
		or source == "" then

		warn(
			"[Fairwell Heaven] Empty module:",
			path
		)

		return nil

	end

	local success2, chunk =
		pcall(function()

			return Compile(source)

		end)

	if not success2
		or type(chunk) ~= "function" then

		warn(
			"[Fairwell Heaven] Compile failed:",
			path
		)

		warn(chunk)

		return nil

	end

	local success3, result =
		pcall(chunk)

	if not success3 then

		warn(
			"[Fairwell Heaven] Execution failed:",
			path
		)

		warn(result)

		return nil

	end

	return result

end

------------------------------------------------------------
-- HUB
------------------------------------------------------------

local Hub =
	LoadModule(
		"core/Hub.lua"
	)

if type(Hub) ~= "table" then

	error(
		"[Fairwell Heaven] "
		.. "Core did not return a Hub."
	)

end

print(
	"[Fairwell Heaven] "
	.. tostring(Hub.Name)
	.. " v"
	.. tostring(Hub.Version)
)

------------------------------------------------------------
-- GAME DETECTION
------------------------------------------------------------

local Games =
	LoadModule(
		"core/Games.lua"
	)

if type(Games) ~= "table"
	or type(Games.Detect) ~= "function" then

	error(
		"[Fairwell Heaven] "
		.. "Game detection failed."
	)

end

local GameInfo =
	Games:Detect()

if type(GameInfo) ~= "table" then

	error(
		"[Fairwell Heaven] "
		.. "Game detector returned invalid data."
	)

end

Hub:SetGame(
	GameInfo.Name or "Unknown",
	GameInfo
)

print(
	"[Fairwell Heaven] Game:",
	GameInfo.Name
)

print(
	"[Fairwell Heaven] Place ID:",
	tostring(game.PlaceId)
)

------------------------------------------------------------
-- MANIFEST
------------------------------------------------------------

local Manifest =
	LoadModule(
		"core/Manifest.lua"
	)

if type(Manifest) ~= "table" then

	error(
		"[Fairwell Heaven] "
		.. "Manifest did not return a table."
	)

end

print(
	"[Fairwell Heaven] Found "
	.. tostring(#Manifest)
	.. " feature(s)."
)

------------------------------------------------------------
-- LOAD FEATURES
------------------------------------------------------------

for _, path in ipairs(Manifest) do

	local Feature =
		LoadModule(path)

	if type(Feature) ~= "table" then

		warn(
			"[Fairwell Heaven] Invalid feature:",
			path
		)

		continue

	end

	local Name =
		Feature.Name or path

	--------------------------------------------------------
	-- REGISTER
	--------------------------------------------------------

	local Registered, ErrorMessage =
		Hub:RegisterFeature(
			Name,
			Feature
		)

	if not Registered then

		warn(
			"[Fairwell Heaven] "
			.. "Registration failed:",
			Name,
			ErrorMessage
		)

		continue

	end

	print(
		"[Fairwell Heaven] Loaded feature:",
		Name
	)

	--------------------------------------------------------
	-- ENABLE
	--------------------------------------------------------

	Hub:Enable(Name)

end

print(
	"[Fairwell Heaven] All features loaded."
)

------------------------------------------------------------
-- FINISH LOADING SCREEN
------------------------------------------------------------

local LoadingScreen =
	Hub:GetFeature(
		"Loading Screen"
	)

if LoadingScreen then

	if type(LoadingScreen.Finish)
		== "function" then

		LoadingScreen:Finish(Hub)

	else

		warn(
			"[Fairwell Heaven] "
			.. "Loading Screen has no Finish function."
		)

	end

else

	warn(
		"[Fairwell Heaven] "
		.. "Loading Screen not found."
	)

end

------------------------------------------------------------
-- STARTUP
------------------------------------------------------------

print(
	"[Fairwell Heaven] Startup complete."
)

return Hub
