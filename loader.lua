--// DOORS FEATURE HUB
--// Main Loader

local BASE_URL =
    "https://raw.githubusercontent.com/reepyissomeone/Fairwell-Heaven/main/"

local function LoadModule(path)
    local url = BASE_URL .. path

    local success, source = pcall(function()
        return game:HttpGet(url)
    end)

    if not success then
        warn("[DOORS HUB] Download failed:", path)
        warn(source)
        return nil
    end

    local success2, result = pcall(function()
        return loadstring(source)()
    end)

    if not success2 then
        warn("[DOORS HUB] Load failed:", path)
        warn(result)
        return nil
    end

    return result
end

-- Load the core
local Hub = LoadModule("core/Hub.lua")

if not Hub then
    error("[DOORS HUB] Core failed to load.")
end

print("[DOORS HUB] " .. Hub.Name .. " v" .. Hub.Version)

-- Load the manifest
local Manifest = LoadModule("core/Manifest.lua")

if not Manifest then
    error("[DOORS HUB] Manifest failed to load.")
end

print("[DOORS HUB] Found " .. #Manifest .. " feature(s).")

-- Load every feature
for _, path in ipairs(Manifest) do
    local Feature = LoadModule(path)

    if Feature then
        local name = Feature.Name or path

        local registered, err = Hub:RegisterFeature(name, Feature)

        if registered then
            print("[Fairwell heaven] Loaded feature:", name)

            -- Start the feature automatically
            Hub:Enable(name)
        else
            warn("[Fairwell heaven] Registration failed:", name, err)
        end
    end
end

print("[Fairwell Heaven] All features loaded.")

-- Fade out the loading screen
local LoadingScreen = Hub:GetFeature("Loading Screen")

if LoadingScreen and LoadingScreen.Finish then
    LoadingScreen:Finish(Hub)
else
    warn("[Fairwell Heaven] Loading Screen feature could not be finished.")
end

return Hub

return Hub
