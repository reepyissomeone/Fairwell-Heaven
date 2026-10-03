--// FAIRWELL HEAVEN
--// Main Loader
--// Client-Side

local BASE_URL =
	"https://raw.githubusercontent.com/reepyissomeone/Fairwell-Heaven/main/"

------------------------------------------------------------
-- HELPERS
------------------------------------------------------------

local function RequireFunction(name, value)

	if type(value) ~= "function" then

		error(
			"[Fairwell Heaven] "
			.. name
			.. " is not available."
		)

	end

	return value

end

local HttpGet =
	RequireFunction(
		"game:HttpGet",
		game.HttpGet
	)

local Compile =
	loadstring or load

if type(Compile) ~= "function" then

	error(
		"[Fairwell Heaven] "
		.. "No Lua compiler is available."
	)

end

------------------------------------------------------------
-- LOAD MODULE
------------------------------------------------------------

local function LoadModule(path)

	print(
		"[Fairwell Heaven] Downloading:",
		path
	)

	local success, source =
		pcall(function()

			return HttpGet(
				game,
				BASE_URL .. path
			)

		end)

	if not success then

		warn(
			"[Fairwell Heaven] Download failed:",
			path
		)

		warn(source)

		return nil

	end

	if type(source) ~= "string"
		or source == "" then

		warn(
			"[Fairwell Heaven] Empty module:",
			path
		)

		return nil

	end

	local success2, chunk =
		pcall(function()

			return Compile(source)

		end)

	if not success2
		or type(chunk) ~= "function" then

		warn(
			"[Fairwell Heaven] Compile failed:",
			path
		)

		warn(chunk)

		return nil

	end

	local success3, result =
		pcall(chunk)

	if not success3 then

		warn(
			"[Fairwell Heaven] Execution failed:",
			path
		)

		warn(result)

		return nil

	end

	return result

end

------------------------------------------------------------
-- LIVE UPDATE RUNTIME
------------------------------------------------------------

local GlobalEnv = _G

pcall(function()
	if type(getgenv) == "function" then
		GlobalEnv = getgenv()
	end
end)

local PreviousRuntime =
	GlobalEnv.__FAIRWELL_HEAVEN_RUNTIME_ID

local RuntimeId =
	(tonumber(PreviousRuntime) or 0) + 1

GlobalEnv.__FAIRWELL_HEAVEN_RUNTIME_ID =
	RuntimeId

local ExistingHub =
	GlobalEnv.__FAIRWELL_HEAVEN_HUB

if type(ExistingHub) == "table" then

	pcall(function()

		if type(ExistingHub.Shutdown) == "function" then
			ExistingHub:Shutdown()

		elseif type(ExistingHub.GetFeatures) == "function"
			and type(ExistingHub.Disable) == "function" then

			for _, info in ipairs(ExistingHub:GetFeatures()) do
				if info.Enabled then
					ExistingHub:Disable(info.Name)
				end
			end

		end

	end)

end

------------------------------------------------------------
-- UPDATE SETTINGS
------------------------------------------------------------

local DEFAULT_UPDATE_INTERVAL = 120

local GITHUB_BRANCH_API =
	"https://api.github.com/repos/reepyissomeone/Fairwell-Heaven/branches/main"

local function GetRemoteCommit()

	local HttpService =
		game:GetService("HttpService")

	local CacheBust =
		"?fairwell=" .. tostring(math.floor(os.clock() * 1000))

	local Success, Body =
		pcall(function()

			return HttpGet(
				game,
				GITHUB_BRANCH_API .. CacheBust
			)

		end)

	if not Success then
		return nil, "GitHub check failed: " .. tostring(Body)
	end

	local DecodeSuccess, Data =
		pcall(function()
			return HttpService:JSONDecode(Body)
		end)

	if not DecodeSuccess or type(Data) ~= "table" then
		return nil, "GitHub returned invalid JSON."
	end

	if type(Data.commit) ~= "table"
		or type(Data.commit.sha) ~= "string" then
		return nil, "GitHub response has no commit SHA."
	end

	return Data.commit.sha

end

