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

AddEvent("OnPackageStop", function()

	for k, v in pairs(StreamedSounds) do
		DestroyObject(k)
	end

	StreamedSounds = nil
end)

AddFunctionExport("CreateSound3D", function (sound_file, x, y, z, radius, volume, pitch)

	radius = radius or 2500.0
	volume = volume or 1.0
	pitch = pitch or 1.0

	-- Create a dummy object that will help us streaming the sound
	local object = CreateObject(1, x, y, z)
	SetObjectPropertyValue(object, "_soundStream", sound_file)
	SetObjectPropertyValue(object, "_soundStreamRadius", radius)
	SetObjectPropertyValue(object, "_soundStreamVolume", volume)
	SetObjectPropertyValue(object, "_soundStreamPitch", pitch)
	SetObjectStreamDistance(object, radius)

	StreamedSounds[object] = { }
	StreamedSounds[object].sound_file = sound_file
	StreamedSounds[object].radius = radius
	StreamedSounds[object].volume = volume
	StreamedSounds[object].pitch = pitch

	return object
end)

AddFunctionExport("AttachSound3D", function(attach, id, sound_file, radius, volume, pitch)

	if attach == nil or id == nil or sound_file == nil then
		return false
	end

	radius = radius or 2500.0
	volume = volume or 1.0
	pitch = pitch or 1.0

	if attach == ATTACH_VEHICLE then
		if not IsValidVehicle(id) then
			return false
		end

		if GetVehiclePropertyValue(id, "_soundStream") ~= nil then
			-- Sound already attached
			return false
		end
		
		local _soundStream = { }
		_soundStream.file = sound_file
		_soundStream.radius = radius
		_soundStream.volume = volume
		_soundStream.pitch = pitch

		SetVehiclePropertyValue(id, "_soundStream", _soundStream)
		return true
	end

	return false
end)

AddFunctionExport("DetachSound3D", function(attach, id)

	if attach == nil or id == nil then
		return false
	end

	if attach == ATTACH_VEHICLE then
		if not IsValidVehicle(id) then
			return false
		end

		if GetVehiclePropertyValue(id, "_soundStream") == nil then
			-- No sound attached
			return false
		end

		SetVehiclePropertyValue(id, "_soundStream", false)
		SetVehiclePropertyValue(id, "_soundStream", nil)		
		return true
	end

	return false
end)

AddFunctionExport("IsSoundAttached", function(attach, id)
	if attach == nil or id == nil then
		return false
	end

	if attach == ATTACH_VEHICLE then
		if not IsValidVehicle(id) then
			return false
		end

		if GetVehiclePropertyValue(id, "_soundStream") ~= nil then
			return true
		end
	end

	return false
end)

AddFunctionExport("DestroySound3D", function (object)
	if StreamedSounds[object] == nil then
		return false
	end
	StreamedSounds[object] = nil
	return DestroyObject(object)
end)

AddFunctionExport("IsValidSound3D", function (object)
	return StreamedSounds[object] ~= nil
end)

AddFunctionExport("SetSound3DVolume", function (object, volume)
	volume = volume or 1.0

	if StreamedSounds[object] == nil then
		return false
	end
	SetObjectPropertyValue(object, "_soundStreamVolume", volume)
	return true
end)

AddFunctionExport("SetSound3DPitch", function (object, pitch)
	pitch = pitch or 1.0

	if StreamedSounds[object] == nil then
		return false
	end
	SetObjectPropertyValue(object, "_soundStreamPitch", pitch)
	return true
end)

AddFunctionExport("SetSound3DDimension", function (object, dimension)
	if StreamedSounds[object] == nil then
		return false
	end
	SetObjectDimension(object, dimension)
	return true
end)

AddFunctionExport("GetSound3DDimension", function (object)
	if StreamedSounds[object] == nil then
		return false
	end
	return GetObjectDimension(object)
end)

AddFunctionExport("SetSound3DLocation", function (object, x, y, z)
	if StreamedSounds[object] == nil then
		return false
	end

	-- We need to notify the client about the loction change with a remote event.
	-- Because SetObjectLocation does not trigger a stream event on the client if the location is within the stream radius.
	for _, v in pairs(GetAllPlayers()) do
		if IsObjectStreamedIn(v, object) then
			CallRemoteEvent(v, "SetStreamedSound3DLocation", object, x, y, z)
		end
	end

	-- Will trigger client stream in/out events if necessary
	SetObjectLocation(object, x, y, z)
	return true
end)

AddFunctionExport("GetSound3DLocation", function (object)
	if StreamedSounds[object] == nil then
		return false
	end

	local x, y, z = GetObjectLocation(object)
	return x, y, z
end)
