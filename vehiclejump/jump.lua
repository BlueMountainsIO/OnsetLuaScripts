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

function VehicleJump(player)
	local vehicle = GetPlayerVehicle(player)
	if (vehicle ~= 0) then
		if GetPlayerVehicleSeat(player) == 1 then
			SetVehicleLinearVelocity(vehicle, 0.0, 0.0, 800.0, false)
		end
	end
end
AddRemoteEvent("VehicleJump", VehicleJump)

function VehicleVelocityReset(player)
	local vehicle = GetPlayerVehicle(player)
	if (vehicle ~= 0) then
		SetVehicleLinearVelocity(vehicle, 0.0, 0.0, 0.0, true)
		SetVehicleAngularVelocity(vehicle, 0.0, 0.0, 0.0, true)
		local rx, ry, rz = GetVehicleRotation(vehicle)
		-- Reset pitch and roll, leave yaw alone
		SetVehicleRotation(vehicle, 0.0, ry, 0.0)
	end
end
AddRemoteEvent("VehicleVelocityReset", VehicleVelocityReset)

function VehicleAccel(player)
	local vehicle = GetPlayerVehicle(player)
	if (vehicle ~= 0) then
		if (GetPlayerVehicleSeat(player) == 1) then
			local x, y, z = GetVehicleVelocity(vehicle)
			local size = x * x + y * y + z * z
			if (size < 25000000) then
				local mult = 0.3
				SetVehicleLinearVelocity(vehicle, x * mult, y * mult, z * mult, false)
			end
		end
	end
end
AddRemoteEvent("VehicleAccel", VehicleAccel)
