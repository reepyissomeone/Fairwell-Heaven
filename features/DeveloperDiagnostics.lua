--// FAIRWELL HEAVEN
--// Diagnostics
--// Non-destructive runtime health checks and copyable developer reports.

local Diagnostics = {
    Name = "Developer Diagnostics",
    Description = "Runtime health checks, feature status, and copyable debug reports.",
}

local function safeCall(fn, ...)
    local ok, a, b = pcall(fn, ...)
    return ok, a, b
end

function Diagnostics.Check(self, Hub)
    local report = {
        Version = tostring(Hub.Version or "?"),
        Game = tostring(Hub.Game and Hub.Game.Name or "Unknown"),
        PlaceId = tostring(game.PlaceId),
        FeatureCount = 0,
        EnabledCount = 0,
        FailedStructure = {},
        MissingServices = {},
        LogCount = #(Hub.LogHistory or {}),
    }

    if type(Hub.GetFeatureCount) == "function" then
        local ok, count = safeCall(Hub.GetFeatureCount, Hub)
        if ok then report.FeatureCount = tonumber(count) or 0 end
    end

    for _, info in ipairs(Hub:GetFeatures()) do
        if info.Enabled then
            report.EnabledCount += 1
        end

        local feature = info.Feature
        if type(feature) ~= "table" then
            table.insert(report.FailedStructure, tostring(info.Name) .. " (not a table)")
        elseif feature.Start ~= nil and type(feature.Start) ~= "function" then
            table.insert(report.FailedStructure, tostring(info.Name) .. " (Start is not a function)")
        elseif feature.Stop ~= nil and type(feature.Stop) ~= "function" then
            table.insert(report.FailedStructure, tostring(info.Name) .. " (Stop is not a function)")
        end
    end

    local requiredServices = {"Settings"}
    for _, serviceName in ipairs(requiredServices) do
        if not Hub:GetService(serviceName) then
            table.insert(report.MissingServices, serviceName)
        end
    end

    return report
end

function Diagnostics.GenerateReport(self, Hub)
    local report = self:Check(Hub)
    local lines = {
        "FAIRWELL HEAVEN DIAGNOSTICS",
        "Version: " .. report.Version,
        "Game: " .. report.Game,
        "Place ID: " .. report.PlaceId,
        "Features: " .. tostring(report.FeatureCount),
        "Enabled: " .. tostring(report.EnabledCount),
        "Log entries: " .. tostring(report.LogCount),
        "",
        "FEATURE STRUCTURE:"
    }

    if #report.FailedStructure == 0 then
        table.insert(lines, "OK - all registered features have valid lifecycle structure.")
    else
        for _, item in ipairs(report.FailedStructure) do
            table.insert(lines, "FAIL - " .. item)
        end
    end

    table.insert(lines, "")
    table.insert(lines, "SERVICES:")
    if #report.MissingServices == 0 then
        table.insert(lines, "OK - required services are present.")
    else
        for _, item in ipairs(report.MissingServices) do
            table.insert(lines, "MISSING - " .. item)
        end
    end

    table.insert(lines, "")
    table.insert(lines, "FEATURE STATUS:")
    local features = Hub:GetFeatures()
    table.sort(features, function(a, b)
        return tostring(a.Name) < tostring(b.Name)
    end)

    for _, info in ipairs(features) do
        local state = info.Enabled and "ON" or "OFF"
        table.insert(lines, state .. " | " .. tostring(info.Name))
    end

    table.insert(lines, "")
    table.insert(lines, "RECENT LOGS:")
    local logs = Hub:GetLogs()
    local startIndex = math.max(1, #logs - 19)
    for i = startIndex, #logs do
        local entry = logs[i]
        table.insert(lines, string.format(
            "[%s] %s %s",
            tostring(entry.Timestamp or "??:??:??"),
            tostring(entry.Level or "INFO"),
            tostring(entry.Message or "")
        ))
    end

    return table.concat(lines, "\n")
end

function Diagnostics.Start(self, Hub)
    Hub:Log("Developer Diagnostics ready.")
    return true
end

function Diagnostics.Stop(self)
end

return Diagnostics
