--[[
Copyright (C) 2020 Blue Mountains GmbH

This program is free software: you can redistribute it and/or modify it under the terms of the Onset
Open Source License as published by Blue Mountains GmbH.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without
even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
See the Onset Open Source License for more details.

You should have received a copy of the Onset Open Source License along with this program. If not,
see https://bluemountains.io/Onset_OpenSourceSoftware_License.txt
]]--

local StreamedSounds = { }

local AttachedVehicleSounds = { }

AddEvent("OnPackageStop", function()

	for _, v in pairs(AttachedVehicleSounds) do
		DestroySound(v)
	end

	AttachedVehicleSounds = nil
end)

AddEvent("OnObjectStreamIn", function(object)
	
	local _soundStream = GetObjectPropertyValue(object, "_soundStream")

	if _soundStream ~= nil then
		local x, y, z = GetObjectLocation(object)
		local _soundStreamRadius = GetObjectPropertyValue(object, "_soundStreamRadius")
		local _soundStreamVolume = GetObjectPropertyValue(object, "_soundStreamVolume")
		local _soundStreamPitch = GetObjectPropertyValue(object, "_soundStreamPitch")

		StreamedSounds[object] = { }

		local ObjectActor = GetObjectActor(object)

		-- Set the scale to 0 and make it hidden
		ObjectActor:SetActorScale3D(FVector(0.0, 0.0, 0.0))
		ObjectActor:SetActorHiddenInGame(true)

		-- Alos disable its collision
		ObjectActor:SetActorEnableCollision(false)

		-- Create the actual sound
		StreamedSounds[object].sound = CreateSound3D(_soundStream, x, y, z, _soundStreamRadius)

		if StreamedSounds[object].sound == false then
			if IsGameDevMode() then
				AddPlayerChat('<span color="#ff0000bb" style="bold" size="10">You have reached the maximum amount of sounds in this area. Remove some sounds or reduce their radius.</>')
			end
		else
			SetSoundPitch(StreamedSounds[object].sound, _soundStreamPitch)
			SetSoundVolume(StreamedSounds[object].sound, _soundStreamVolume)
		end

		if IsGameDevMode() then
			AddPlayerChat("STREAMIN: Server Sound3D "..object)
		end
	end

end)

AddEvent("OnObjectStreamOut", function(object)

	-- When the dummy object is streamed out make sure to destroy the sound
	if StreamedSounds[object] ~= nil then
		DestroySound(StreamedSounds[object].sound)

		if IsGameDevMode() then
			AddPlayerChat("STREAMOUT: Server Sound3D "..object)
		end

		StreamedSounds[object] = nil
	end

end)

AddEvent("OnObjectNetworkUpdatePropertyValue", function (object, PropertyName, PropertyValue)

	if StreamedSounds[object] == nil then
		return
	end

	if PropertyName == "_soundStreamVolume" then
		SetSoundVolume(StreamedSounds[object].sound, PropertyValue)
	elseif PropertyName == "_soundStreamPitch" then
		SetSoundPitch(StreamedSounds[object].sound, PropertyValue)
	end

end)

AddRemoteEvent("SetStreamedSound3DLocation", function (object, x, y, z)
	if StreamedSounds[object] == nil then
		return
	end
	SetSound3DLocation(StreamedSounds[object].sound, x, y, z)
end)

function CreateVehicleAttachedSound(vehicle)

	local _soundStream = GetVehiclePropertyValue(vehicle, "_soundStream")

	if _soundStream ~= nil then
		local x, y, z = GetVehicleLocation(vehicle)

		if IsGameDevMode() then
			print("Creating attached 3D sound", x, y, z, _soundStream.file, _soundStream.radius)
		end

		AttachedVehicleSounds[vehicle] = CreateSound3D(_soundStream.file, x, y, z, _soundStream.radius)

		if AttachedVehicleSounds[vehicle] ~= false then
			SetSoundPitch(AttachedVehicleSounds[vehicle], _soundStream.pitch)
			SetSoundVolume(AttachedVehicleSounds[vehicle], _soundStream.volume)
		else
			AttachedVehicleSounds[vehicle] = nil
		end
	end
end

function DestroyVehicleAttachedSound(vehicle)
	if AttachedVehicleSounds[vehicle] ~= nil then
		DestroySound(AttachedVehicleSounds[vehicle])
		AttachedVehicleSounds[vehicle] = nil
	end
end

AddEvent("OnVehicleStreamIn", function (vehicle)
	CreateVehicleAttachedSound(vehicle)
end)

AddEvent("OnVehicleStreamOut", function (vehicle)
	DestroyVehicleAttachedSound(vehicle)
end)

AddEvent("OnGameTick", function (DeltaSeconds)
	for k, v in pairs(AttachedVehicleSounds) do
		local x, y, z = GetVehicleLocation(k)

		SetSound3DLocation(v, x, y, z)		
	end	
end)

AddEvent("OnVehicleNetworkUpdatePropertyValue", function(vehicle, PropertyName, PropertyValue)

	if PropertyName == "_soundStream" then
		if PropertyValue == false then
			DestroyVehicleAttachedSound(vehicle)
		elseif PropertyValue ~= nil then
			-- Delay this to the next tick because GetVehiclePropertyValue in the function would return the old value in this event.
			Delay(1, function(v)
				CreateVehicleAttachedSound(v)
			end, vehicle)
		end
	end

end)
