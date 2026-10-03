--// FAIRWELL HEAVEN
--// Core Hub
--// Version 0.2.0

local Hub = {}

--==================================================
-- IDENTITY
--==================================================

Hub.Name = "Fairwell Heaven"
Hub.Version = "0.2.0"
Hub.Prefix = "[Fairwell Heaven]"

--==================================================
-- STORAGE
--==================================================

Hub.Features = {}
Hub.Enabled = {}

--==================================================
-- LOGGING
--==================================================

function Hub:Log(...)
    print(self.Prefix, ...)
end

function Hub:Warn(...)
    warn(self.Prefix, ...)
end

function Hub:Error(...)
    warn(self.Prefix, "ERROR:", ...)
end

--==================================================
-- FEATURE REGISTRATION
--==================================================

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

--==================================================
-- FEATURE ENABLE
--==================================================

function Hub:Enable(name)

    local feature = self.Features[name]

    if not feature then
        self:Warn("Feature not found:", name)
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

--==================================================
-- FEATURE DISABLE
--==================================================

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

--==================================================
-- FEATURE STATUS
--==================================================

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

--==================================================
-- FEATURE COUNT
--==================================================

function Hub:GetFeatureCount()

    local count = 0

    for _ in pairs(self.Features) do
        count += 1
    end

    return count
end

--==================================================
-- STARTUP
--==================================================

Hub:Log(Hub.Name .. " v" .. Hub.Version .. " initialized.")

return Hub
