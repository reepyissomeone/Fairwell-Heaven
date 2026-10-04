--// FAIRWELL HEAVEN
--// Game Detection

local Games = {}

Games.DOORS = {
	Name = "DOORS",

	-- Roblox DOORS place.
	PlaceId = 6516141723
}

function Games:Detect()

	local PlaceId = game.PlaceId

	------------------------------------------------------------
	-- DOORS PLACE ID
	------------------------------------------------------------

	if PlaceId == self.DOORS.PlaceId then

		return {
			Name = "DOORS",
			IsDOORS = true,
			PlaceId = PlaceId
		}

	end

	------------------------------------------------------------
	-- FALLBACK DOORS DETECTION
	------------------------------------------------------------

	local Workspace = game:GetService("Workspace")

	if Workspace:FindFirstChild("CurrentRooms") then

		return {
			Name = "DOORS",
			IsDOORS = true,
			PlaceId = PlaceId
		}

	end

	------------------------------------------------------------
	-- UNKNOWN GAME
	------------------------------------------------------------

	return {
		Name = "Unknown",
		IsDOORS = false,
		PlaceId = PlaceId
	}

end

return Games