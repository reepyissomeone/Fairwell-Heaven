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
        warn("[DOORS HUB] Failed to download:", path)
        warn(source)
        return nil
    end

    local success2, module = pcall(function()
        return loadstring(source)()
    end)

    if not success2 then
        warn("[DOORS HUB] Failed to load:", path)
        warn(module)
        return nil
    end

    return module
end

local Hub = LoadModule("core/Hub.lua")

if not Hub then
    error("[DOORS HUB] Core failed to load.")
end

print("[DOORS HUB] " .. Hub.Name .. " v" .. Hub.Version)
print("[DOORS HUB] Successfully loaded.")

return Hub
