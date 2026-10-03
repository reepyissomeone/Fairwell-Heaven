--// FAIRWELL HEAVEN
--// DOORS Door Tracker

local DoorTracker = {

	Name = "DOORS Door Tracker",

	Description = "Tracks doors belonging to the current room.",

	Game = "DOORS",

	CurrentDoor = nil,

	ChangedConnection = nil,

	RoomConnection = nil

}

------------------------------------------------------------
-- FIND DOOR
------------------------------------------------------------

function DoorTracker.FindDoor(room)

	if not room then
		return nil
	end

	------------------------------------------------------------
	-- NORMAL DOOR OBJECT
	------------------------------------------------------------

	local Door = room:FindFirstChild("Door")

	if Door then
		return Door
	end

	------------------------------------------------------------
	-- SEARCH DESCENDANTS
	------------------------------------------------------------

	for _, Object in ipairs(
		room:GetDescendants()
	) do

		if Object.Name == "Door" then

			return Object

		end

	end

	return nil

end

------------------------------------------------------------
-- UPDATE
------------------------------------------------------------

function DoorTracker.Update(self, Hub, Room)

	local NewDoor =
		self.FindDoor(Room)

	if NewDoor ~= self.CurrentDoor then

		local OldDoor =
			self.CurrentDoor

		self.CurrentDoor =
			NewDoor

		local Doors =
			Hub:GetService("Doors")

		if Doors then

			Doors.CurrentDoor =
				NewDoor

			Doors.DoorChanged:Fire(
				NewDoor,
				OldDoor
			)

		end

		if NewDoor then

			Hub:Log(
				"DOORS door detected:",
				NewDoor:GetFullName()
			)

		end

	end

end

------------------------------------------------------------
-- START
------------------------------------------------------------

function DoorTracker.Start(self, Hub)

	local Doors =
		Hub:GetService("Doors")

	if not Doors then

		warn(
			"[Fairwell Heaven] DOORS service unavailable."
		)

		return

	end

	------------------------------------------------------------
	-- INITIAL
	------------------------------------------------------------

	self:Update(
		Hub,
		Doors.CurrentRoom
	)

	------------------------------------------------------------
	-- ROOM CHANGES
	------------------------------------------------------------

	self.RoomConnection =
		Doors.RoomChanged.Event:Connect(
			function(NewRoom)

				self:Update(
					Hub,
					NewRoom
				)

			end
		)

	Hub:Log(
		"DOORS Door Tracker started."
	)

end

------------------------------------------------------------
-- STOP
------------------------------------------------------------

function DoorTracker.Stop(self)

	if self.RoomConnection then

		self.RoomConnection:Disconnect()

		self.RoomConnection = nil

	end

	self.CurrentDoor = nil

end

return DoorTracker
