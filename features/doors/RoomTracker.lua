--// FAIRWELL HEAVEN
--// DOORS Room Tracker

local RoomTracker = {

	Name = "DOORS Room Tracker",

	Description = "Tracks the current DOORS room.",

	Game = "DOORS",

	CurrentRoomNumber = nil,

	ChangedConnection = nil,

	SeekRoomToken = 0

}

local function IsSeekRoom(Room)
	if not Room then
		return false
	end

	local function LooksLikeSeek(Name)
		Name = string.lower(tostring(Name or ""))
		return Name == "seek"
			or string.find(Name, "seekroom", 1, true) ~= nil
			or string.find(Name, "seek_room", 1, true) ~= nil
	end

	if LooksLikeSeek(Room.Name) then
		return true
	end

	for _, Object in ipairs(Room:GetDescendants()) do
		if LooksLikeSeek(Object.Name) then
			return true
		end
	end

	return false
end

local function TellFairwell(Hub, Message, Duration)
	local MainUI = Hub:GetFeature("Main UI")
	if not MainUI or type(MainUI.CompanionNotify) ~= "function" then
		return
	end

	MainUI.CompanionNotify(
		"FAIRWELL",
		Message,
		"INFO",
		Duration or 4
	)
end

function RoomTracker.Start(self, Hub)

	local Doors =
		Hub:GetService("Doors")

	if not Doors then

		warn(
			"[Fairwell Heaven] DOORS service unavailable."
		)

		return

	end

	------------------------------------------------------------
	-- INITIAL ROOM
	------------------------------------------------------------

	if Doors.CurrentRoom then

		self.CurrentRoomNumber =
			Doors:GetRoomNumber(
				Doors.CurrentRoom
			)

	end

	------------------------------------------------------------
	-- ROOM CHANGES
	------------------------------------------------------------

	self.ChangedConnection =
		Doors.RoomChanged.Event:Connect(
			function(NewRoom, OldRoom)

				local Number =
					Doors:GetRoomNumber(
						NewRoom
					)

				self.CurrentRoomNumber =
					Number

				Hub:Log(
					"DOORS room changed:",
					tostring(Number)
				)

				self.SeekRoomToken += 1
				local Token = self.SeekRoomToken

				task.spawn(function()
					for _, Delay in ipairs({0, 0.25, 0.75, 1.5, 2.5}) do
						if Delay > 0 then
							task.wait(Delay)
						end

						if Token ~= self.SeekRoomToken then
							return
						end

						if Doors.CurrentRoom == NewRoom then
							if Number == 50 then
								TellFairwell(
									Hub,
									"I ain't good at reading but I'll see what I can do",
									5
								)
								return
							end

							if IsSeekRoom(NewRoom) then
								TellFairwell(Hub, "Good luck.", 4)
								return
							end
						end
					end
				end)

			end
		)

	Hub:Log(
		"DOORS Room Tracker started."
	)

end

function RoomTracker.Stop(self)

	if self.ChangedConnection then

		self.ChangedConnection:Disconnect()

		self.ChangedConnection = nil

	end

	self.CurrentRoomNumber = nil
	self.SeekRoomToken += 1

end

return RoomTracker
