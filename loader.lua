--// FAIRWELL HEAVEN
--// Main Loader
--// Client-Side

local BASE_URL =
	"https://raw.githubusercontent.com/reepyissomeone/Fairwell-Heaven/main/"

--==================================================
-- DOWNLOAD MODULE
--==================================================

local function LoadModule(path)

	local url = BASE_URL .. path

	local success, source = pcall(function()
		return game:HttpGet(url)
	end)

	if not success then
		warn("[Fairwell Heaven] Download failed:", path)
		warn(source)
		return nil
	end

	if type(source) ~= "string" or source == "" then
		warn("[Fairwell Heaven] Empty response:", path)
		return nil
	end

	local success2, result = pcall(function()

		local chunk = loadstring(source)

		if not chunk then
			error("loadstring failed")
		end

		return chunk()

	end)

	if not success2 then
		warn("[Fairwell Heaven] Load failed:", path)
		warn(result)
		return nil
	end

	return result

end

--==================================================
-- LOAD CORE
--==================================================

local Hub = LoadModule("core/Hub.lua")

if not Hub then
	error("[Fairwell Heaven] Core failed to load.")
end

print(
	"[Fairwell Heaven] "
	.. tostring(Hub.Name)
	.. " v"
	.. tostring(Hub.Version)
)

--==================================================
-- LOAD MANIFEST
--==================================================

local Manifest = LoadModule("core/Manifest.lua")

if not Manifest then
	error("[Fairwell Heaven] Manifest failed to load.")
end

print(
	"[Fairwell Heaven] Found "
	.. tostring(#Manifest)
	.. " feature(s)."
)

--==================================================
-- LOAD FEATURES
--==================================================

for _, path in ipairs(Manifest) do

	local Feature = LoadModule(path)

	if Feature then

		local Name = Feature.Name or path

		local Registered, ErrorMessage =
			Hub:RegisterFeature(Name, Feature)

		if Registered then

			print(
				"[Fairwell Heaven] Loaded feature:",
				Name
			)

			-- Start feature
			Hub:Enable(Name)

		else

			warn(
				"[Fairwell Heaven] Registration failed:",
				Name,
				ErrorMessage
			)

		end

	else

		warn(
			"[Fairwell Heaven] Could not load:",
			path
		)

	end

end

--==================================================
-- ALL FEATURES LOADED
--==================================================

print("[Fairwell Heaven] All features loaded.")

--==================================================
-- FINISH LOADING SCREEN
--==================================================

local LoadingScreen =
	Hub:GetFeature("Loading Screen")

if LoadingScreen then

	if LoadingScreen.Finish then

		LoadingScreen:Finish(Hub)

	else

		warn(
			"[Fairwell Heaven] Loading Screen has no Finish function."
		)

	end

else

	warn(
		"[Fairwell Heaven] Loading Screen feature not found."
	)

end

--==================================================
-- DONE
--==================================================

print("[Fairwell Heaven] Startup complete.")

return Hub