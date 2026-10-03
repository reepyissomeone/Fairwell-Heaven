--// FAIRWELL HEAVEN
--// DOORS Room Tracker

local RoomTracker = {

	Name = "DOORS Room Tracker",

	Description = "Tracks the current DOORS room.",

	Game = "DOORS",

	CurrentRoomNumber = nil,

	ChangedConnection = nil

}

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

end

return RoomTracker
