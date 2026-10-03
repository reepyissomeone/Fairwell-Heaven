--// DOORS FEATURE HUB
--// Core Hub

local Hub = {}

Hub.Name = "DOORS Feature Hub"
Hub.Version = "0.1.0"

Hub.Features = {}
Hub.Enabled = {}

function Hub:RegisterFeature(name, feature)
    if type(name) ~= "string" then
        return false, "Feature name must be a string"
    end

    if type(feature) ~= "table" then
        return false, "Feature must be a table"
    end

    Hub.Features[name] = feature

    return true
end

function Hub:Enable(name)
    local feature = Hub.Features[name]

    if not feature then
        warn("[DOORS HUB] Feature not found:", name)
        return false
    end

    if Hub.Enabled[name] then
        return true
    end

    if feature.Start then
        local success, err = pcall(feature.Start, feature, Hub)

        if not success then
            warn("[DOORS HUB] Failed to start:", name, err)
            return false
        end
    end

    Hub.Enabled[name] = true

    print("[DOORS HUB] Enabled:", name)

    return true
end

function Hub:Disable(name)
    local feature = Hub.Features[name]

    if not feature then
        return false
    end

    if not Hub.Enabled[name] then
        return true
    end

    if feature.Stop then
        local success, err = pcall(feature.Stop, feature, Hub)

        if not success then
            warn("[DOORS HUB] Failed to stop:", name, err)
        end
    end

    Hub.Enabled[name] = nil

    print("[DOORS HUB] Disabled:", name)

    return true
end

function Hub:IsEnabled(name)
    return Hub.Enabled[name] == true
end

function Hub:GetFeature(name)
    return Hub.Features[name]
end

return Hub
