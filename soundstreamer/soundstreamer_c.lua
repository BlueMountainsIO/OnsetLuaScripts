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

-- Expose attach types like on the server.
if ATTACH_NONE == nil then
	ATTACH_NONE = 0
end
if ATTACH_PLAYER == nil then
	ATTACH_PLAYER = 1
end
if ATTACH_VEHICLE == nil then
	ATTACH_VEHICLE = 2
end
if ATTACH_OBJECT == nil then
	ATTACH_OBJECT = 3
end
if ATTACH_NPC == nil then
	ATTACH_NPC = 4
end

AddEvent("OnPackageStop", function()

	for k, v in pairs(StreamedSounds) do
		DestroySound(v.sound)
	end

	StreamedSounds = nil

end)

AddEvent("OnObjectStreamIn", function(object)
	
	if StreamedSounds[object] ~= nil then
		print("ERROR: OnObjectStreamIn("..object..") called where we already have one")
		return
	end

	local _soundStream = GetObjectPropertyValue(object, "_soundStream")

	if _soundStream ~= nil then

		StreamedSounds[object] = { }
		StreamedSounds[object] = _soundStream

		local ObjectActor = GetObjectActor(object)

		-- Set the scale to 0 and make it hidden
		ObjectActor:SetActorScale3D(FVector(0.01, 0.01, 0.01))
		ObjectActor:SetActorHiddenInGame(true)

		-- Alos disable its collision
		ObjectActor:SetActorEnableCollision(false)

		local x, y, z

		if _soundStream.is_attached == false then

			x, y, z = GetObjectLocation(object)

		elseif _soundStream.is_attached == true then

			if _soundStream.attach == ATTACH_VEHICLE then
				
				x, y, z = GetVehicleLocation(_soundStream.id)

			elseif _soundStream.attach == ATTACH_PLAYER then

				x, y, z = GetPlayerLocation(_soundStream.id)

			elseif _soundStream.attach == ATTACH_OBJECT then

				x, y, z = GetObjectLocation(_soundStream.id)				

			elseif _soundStream.attach == ATTACH_NPC then

				x, y, z = GetNPCLocation(_soundStream.id)			

			end
		end

		-- Create the actual sound
		StreamedSounds[object].sound = CreateSound3D(_soundStream.file, x, y, z, _soundStream.radius)

		if StreamedSounds[object].sound == false then
			if IsGameDevMode() then
				local msg = "WARNING: Attempting to create streamed 3d sound but there already is a maximum number of sounds in this area. Remove some sounds or reduce their radius."
				AddPlayerChat('<span color="#ff0000bb" style="bold" size="10">'..msg..'</>')
				print(msg)
			end
			StreamedSounds[object] = nil
			return
		else
			SetSoundPitch(StreamedSounds[object].sound, _soundStream.pitch)
			SetSoundVolume(StreamedSounds[object].sound, _soundStream.volume)
		end

		if IsGameDevMode() then
			AddPlayerChat("STREAMIN: Server Sound3D for Object "..object)
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

AddEvent("OnObjectNetworkUpdatePropertyValue", function(object, PropertyName, PropertyValue)

	if StreamedSounds[object] == nil then
		return
	end

	if PropertyName == "_soundStream" then
		
		local CurrentPV = GetObjectPropertyValue(object, PropertyName)
		if CurrentPV.radius ~= PropertyValue.radius then
			DestroySound(StreamedSounds[object].sound)
			StreamedSounds[object].sound = CreateSound3D(StreamedSounds[object].file, x, y, z, PropertyValue.radius)
		end

		SetSoundVolume(StreamedSounds[object].sound, PropertyValue.volume)
		SetSoundPitch(StreamedSounds[object].sound, PropertyValue.pitch)

		StreamedSounds[object].volume = PropertyValue.volume
		StreamedSounds[object].pitch = PropertyValue.pitch
		StreamedSounds[object].radius = PropertyValue.radius
		
	end

end)

AddRemoteEvent("SetStreamedSound3DLocation", function(object, x, y, z)
	if StreamedSounds[object] == nil then
		return
	end
	SetSound3DLocation(StreamedSounds[object].sound, x, y, z)
end)


AddEvent("OnGameTick", function(DeltaSeconds)

	for k, v in pairs(StreamedSounds) do
		if v.is_attached then
			local x, y, z
			if v.attach == ATTACH_VEHICLE then
				if IsValidVehicle(v.id) then
					x, y, z = GetVehicleLocation(v.id)				
				end
			elseif v.attach == ATTACH_PLAYER then
				if IsValidPlayer(v.id) then
					x, y, z = GetPlayerLocation(v.id)
				end
			elseif v.attach == ATTACH_OBJECT then
				if IsValidObject(v.id) then
					x, y, z = GetObjectLocation(v.id)
				end
			elseif v.attach == ATTACH_NPC then
				if IsValidNPC(v.id) then
					x, y, z = GetNPCLocation(v.id)
				end
			end
			SetSound3DLocation(v.sound, x, y, z)
		end
	end

end)
