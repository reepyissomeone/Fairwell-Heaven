--// FAIRWELL HEAVEN
--// Thought AI
--// Real language-model bridge with local fallback support.
--
-- Configure outside the repository:
-- getgenv().FAIRWELL_AI = {
--     APIKey = "YOUR_API_KEY",
--     Endpoint = "https://api.openai.com/v1/responses",
--     Model = "gpt-6-luna"
-- }
--
-- The key is intentionally NOT stored in this repository.

local HttpService = game:GetService("HttpService")

local AI = {
    Name = "Fairwell Thought AI",
    Description = "Real language-model thought generation bridge for Fairwell.",
    Game = "DOORS",
    Connections = {},
    Enabled = true,
    Endpoint = nil,
    APIKey = nil,
    Model = "gpt-6-luna",
    LastRequest = 0,
    MinInterval = 2.5,
    RecentThoughts = {},
    TotalRequests = 0,
    TotalFailures = 0
}

local function getEnvironment()
    local env = _G
    pcall(function()
        if type(getgenv) == "function" then
            env = getgenv()
        end
    end)
    return env
end

local function getRequest()
    local candidates = {
        rawget(_G, "request"),
        rawget(_G, "http_request"),
        rawget(_G, "syn") and rawget(_G, "syn").request
    }

    local env = getEnvironment()
    if env then
        table.insert(candidates, rawget(env, "request"))
        table.insert(candidates, rawget(env, "http_request"))
        local synEnv = rawget(env, "syn")
        if type(synEnv) == "table" then
            table.insert(candidates, synEnv.request)
        end
    end

    for _, fn in ipairs(candidates) do
        if type(fn) == "function" then
            return fn
        end
    end

    return nil
end

