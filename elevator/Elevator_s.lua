
local ElevatorOutsideDoors = { }

local Elevators = { }

local Elevator1 = {
	{ 173010.000000, 216169.000000, 782.0 },
	{ 173010.000000, 216169.000000, 1182.0 },
	{ 173010.000000, 216169.000000, 1583.0 },
	{ 173010.000000, 216169.000000, 2150.0 }
}

local Elevator2 = {
	{ 172750.000000, 216169.000000, 782.0 },
	{ 172750.000000, 216169.000000, 1182.0 },
	{ 172750.000000, 216169.000000, 1583.0 },
	{ 172750.000000, 216169.000000, 2150.0 }
}

AddEvent("OnPackageStart", function()

	CreateElevator(Elevator1, 2)
	CreateElevator(Elevator2, 2)
	
end)

AddEvent("OnPackageStop", function()

	for k, v in pairs(Elevators) do
		DestroyObject(k)
		
		for k2, v2 in pairs(v.OutsideDoors) do
			DestroyObject(v2)
		end
		
		v.OutsideDoors = { }
	end
	
	Elevators = { }

end)

AddRemoteEvent("Elevator:RequestFloor", function(player, object, Floor)
	
	if Elevators[object] == nil then return end
	
	if Elevators[object].FloorPositions[Floor] == nil then return end
	
	local x, y, z = GetPlayerLocation(player)
	local x2, y2, z2 = GetObjectLocation(object)
	if GetDistance3D(x, y, z, x2, y2, z2) < 600.0 then
		if GetObjectPropertyValue(object, "moving") == false and GetObjectPropertyValue(object, "waiting") == false then	
			SetObjectPropertyValue(object, "waiting", true)
			OpenCloseDoors(object, "close")
			CreateCountTimer(function(object, Floor)
				SetObjectPropertyValue(object, "waiting", false)
				MoveElevator(object, Floor)
			end, 4500, 1, object, Floor)	
		end
	end
end)

AddRemoteEvent("Elevator:RequestDoor", function(player, door)
	--print("Elevator:RequestDoor", player, door)
	
	for k, v in pairs(Elevators) do
		for k2, v2 in pairs(v.OutsideDoors) do
			if v2 == door then
				local x, y, z = GetPlayerLocation(player)
				local x2, y2, z2 = GetObjectLocation(v2)
				if GetDistance3D(x, y, z, x2, y2, z2) < 400.0 then
					if GetObjectPropertyValue(k, "moving") == false and GetObjectPropertyValue(k, "waiting") == false then
						SetObjectPropertyValue(k, "waiting", true)
						OpenCloseDoors(k, "close")
						CreateCountTimer(function(k, k2)
							SetObjectPropertyValue(k, "waiting", false)
							MoveElevator(k, k2)
						end, 4500, 1, k, k2)
					end
				end
				break
			end
		end		
	end
end)

AddEvent("OnObjectStopMoving", function(object)
	--print("OnObjectStopMoving", object)
	
	if Elevators[object] ~= nil then
		SetObjectPropertyValue(object, "moving", false)
		
		OpenCloseDoors(object, "open")
	end
end)

function CreateElevator(ElevatorPositions, Floor)

	if ElevatorPositions[Floor] == nil then return false end

	local object = CreateObject(1, ElevatorPositions[Floor][1], ElevatorPositions[Floor][2], ElevatorPositions[Floor][3])
	
	--print("Elevator object:", object)
	--print("Num Floors", #ElevatorPositions)
	
	SetObjectPropertyValue(object, "elevator", true)
	SetObjectPropertyValue(object, "state", "open")
	SetObjectPropertyValue(object, "floor", Floor)
	SetObjectPropertyValue(object, "num_floors", #ElevatorPositions)
	SetObjectPropertyValue(object, "moving", false)
	SetObjectPropertyValue(object, "waiting", false)
	
	Elevators[object] = { }
	Elevators[object].OutsideDoors = { }
	Elevators[object].FloorPositions = ElevatorPositions
	
	for k, v in pairs(ElevatorPositions) do
		
		Elevators[object].OutsideDoors[k] = CreateObject(1, v[1], v[2], v[3])
		SetObjectPropertyValue(Elevators[object].OutsideDoors[k], "elevator_door", true)
		SetObjectPropertyValue(Elevators[object].OutsideDoors[k], "floor", k)
		SetObjectPropertyValue(Elevators[object].OutsideDoors[k], "state", Floor == k and "open" or "close")
		SetObjectPropertyValue(Elevators[object].OutsideDoors[k], "elevator_parent", object, false)
		
		--print(" Door:", Elevators[object].OutsideDoors[k])
		
	end
	
	return object
end

function MoveElevator(object, Floor)
	--print("MoveElevator", object, Floor)

	if Elevators[object] == nil then return false end

	if GetObjectPropertyValue(object, "moving") == true then return false end
	
	if Elevators[object].FloorPositions[Floor] == nil then return false end
	
	SetObjectPropertyValue(object, "floor", Floor)
	SetObjectPropertyValue(object, "moving", true)
	
	local speed = 90.0
	
	SetObjectMoveTo(object, Elevators[object].FloorPositions[Floor][1], Elevators[object].FloorPositions[Floor][2], Elevators[object].FloorPositions[Floor][3], speed)
	
	return true
end

function OpenCloseDoors(object, openclose)

	if Elevators[object] == nil then return false end

	if GetObjectPropertyValue(object, "moving") == true then return false end

	local Floor = GetObjectPropertyValue(object, "floor")

	SetObjectPropertyValue(object, "state", openclose)
	SetObjectPropertyValue(Elevators[object].OutsideDoors[Floor], "state", openclose)

	for _, v in pairs(GetAllPlayers()) do
		CallRemoteEvent(v, "Elevator:OpenClose", object, openclose)
		
		CallRemoteEvent(v, "ElevatorOutside:OpenClose", Elevators[object].OutsideDoors[Floor], openclose)
	end
	
	return true
end
