--[[
Copyright (C) 2019 Blue Mountains GmbH

This program is free software: you can redistribute it and/or modify it under the terms of the Onset
Open Source License as published by Blue Mountains GmbH.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without
even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
See the Onset Open Source License for more details.

You should have received a copy of the Onset Open Source License along with this program. If not,
see https://bluemountains.io/Onset_OpenSourceSoftware_License.txt
]]--

function UpdateServerData(player)
	
	local PoolsTable = { }
	PoolsTable[1] = GetPlayerCount()
	PoolsTable[2] = GetVehicleCount()
	PoolsTable[3] = GetObjectCount()
	PoolsTable[4] = GetNPCCount()
	PoolsTable[5] = GetPickupCount()
	PoolsTable[6] = GetText3DCount()
	PoolsTable[7] = GetLightCount()
	PoolsTable[8] = GetTimerCount()
	
	local NetStats = GetNetworkStats()
	
	local AvgPing = 0
	for _, v in pairs(GetAllPlayers()) do
		AvgPing = AvgPing + GetPlayerPing(v)
	end
	AvgPing = AvgPing / GetPlayerCount()
	
	CallRemoteEvent(player, "OnGetUpdateServerPools", PoolsTable, NetStats, AvgPing)
end
AddRemoteEvent("UpdateServerData", UpdateServerData)

AddCommand("debugstat", function(player)
	CallRemoteEvent(player, "ToggleDebugStats")
end)

function cmd_debugobject(player, object)
	if (object == nil) then
		return AddPlayerChat(player, "Usage: /debugobject <object>")
	end

	if (not IsValidObject(object)) then
		return AddPlayerChat(player, "Object (ID: "..object..") does not exist")
	end
	
	local x, y, z = GetObjectLocation(object)
	local rx, ry, rz = GetObjectRotation(object)
	local sx, sy, sz = GetObjectScale(object)
	local isAttached = IsObjectAttached(object)
	local attachType, attachId = GetObjectAttachmentInfo(object)
	local isMoving = IsObjectMoving(object)
	--local streamed = IsObjectStreamedIn(player, object) == true and 'True' or 'False'
	
	AddPlayerChat(player, '<span color="00ee00ff">Object (ID: '..object..')</>')
	AddPlayerChat(player, '  Loc: ' .. x .. ', ' .. y .. ', ' .. z)
	AddPlayerChat(player, '  Rot: ' .. rx .. ', ' .. ry .. ', ' .. rz)
	AddPlayerChat(player, '  Scale: ' .. sx .. ', ' .. sy .. ', ' .. sz)
	if isAttached then
		local attachTypeStr
		if attachType == ATTACH_PLAYER then
			attachTypeStr = "Player"
		else
			attachTypeStr = "Vehicle"
		end
		AddPlayerChat(player, '  AttachedTo: ' .. attachTypeStr .. ', ' .. attachId)
	end
	if isMoving then
		AddPlayerChat(player, '  Moving: ' .. isMoving)
	end
end
AddCommand("debugobject", cmd_debugobject)

function cmd_debugvehicle(player, vehicle)
	if (vehicle == nil) then
		return AddPlayerChat(player, "Usage: /debugvehicle <vehicle>")
	end

	if (not IsValidVehicle(vehicle)) then
		return AddPlayerChat(player, "Vehicle (ID: "..vehicle..") does not exist")
	end

	local model = GetVehicleModelName(vehicle).." (ModelID: "..GetVehicleModel(vehicle)..")"
	local x, y, z = GetVehicleLocation(vehicle)
	local rx, ry, rz = GetVehicleRotation(vehicle)
	local h = GetVehicleRotation(vehicle)
	local vx, vy, vz = GetVehicleVelocity(vehicle)
	local health = GetVehicleHealth(vehicle)
	local r, g, b = HexToRGBA(GetVehicleColor(vehicle))
	local streamed = IsVehicleStreamedIn(player, vehicle) == true and 'True' or 'False'
	local occupants = {}

	for i=1, GetVehicleNumberOfSeats(vehicle) do
		local passenger = GetVehiclePassenger(vehicle, i)
		if (passenger == 0) then
			occupants[i] = "Empty"
		else
			occupants[i] = GetPlayerName(passenger).."("..passenger..")"
		end
	end

	AddPlayerChat(player, '<span color="00ee00ff">Vehicle (ID: '..vehicle..')</>')
	AddPlayerChat(player, '  Loc: ' .. x .. ', ' .. y .. ', ' .. z)
	AddPlayerChat(player, '  Rot: ' .. rx .. ', ' .. ry .. ', ' .. rz)
	AddPlayerChat(player, '  Velocity: ' .. vx .. ', ' .. vy .. ', ' .. vz)
	AddPlayerChat(player, '  Health: '..health)
	AddPlayerChat(player, '  Model: '..model)
	AddPlayerChat(player, '  Color: '..r..', '..g..', '..b)
	AddPlayerChat(player, '  StreamedIn: '..streamed)

	for k, v in ipairs(occupants) do
		AddPlayerChat(player, '    Seat '..k..': '..v)
	end
end
AddCommand("debugvehicle", cmd_debugvehicle)

function cmd_getdriver(player, vehicle)
	if (vehicle == nil) then
		return AddPlayerChat(player, "Usage: /getdriver <vehicle>")
	end

	if (not IsValidVehicle(vehicle)) then
		return AddPlayerChat(player, "Vehicle (ID: "..vehicle..") does not exist")
	end

	local driver = GetVehicleDriver(vehicle)
	local name = GetPlayerName(driver)
	AddPlayerChat(player, "Vehicle "..vehicle.." driver is "..name.." ("..driver..")")
end
AddCommand("getdriver", cmd_getdriver)