local function StartAutoUpdater(Hub)

	local function GetUpdateInterval()
		local Settings = Hub:GetService("Settings")

		if Settings then
			local SavedInterval =
				tonumber(
					Settings:Get(
						"UpdateInterval",
						DEFAULT_UPDATE_INTERVAL
					)
				)

			if SavedInterval then
				return math.clamp(
					SavedInterval,
					30,
					3600
				)
			end
		end

		return DEFAULT_UPDATE_INTERVAL
	end

	local UPDATE_INTERVAL = GetUpdateInterval()

	if type(task) ~= "table"
		or type(task.spawn) ~= "function"
		or type(task.wait) ~= "function" then

		Hub:Warn(
			"Auto-updater disabled: task library unavailable."
		)

		return

	end

	local InitialCommit, ErrorMessage =
		GetRemoteCommit()

	if not InitialCommit then

		Hub:Warn(
			"Auto-updater could not get initial commit:",
			ErrorMessage
		)

		return

	end

	Hub:Log(
		"Auto-updater active. Commit:",
		InitialCommit:sub(1, 7),
		"| Check every",
		UPDATE_INTERVAL,
		"seconds."
	)

	task.spawn(function()

		while GlobalEnv.__FAIRWELL_HEAVEN_RUNTIME_ID
			== RuntimeId do

			UPDATE_INTERVAL = GetUpdateInterval()
			task.wait(UPDATE_INTERVAL)

			if GlobalEnv.__FAIRWELL_HEAVEN_RUNTIME_ID
				~= RuntimeId then
				break
			end

			local RemoteCommit, CheckError =
				GetRemoteCommit()

			if not RemoteCommit then

				Hub:Warn(
					"Update check failed:",
					CheckError
				)

				continue

			end

			if RemoteCommit == InitialCommit then
				continue
			end

			Hub:Log(
				"GitHub update detected:",
				InitialCommit:sub(1, 7),
				"->",
				RemoteCommit:sub(1, 7)
			)

			local CacheBust =
				"?fairwell=" .. tostring(
					math.floor(os.clock() * 1000)
				)

			local DownloadSuccess, Source =
				pcall(function()

					return HttpGet(
						game,
						BASE_URL
						.. "loader.lua"
						.. CacheBust
					)

				end)

			if not DownloadSuccess
				or type(Source) ~= "string"
				or Source == "" then

				Hub:Warn(
					"Update download failed. Keeping current version."
				)

				continue

			end

			local CompileSuccess, NewLoader =
				pcall(function()
					return Compile(Source)
				end)

			if not CompileSuccess
				or type(NewLoader) ~= "function" then

				Hub:Warn(
					"New loader failed to compile. Keeping current version."
				)

				continue

			end

			Hub:Log(
				"Installing GitHub update..."
			)

			GlobalEnv.__FAIRWELL_HEAVEN_RUNTIME_ID =
				RuntimeId + 1

			Hub:Shutdown()

			GlobalEnv.__FAIRWELL_HEAVEN_HUB = nil

			local ExecuteSuccess, ExecuteError =
				pcall(NewLoader)

			if not ExecuteSuccess then

				warn(
					"[Fairwell Heaven] "
					.. "Updated loader failed:",
					ExecuteError
				)

			end

			break

		end

	end)

end

------------------------------------------------------------
-- HUB
------------------------------------------------------------

local Hub =
	LoadModule(
		"core/Hub.lua"
	)

if type(Hub) ~= "table" then

	error(
		"[Fairwell Heaven] "
		.. "Core did not return a Hub."
	)

end

print(
	"[Fairwell Heaven] "
	.. tostring(Hub.Name)
	.. " v"
	.. tostring(Hub.Version)
)

GlobalEnv.__FAIRWELL_HEAVEN_HUB = Hub

------------------------------------------------------------
-- PERSISTENT SETTINGS
------------------------------------------------------------

local Settings =
	LoadModule(
		"core/Settings.lua"
	)

if type(Settings) ~= "table" then

	warn(
		"[Fairwell Heaven] "
		.. "Settings service failed to load."
	)

else

	Hub:RegisterService(
		"Settings",
		Settings
	)

	if type(Settings.Start) == "function" then
		local SettingsSuccess, SettingsError =
			pcall(function()
				Settings:Start(Hub)
			end)

		if not SettingsSuccess then
			Hub:Warn(
				"Settings startup failed:",
				SettingsError
			)
		end
	end

end

------------------------------------------------------------
-- GAME DETECTION
------------------------------------------------------------

local Games =
	LoadModule(
		"core/Games.lua"
	)

if type(Games) ~= "table"
	or type(Games.Detect) ~= "function" then

	error(
		"[Fairwell Heaven] "
		.. "Game detection failed."
	)

end

local GameInfo =
	Games:Detect()

if type(GameInfo) ~= "table" then

	error(
		"[Fairwell Heaven] "
		.. "Game detector returned invalid data."
	)

end

Hub:SetGame(
	GameInfo.Name or "Unknown",
	GameInfo
)

print(
	"[Fairwell Heaven] Game:",
	GameInfo.Name
)

print(
	"[Fairwell Heaven] Place ID:",
	tostring(game.PlaceId)
)

------------------------------------------------------------
-- MANIFEST
------------------------------------------------------------

local Manifest =
	LoadModule(
		"core/Manifest.lua"
	)

if type(Manifest) ~= "table" then

	error(
		"[Fairwell Heaven] "
		.. "Manifest did not return a table."
	)

end

print(
	"[Fairwell Heaven] Found "
	.. tostring(#Manifest)
	.. " feature(s)."
)

------------------------------------------------------------
-- LOAD FEATURES
------------------------------------------------------------

for _, path in ipairs(Manifest) do

	local Feature =
		LoadModule(path)

	if type(Feature) ~= "table" then

		warn(
			"[Fairwell Heaven] Invalid feature:",
			path
		)

		continue

	end

	local Name =
		Feature.Name or path

	--------------------------------------------------------
	-- REGISTER
	--------------------------------------------------------

	local Registered, ErrorMessage =
		Hub:RegisterFeature(
			Name,
			Feature
		)

	if not Registered then

		warn(
			"[Fairwell Heaven] "
			.. "Registration failed:",
			Name,
			ErrorMessage
		)

		continue

	end

	print(
		"[Fairwell Heaven] Loaded feature:",
		Name
	)

	--------------------------------------------------------
	-- ENABLE
	--------------------------------------------------------

	Hub:Enable(Name)

end

print(
	"[Fairwell Heaven] All features loaded."
)

------------------------------------------------------------
-- FINISH LOADING SCREEN
------------------------------------------------------------

local LoadingScreen =
	Hub:GetFeature(
		"Loading Screen"
	)

if LoadingScreen then

	if type(LoadingScreen.Finish)
		== "function" then

		LoadingScreen:Finish(Hub)

	else

		warn(
			"[Fairwell Heaven] "
			.. "Loading Screen has no Finish function."
		)

	end

else

	warn(
		"[Fairwell Heaven] "
		.. "Loading Screen not found."
	)

end

------------------------------------------------------------
-- STARTUP
------------------------------------------------------------

print(
	"[Fairwell Heaven] Startup complete."
)

return Hub
