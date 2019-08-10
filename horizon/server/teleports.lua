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

function TeleportTo(player, x, y, z, h)
	h = h or -1.0

	if (GetPlayerVehicleSeat(player) == 1) then
		local vehicle = GetPlayerVehicle(player)
		SetVehicleLocation(vehicle, x, y, z)
		if (h ~= -1.0) then
			SetVehicleHeading(vehicle, h)
		end

		-- Reset velocity
		SetVehicleLinearVelocity(vehicle, 0.0, 0.0, 0.0, true)
		SetVehicleAngularVelocity(vehicle, 0.0, 0.0, 0.0, true)
		local rx, ry, rz = GetVehicleRotation(vehicle)
		-- Reset pitch and roll, leave yaw alone
		SetVehicleRotation(vehicle, 0.0, ry, 0.0)
	else
		SetPlayerLocation(player, x, y, z)
		if (h ~= -1.0) then
			SetPlayerHeading(player, h)
		end
	end

	ResetPlayerCamera(player)
end

function cmd_beach(player)
	TeleportTo(player, 208591.0, 212335.0, 455.0, 180.0)
end
AddCommand("beach", cmd_beach)

function cmd_police(player)
	TeleportTo(player, 173479.0, 192671.0, 1335.0, -90.0)
end
AddCommand("police", cmd_police)

function cmd_gas(player)
	TeleportTo(player, 125773.000000, 80246.000000, 1645.000000, 90.0)
end
AddCommand("gas", cmd_gas)

function cmd_mtn(player)
	TeleportTo(player, -152707.37, -225139.59, 5000.0, -133.0)
end
AddCommand("mtn", cmd_mtn)

function cmd_po(player)
	TeleportTo(player, 41276.2109375, 134418.359375, 1800.7901611328, 89.136711120605)
end
AddCommand("po", cmd_po)

function cmd_pancake(player)
	TeleportTo(player, 119260.0703125, 164159.46875, 3028.7553710938, -129.5276184082)
end
AddCommand("pancake", cmd_pancake)

function cmd_office(player)
	TeleportTo(player, 191711.000000, 191871.000000, 9377.000000)
end
AddCommand("office", cmd_office)

function cmd_garage(player)
	TeleportTo(player, 166606.000000, 219968.000000, 1427.000000)
end
AddCommand("garage", cmd_garage)

function cmd_hospital(player)
	TeleportTo(player, 212112.53125, 160486.25, 1305.2940673828, 174.63586425781)
end
AddCommand("hospital", cmd_hospital)

function cmd_bank(player)
	TeleportTo(player, 211538.875, 190173.734375, 1306.9666748047, -177.48133850098)
end
AddCommand("bank", cmd_bank)

function cmd_prison(player)
	TeleportTo(player, -167958.000000, 78089.000000, 1569.000000, -90.0)
end
AddCommand("prison", cmd_prison)
