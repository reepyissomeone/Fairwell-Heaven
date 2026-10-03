--// FAIRWELL HEAVEN
--// DOORS Core
--// Version 1.0

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Doors = {

	Name = "DOORS Core",

	Description = "Core DOORS game service.",

	Game = "DOORS",

	CurrentRoom = nil,
	CurrentDoor = nil,

	Player = nil,
	Character = nil,
	Root = nil,

	RoomChanged = Instance.new("BindableEvent"),
	DoorChanged = Instance.new("BindableEvent")

}

------------------------------------------------------------
-- ROOM NUMBER
------------------------------------------------------------

function Doors:GetRoomNumber(room)

	if not room then
		return nil
	end

	return tonumber(room.Name)

end

------------------------------------------------------------
-- CURRENT ROOM
------------------------------------------------------------

function Doors:GetCurrentRoom()

	local CurrentRooms =
		workspace:FindFirstChild("CurrentRooms")

	if not CurrentRooms then
		return nil
	end

	local HighestRoom = nil
	local HighestNumber = nil

	for _, Room in ipairs(CurrentRooms:GetChildren()) do

		local Number =
			self:GetRoomNumber(Room)

		if Number then

			if not HighestNumber
				or Number > HighestNumber then

				HighestNumber = Number
				HighestRoom = Room

			end

		end

	end

	return HighestRoom

end

------------------------------------------------------------
-- PLAYER
------------------------------------------------------------

function Doors:UpdatePlayer()

	self.Character =
		self.Player.Character

	self.Root =
		self.Character
		and self.Character:FindFirstChild(
			"HumanoidRootPart"
		)

end

------------------------------------------------------------
-- START
------------------------------------------------------------

function Doors.Start(self, Hub)

	self.Player =
		Players.LocalPlayer

	if not self.Player then

		warn(
			"[Fairwell Heaven] DOORS player not found."
		)

		return

	end

	self:UpdatePlayer()

	self.CharacterConnection =
		self.Player.CharacterAdded:Connect(
			function()

				self:UpdatePlayer()

			end
		)

	self.UpdateConnection =
		RunService.Heartbeat:Connect(
			function()

				self:UpdatePlayer()

				local NewRoom =
					self:GetCurrentRoom()

				if NewRoom ~= self.CurrentRoom then

					local OldRoom =
						self.CurrentRoom

					self.CurrentRoom =
						NewRoom

					self.RoomChanged:Fire(
						NewRoom,
						OldRoom
					)

				end

			end
		)

	Hub:RegisterService(
		"Doors",
		self
	)

	Hub:Log(
		"DOORS Core initialized."
	)

end

------------------------------------------------------------
-- STOP
------------------------------------------------------------

function Doors.Stop(self)

	if self.CharacterConnection then

		self.CharacterConnection:Disconnect()

		self.CharacterConnection = nil

	end

	if self.UpdateConnection then

		self.UpdateConnection:Disconnect()

		self.UpdateConnection = nil

	end

	self.CurrentRoom = nil
	self.CurrentDoor = nil

end

return Doors