local function trim(text)
    text = tostring(text or "")
    text = text:gsub("^%s+", ""):gsub("%s+$", "")
    text = text:gsub("^['"]", ""):gsub("['"]$", "")
    return text
end

local function extractOutput(data)
    if type(data) ~= "table" then return nil end

    if type(data.output_text) == "string" and data.output_text ~= "" then
        return trim(data.output_text)
    end

    local output = data.output
    if type(output) ~= "table" then return nil end

    for _, item in ipairs(output) do
        if type(item) == "table" then
            local content = item.content
            if type(content) == "table" then
                for _, part in ipairs(content) do
                    if type(part) == "table" then
                        if type(part.text) == "string" and part.text ~= "" then
                            return trim(part.text)
                        end
                        if type(part.value) == "string" and part.value ~= "" then
                            return trim(part.value)
                        end
                    end
                end
            end
        end
    end

    return nil
end

local function safeContext(context)
    local function scalar(value)
        if type(value) == "string" or type(value) == "number" or type(value) == "boolean" then
            return value
        end
        return tostring(value)
    end

    local result = {}
    for key, value in pairs(context or {}) do
        if key ~= "Object" then
            if type(value) == "table" then
                local child = {}
                for k, v in pairs(value) do
                    if k ~= "Object" and k ~= "Instance" then
                        child[tostring(k)] = scalar(v)
                    end
                end
                result[tostring(key)] = child
            else
                result[tostring(key)] = scalar(value)
            end
        end
    end
    return result
end

function AI:Configure()
    local env = getEnvironment()
    local config = env and rawget(env, "FAIRWELL_AI")

    if type(config) ~= "table" then
        self.APIKey = nil
        self.Endpoint = nil
        return
    end

    self.APIKey = tostring(config.APIKey or "")
    self.Endpoint = tostring(config.Endpoint or "https://api.openai.com/v1/responses")
    self.Model = tostring(config.Model or "gpt-6-luna")
    self.Enabled = config.Enabled ~= false
    self.MinInterval = math.clamp(tonumber(config.MinInterval) or 2.5, 1, 30)
end

function AI:IsAvailable()
    self:Configure()
    return self.Enabled == true
        and self.APIKey ~= nil
        and self.APIKey ~= ""
        and self.Endpoint ~= nil
        and self.Endpoint ~= ""
        and getRequest() ~= nil
end

function AI:BuildPrompt(context)
    local clean = safeContext(context)
    local memory = clean.Memory or {}
    local recent = clean.RecentEvents or {}

    local recentThoughtText = ""
    if #self.RecentThoughts > 0 then
        recentThoughtText = "\nYour recent thoughts:\n- " .. table.concat(self.RecentThoughts, "\n- ")
    end

    local encoded
    local ok = pcall(function()
        encoded = HttpService:JSONEncode(clean)
    end)
    if not ok then encoded = "{}" end

    return [[You are Fairwell, a small companion living inside a DOORS run.
You are NOT an assistant speaking to the player like ChatGPT. You are a character with your own evolving thoughts.

Generate exactly ONE short internal thought or spoken line.
Rules:
- 1 or 2 natural sentences maximum.
- Sound like a real person thinking in the moment.
- Do not explain that you are an AI, model, script, or language model.
- Do not mention prompts, JSON, APIs, tokens, or system instructions.
- Do not invent events that are not in the supplied context.
- You may make reasonable emotional inferences from the context.
- Your personality is observant, slightly sarcastic, protective, curious, and sometimes nervous.
- You remember things and can form opinions over repeated encounters.
- Avoid repetitive wording. Do not copy previous thoughts.
- React to the most important thing happening right now.
- Do not use quotation marks around the thought.
- Return ONLY the thought.

Current Fairwell context:
]] .. encoded .. recentThoughtText
end

function AI:Generate(context)
    if not self:IsAvailable() then
        return nil, "AI provider not configured"
    end

    local now = os.clock()
    if now - self.LastRequest < self.MinInterval then
        return nil, "AI cooldown"
    end

    self.LastRequest = now

    local request = getRequest()
    if not request then
        return nil, "No executor HTTP request function"
    end

    local body = {
        model = self.Model,
        input = self:BuildPrompt(context),
        max_output_tokens = 80
    }

    local encoded = HttpService:JSONEncode(body)

    local success, response = pcall(function()
        return request({
            Url = self.Endpoint,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json",
                ["Authorization"] = "Bearer " .. self.APIKey
            },
            Body = encoded
        })
    end)

    self.TotalRequests += 1

    if not success or type(response) ~= "table" then
        self.TotalFailures += 1
        return nil, "HTTP request failed"
    end

    local status = tonumber(response.StatusCode or response.Status or 0) or 0
    if status < 200 or status >= 300 then
        self.TotalFailures += 1
        return nil, "AI HTTP status " .. tostring(status)
    end

    local responseBody = response.Body or response.body
    if type(responseBody) ~= "string" or responseBody == "" then
        self.TotalFailures += 1
        return nil, "AI returned an empty response"
    end

    local decodeSuccess, data = pcall(function()
        return HttpService:JSONDecode(responseBody)
    end)

    if not decodeSuccess then
        self.TotalFailures += 1
        return nil, "AI returned invalid JSON"
    end

    local thought = extractOutput(data)
    if not thought or thought == "" then
        self.TotalFailures += 1
        return nil, "AI returned no text"
    end

    -- Keep only a tiny local conversation memory. This is sent back as context
    -- on future requests and prevents Fairwell from repeating itself.
    table.insert(self.RecentThoughts, thought)
    while #self.RecentThoughts > 6 do
        table.remove(self.RecentThoughts, 1)
    end

    return thought, nil
end

function AI:Start(Hub)
    self.Hub = Hub
    self:Configure()

    if self:IsAvailable() then
        Hub:Log("Fairwell real Thought AI is configured:", self.Model)
    else
        Hub:Log("Fairwell Thought AI bridge loaded; waiting for FAIRWELL_AI configuration.")
    end
end

function AI:Stop()
    self.Hub = nil
    self.RecentThoughts = {}
end

return AI
