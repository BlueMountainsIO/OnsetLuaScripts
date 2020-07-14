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

	if sound_file == nil or x == nil or y == nil or z == nil then
		return false
	end

	radius = radius or 2500.0
	volume = volume or 1.0
	pitch = pitch or 1.0

	-- Create a dummy object that will help us streaming the sound
	local object = CreateObject(1, x, y, z)

	if object == false then
		return false
	end

	SetObjectStreamDistance(object, radius)

	local _soundStream = { }
	_soundStream.is_attached = false
	_soundStream.file = sound_file
	_soundStream.radius = radius
	_soundStream.volume = volume
	_soundStream.pitch = pitch

	SetObjectPropertyValue(object, "_soundStream", _soundStream)

	StreamedSounds[object] = _soundStream

	return object
end)

AddFunctionExport("CreateAttachedSound3D", function(attach, id, sound_file, radius, volume, pitch)

	if attach == nil or id == nil or sound_file == nil then
		return false
	end

	radius = radius or 2500.0
	volume = volume or 1.0
	pitch = pitch or 1.0

	local object = CreateObject(1, 0.0, 0.0, 0.0)
	
	if object == false then
		return false
	end

	local _soundStream = { }
	_soundStream.is_attached = true
	_soundStream.attach = attach
	_soundStream.id = id
	_soundStream.file = sound_file
	_soundStream.radius = radius
	_soundStream.volume = volume
	_soundStream.pitch = pitch

	SetObjectPropertyValue(object, "_soundStream", _soundStream)

	if SetObjectAttached(object, attach, id, 0.0, 0.0, 0.0) == false then
		DestroyObject(object)
		return false
	end

	StreamedSounds[object] = _soundStream

	return object
end)

AddFunctionExport("GetAttached3DSounds", function(attach, id)
	
	if attach == nil or id == nil then
		return false
	end

	local sounds = { }

	for k, v in pairs(StreamedSounds) do
		if v.is_attached == true then
			if v.attach == attach and v.id == id then
				table.insert(sounds, k)
			end
		end
	end

	return sounds
end)

AddFunctionExport("DestroySound3D", function(object)
	if object == nil then
		return false
	end
	if StreamedSounds[object] == nil then
		return false
	end
	StreamedSounds[object] = nil
	return DestroyObject(object)
end)

AddFunctionExport("IsValidSound3D", function(object)
	return StreamedSounds[object] ~= nil
end)

AddFunctionExport("IsAttachedSound3D", function(object)
	if StreamedSounds[object] == nil then
		return false
	end
	return StreamedSounds[object].is_attached
end)

AddFunctionExport("SetSound3DVolume", function(object, volume)
	if object == nil then
		return false
	end

	volume = volume or 1.0

	if StreamedSounds[object] == nil then
		return false
	end

	StreamedSounds[object].volume = volume
	SetObjectPropertyValue(object, "_soundStream", StreamedSounds[object])
	return true
end)

AddFunctionExport("SetSound3DPitch", function(object, pitch)
	if object == nil then
		return false
	end

	pitch = pitch or 1.0

	if StreamedSounds[object] == nil then
		return false
	end
	StreamedSounds[object].pitch = pitch
	SetObjectPropertyValue(object, "_soundStream", StreamedSounds[object])
	return true
end)

AddFunctionExport("SetSound3DRadius", function(object, radius)
	if object == nil then
		return false
	end

	radius = radius or 2500.0

	if StreamedSounds[object] == nil then
		return false
	end

	StreamedSounds[object].radius = radius
	SetObjectPropertyValue(object, "_soundStream", StreamedSounds[object])
	return true
end)

AddFunctionExport("SetSound3DDimension", function(object, dimension)
	if object == nil or dimension == nil then
		return false
	end
	if StreamedSounds[object] == nil then
		return false
	end
	return SetObjectDimension(object, dimension)
end)

AddFunctionExport("GetSound3DDimension", function(object)
	if object == nil then
		return false
	end
	if StreamedSounds[object] == nil then
		return false
	end
	return GetObjectDimension(object)
end)

AddFunctionExport("SetSound3DLocation", function(object, x, y, z)
	if object == nil or x == nil or y == nil or z == nil then
		return false
	end
	if StreamedSounds[object] == nil then
		return false
	end
	if StreamedSounds[object].is_attached == true then
		return false -- Can't sent location of an attached sound
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

AddFunctionExport("GetSound3DLocation", function(object)
	if object == nil then
		return false
	end
	if StreamedSounds[object] == nil then
		return false
	end

	if StreamedSounds[object].is_attached == true then
		return false
	end

	local x, y, z = GetObjectLocation(object)
	return x, y, z
end)
