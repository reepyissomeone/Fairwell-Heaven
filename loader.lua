--// FAIRWELL HEAVEN
--// Main Loader
--// Client-Side

local BASE_URL =
	"https://raw.githubusercontent.com/reepyissomeone/Fairwell-Heaven/main/"

--==================================================
-- FUNCTION CHECK
--==================================================

local function RequireFunction(name, value)
	if type(value) ~= "function" then
		error("[Fairwell Heaven] " .. name .. " is not available.")
	end

	return value
end

--==================================================
-- HTTP
--==================================================

local HttpGet = RequireFunction(
	"game:HttpGet",
	game.HttpGet
)

--==================================================
-- SCRIPT LOADER
--==================================================

local Compile = loadstring or load

if type(Compile) ~= "function" then
	error("[Fairwell Heaven] No Lua compiler is available.")
end

--==================================================
-- DOWNLOAD MODULE
--==================================================

local function LoadModule(path)

	print("[Fairwell Heaven] Downloading:", path)

	local success, source = pcall(function()
		return HttpGet(game, BASE_URL .. path)
	end)

	if not success then
		warn("[Fairwell Heaven] Download failed:", path)
		warn(source)
		return nil
	end

	if type(source) ~= "string" or source == "" then
		warn("[Fairwell Heaven] Empty module:", path)
		return nil
	end

	local success2, chunk = pcall(function()
		return Compile(source)
	end)

	if not success2 or type(chunk) ~= "function" then
		warn("[Fairwell Heaven] Compile failed:", path)
		warn(chunk)
		return nil
	end

	local success3, result = pcall(chunk)

	if not success3 then
		warn("[Fairwell Heaven] Execution failed:", path)
		warn(result)
		return nil
	end

	return result
end

--==================================================
-- CORE
--==================================================

local Hub = LoadModule("core/Hub.lua")

if type(Hub) ~= "table" then
	error("[Fairwell Heaven] Core did not return a Hub.")
end

print(
	"[Fairwell Heaven] "
	.. tostring(Hub.Name)
	.. " v"
	.. tostring(Hub.Version)
)

--==================================================
-- MANIFEST
--==================================================

local Manifest = LoadModule("core/Manifest.lua")

if type(Manifest) ~= "table" then
	error("[Fairwell Heaven] Manifest did not return a table.")
end

print(
	"[Fairwell Heaven] Found "
	.. tostring(#Manifest)
	.. " feature(s)."
)

--==================================================
-- FEATURES
--==================================================

for _, path in ipairs(Manifest) do

	local Feature = LoadModule(path)

	if type(Feature) ~= "table" then

		warn(
			"[Fairwell Heaven] Invalid feature:",
			path
		)

		continue
	end

	local Name = Feature.Name or path

	if type(Hub.RegisterFeature) ~= "function" then
		error("[Fairwell Heaven] Hub:RegisterFeature is missing.")
	end

	local Registered, ErrorMessage =
		Hub:RegisterFeature(Name, Feature)

	if Registered then

		print(
			"[Fairwell Heaven] Loaded feature:",
			Name
		)

		if type(Hub.Enable) ~= "function" then
			error("[Fairwell Heaven] Hub:Enable is missing.")
		end

		Hub:Enable(Name)

	else

		warn(
			"[Fairwell Heaven] Registration failed:",
			Name,
			ErrorMessage
		)
	end
end

--==================================================
-- ALL FEATURES LOADED
--==================================================

print("[Fairwell Heaven] All features loaded.")

--==================================================
-- LOADING SCREEN
--==================================================

if type(Hub.GetFeature) == "function" then

	local LoadingScreen =
		Hub:GetFeature("Loading Screen")

	if LoadingScreen then

		if type(LoadingScreen.Finish) == "function" then

			LoadingScreen:Finish(Hub)

		else

			warn(
				"[Fairwell Heaven] Loading Screen has no Finish function."
			)
		end

	else

		warn(
			"[Fairwell Heaven] Loading Screen not found."
		)
	end

else

	warn(
		"[Fairwell Heaven] Hub:GetFeature is missing."
	)
end

print("[Fairwell Heaven] Startup complete.")

return Hub