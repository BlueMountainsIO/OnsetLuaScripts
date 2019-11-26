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

--Vehicles
CreateVehicle(1, 125604.703125, 82548.3046875, 1469.5706787109, -94.918533325195)
CreateVehicle(2, 125983.984375, 82535.4609375, 1469.541015625, -94.270843505859)
CreateVehicle(3, 126371.015625, 82529.2421875, 1469.5506591797, -92.928779602051)
CreateVehicle(4, 126787.4140625, 82512.8828125, 1468.4599609375, -91.912307739258)
CreateVehicle(5, 127260.8515625, 82608.3359375, 1471.1015625, -90.071769714355)
CreateVehicle(6, 127643.0546875, 82579.125, 1468.8540039062, -93.760871887207)
CreateVehicle(7, 128068.6953125, 82584.609375, 1466.5334472656, -90.478660583496)
CreateVehicle(8, 128756.5859375, 82445.515625, 1466.5108642578, -104.88040924072)
CreateVehicle(9, 132347.953125, 80222.6484375, 1566.9005126953, -89.371635437012)
CreateVehicle(10, 129932.7734375, 82583.265625, 1470.3785400391, -122.43447875977)
CreateVehicle(11, 129129.53125, 79765.2734375, 1469.5688476562, 90.537796020508)
CreateVehicle(12, 130539.890625, 82047.6328125, 1469.4406738281, -147.66664123535)
CreateVehicle(13, 131762.34375, 79963.90625, 1668.2921142578, -88.196624755859)
CreateVehicle(16, 125596.28125, 74573.09375, 1668.2861328125, 134.67620849609)

--Text3D
CreateText3D("/gas", 80, 125769.710938, 80245.554688, 1600.395508, 90.000000, 56.309914, 146.309296)

--NPC
local npc = CreateNPC(128959.1015625, 79325.328125, 1579.2750244141, 84.066261291504)
SetNPCPropertyValue(npc, "_modelPreset", 23)

CreateObject(42, 127015.390625, 80362.5234375, 1566.9710693359)

local WeaponPickups = {}
local ParachutePickups = {}
local HealthPickups = {}
local ArmorPickups = {}
local ConePickups = {}

local function OnPackageStart()
	for i=1,19 do
		WeaponPickups[i] = CreatePickup(i + 3, 129898.9453125, 81860.2421875 - (i * 200.0), 1566.9010009766)
	end

	ParachutePickups[1] = CreatePickup(818, 130222.4296875, 80253.5859375, 1659.2888183594)

	HealthPickups[1] = CreatePickup(815, 128329.15625, 79425.5703125, 1566.9007568359)

	ArmorPickups[1] = CreatePickup(814, 129374.484375, 79380.2109375, 1566.9005126953)

	ConePickups[1] = CreatePickup(2, 191678.546875, 195024.28125, 1310.6500244141, -98.309234619141)

	local TextureObject = CreateObject(1, 128651.5234375, 79332.890625, 1579.2681884766)
	SetObjectPropertyValue(TextureObject, "_texture", "animated")
	SetObjectPropertyValue(TextureObject, "_textureFile", GetPackageName().."/client/files/AnimatedBanana.PNG")
	SetObjectPropertyValue(TextureObject, "_textureRowColumns", { 2, 4 })

	TextureObject = CreateObject(3, 126489.7890625, 80245.554688, 1477.395508)
	SetObjectPropertyValue(TextureObject, "_texture", "static")
	SetObjectPropertyValue(TextureObject, "_textureFile", GetPackageName().."/client/files/AI.png")
	SetObjectScale(TextureObject, 0.5, 0.5, 1.0)
end
AddEvent("OnPackageStart", OnPackageStart)

local function OnPlayerPickupHit(player, pickup)
	--AddPlayerChat(player, "You have hit pickup id "..pickup)
	
	for i, p in ipairs(WeaponPickups) do
		if p == pickup then
			SetPlayerWeapon(player, i + 1, 450, true, 1)
			return
		end
	end

	for _, v in pairs(ParachutePickups) do
		if v == pickup then
			AttachPlayerParachute(player, true)
			return
		end
	end

	for _, v in pairs(HealthPickups) do
		if v == pickup then
			SetPlayerHealth(player, 100.0)
			return
		end
	end

	for _, v in pairs(ArmorPickups) do
		if v == pickup then
			SetPlayerArmor(player, 100.0)
			return
		end
	end

	if pickup == ConePickups[1] then
		SetPlayerLocation(player, 191711.000000, 191871.000000, 9377.000000)
		return
	end
end
AddEvent("OnPlayerPickupHit", OnPlayerPickupHit)
