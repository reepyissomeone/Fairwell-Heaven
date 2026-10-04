--// FAIRWELL HEAVEN
--// Private Developer Lab bridge
--// No Discord, OpenAI, or GitHub secrets belong in this file.

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local DevLab = {
    Name = "Fairwell Dev Lab",
    Description = "Private owner-only feature request workspace.",
    Game = "GLOBAL",

    -- Set this through getgenv() on your own runtime.
    -- Never put API keys, Discord tokens, or webhook secrets here.
    OwnerUserId = 0,
    Endpoint = ""
}

local function getConfig()
    local env = (type(getgenv) == "function" and getgenv()) or _G
    local config = type(env.FAIRWELL_DEV_LAB) == "table" and env.FAIRWELL_DEV_LAB or {}

    return {
        OwnerUserId = tonumber(config.OwnerUserId or DevLab.OwnerUserId or 0) or 0,
        Endpoint = tostring(config.Endpoint or DevLab.Endpoint or "")
    }
end

function DevLab:IsAuthorized()
    local player = Players.LocalPlayer
    local config = getConfig()

    return player ~= nil
        and config.OwnerUserId > 0
        and tonumber(player.UserId) == config.OwnerUserId
end

function DevLab:GetStatus()
    local config = getConfig()

    if not self:IsAuthorized() then
        return false, "Owner authorization is not configured."
    end

    if config.Endpoint == "" then
        return true, "Owner verified. Dev bridge is not connected yet."
    end

    return true, "Owner verified. Dev bridge configured."
end

function DevLab:Submit(requestData)
    if not self:IsAuthorized() then
        return false, "Access denied."
    end

    local config = getConfig()
    if config.Endpoint == "" then
        return false, "Dev bridge endpoint is not configured yet."
    end

    if type(requestData) ~= "table" then
        return false, "Invalid request."
    end

    local requestFunction =
        (type(request) == "function" and request)
        or (type(http_request) == "function" and http_request)
        or (syn and type(syn.request) == "function" and syn.request)

    if not requestFunction then
        return false, "HTTP request support is unavailable."
    end

    requestData.Client = "Fairwell Heaven"
    requestData.Game = requestData.Game or "GLOBAL"
    requestData.Timestamp = os.time()

    local okEncode, body = pcall(function()
        return HttpService:JSONEncode(requestData)
    end)

    if not okEncode then
        return false, "Could not encode request."
    end

    local okRequest, response = pcall(function()
        return requestFunction({
            Url = config.Endpoint,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body = body
        })
    end)

    if not okRequest then
        return false, "Bridge request failed: " .. tostring(response)
    end

    local statusCode = tonumber(response and (response.StatusCode or response.Status))
    if statusCode and (statusCode < 200 or statusCode >= 300) then
        return false, "Bridge returned HTTP " .. tostring(statusCode) .. "."
    end

    return true, "Request sent to the Fairwell development bridge."
end

function DevLab:Start(Hub)
    self.Hub = Hub
    local authorized, status = self:GetStatus()

    if authorized then
        Hub:Log("Private Dev Lab ready:", status)
    else
        Hub:Log("Private Dev Lab locked until owner authorization is configured.", "INFO")
    end

    return true
end

function DevLab:Stop()
    self.Hub = nil
end

return DevLab
