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
    Endpoint = "",
    SessionToken = ""
}

local function getConfig()
    local env = (type(getgenv) == "function" and getgenv()) or _G
    local config = type(env.FAIRWELL_DEV_LAB) == "table" and env.FAIRWELL_DEV_LAB or {}

    return {
        OwnerUserId = tonumber(config.OwnerUserId or DevLab.OwnerUserId or 0) or 0,
        Endpoint = tostring(config.Endpoint or DevLab.Endpoint or ""),
        SessionToken = tostring(config.SessionToken or DevLab.SessionToken or "")
    }
end

function DevLab:IsAuthorized()
    local player = Players.LocalPlayer
    local config = getConfig()

    return player ~= nil
        and config.OwnerUserId > 0
        and tonumber(player.UserId) == config.OwnerUserId
end

function DevLab:Authenticate(password)
    if type(password) ~= "string" or password == "" then
        return false, "Enter your Dev Lab password."
    end

    local config = getConfig()
    if config.Endpoint == "" then
        return false, "Dev bridge endpoint is not configured yet."
    end

    local requestFunction =
        (type(request) == "function" and request)
        or (type(http_request) == "function" and http_request)
        or (syn and type(syn.request) == "function" and syn.request)

    if not requestFunction then
        return false, "HTTP request support is unavailable."
    end

    local okEncode, body = pcall(function()
        return HttpService:JSONEncode({Password = password, UserId = Players.LocalPlayer and Players.LocalPlayer.UserId})
    end)
    if not okEncode then return false, "Could not encode authentication request." end

    local okRequest, response = pcall(function()
        return requestFunction({
            Url = config.Endpoint .. "/auth",
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = body
        })
    end)
    if not okRequest then return false, "Authentication request failed." end

    local statusCode = tonumber(response and (response.StatusCode or response.Status))
    if not statusCode or statusCode < 200 or statusCode >= 300 then
        return false, "Incorrect password or authentication rejected."
    end

    local decoded = HttpService:JSONDecode(response.Body or "{}")
    if type(decoded) ~= "table" or type(decoded.token) ~= "string" or decoded.token == "" then
        return false, "Authentication response was invalid."
    end

    self.SessionToken = decoded.token
    return true, "Dev Lab unlocked."
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
                ["Content-Type"] = "application/json",
                ["Authorization"] = self.SessionToken ~= "" and ("Bearer " .. self.SessionToken) or ""
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
    self.SessionToken = ""
end

return DevLab
