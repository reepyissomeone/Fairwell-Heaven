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

local function AnalyzeRoom(Room)
	if not Room then
		return nil
	end

	local Counts = {
		key = 0,
		drawer = 0,
		locker = 0,
		book = 0,
		painting = 0,
		light = 0,
		door = 0,
		entity = 0
	}

	for _, Object in ipairs(Room:GetDescendants()) do
		local Name = string.lower(tostring(Object.Name or ""))

		for Kind in pairs(Counts) do
			if string.find(Name, Kind, 1, true) then
				Counts[Kind] += 1
			end
		end

		if string.find(Name, "rush", 1, true)
			or string.find(Name, "ambush", 1, true)
			or string.find(Name, "seek", 1, true)
			or string.find(Name, "figure", 1, true) then
			Counts.entity += 1
		end
	end

	-- Strong visual clues get priority over generic room comments.
	if Counts.entity > 0 then
		return "Uh... I don't think we're alone in here."
	end

	if Counts.book >= 3 then
		return "A lot of books... hopefully one of them has instructions."
	end

	if Counts.key > 0 then
		return "I see a key. That's probably important."
	end

	if Counts.locker > 0 then
		return "I see somewhere to hide. That's... reassuring."
	end

	if Counts.drawer >= 4 then
		return "So many drawers. Surely there's something useful in here."
	end

	if Counts.painting >= 2 then
		return "These paintings are staring at me. I don't like that."
	end

	if Counts.light == 0 then
		return "It's pretty dark in here..."
	end

	if Counts.door >= 2 then
		return "Lots of doors. One of them has to be the right one."
	end

	local Comments = {
		"This room looks suspiciously normal.",
		"Not much going on in here. Yet.",
		"Okay... let's see what this place has.",
		"I wonder what's hiding around here.",
		"Looks safe enough. Probably."
	}

	return Comments[math.random(1, #Comments)]
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

							local Comment = AnalyzeRoom(NewRoom)
							if Comment then
								TellFairwell(Hub, Comment, 4)
							end
							return
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
