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

local StreamedUIs = { }

AddEvent("OnPackageStop", function()

	for k, v in pairs(StreamedUIs) do
		DestroyObject(k)
	end

	StreamedUIs = nil

end)

function CreateWebUI(is_remote, x, y, z, rx, ry, rz, width, height, frame_rate, radius)
	frame_rate = frame_rate or 30
	radius = radius or 10000.0

	-- Create a dummy object that will help us streaming the WebUI
	local object = CreateObject(1, x, y, z, rx, ry, rz)
	SetObjectPropertyValue(object, "_webUIRemote", is_remote)
	SetObjectPropertyValue(object, "_webUIWidth", width)
	SetObjectPropertyValue(object, "_webUIHeight", height)
	SetObjectPropertyValue(object, "_webUIFPS", frame_rate)
	SetObjectStreamDistance(object, radius)

	StreamedUIs[object] = { }
	StreamedUIs[object].radius = radius
	StreamedUIs[object].fps = frame_rate

	return object
end

AddFunctionExport("CreateWebUI3D", function (x, y, z, rx, ry, rz, width, height, frame_rate, radius)
	return CreateWebUI(false, x, y, z, rx, ry, rz, width, height, frame_rate, radius)
end)

AddFunctionExport("CreateRemoteWebUI3D", function (x, y, z, rx, ry, rz, width, height, frame_rate, radius)
	return CreateWebUI(true, x, y, z, rx, ry, rz, width, height, frame_rate, radius)
end)

AddFunctionExport("DestroyWebUI3D", function (object)
	if StreamedUIs[object] == nil then
		return false
	end
	StreamedUIs[object] = nil
	return DestroyObject(object)
end)

AddFunctionExport("IsValidWebUI3D", function (object)
	return StreamedUIs[object] ~= nil
end)

AddFunctionExport("SetWebUI3DUrl", function (object, url)
	if StreamedUIs[object] == nil then
		return false
	end
	SetObjectPropertyValue(object, "_webUIURL", url)
	return true
end)

AddFunctionExport("SetWebUI3DDimension", function (object, dimension)
	if StreamedUIs[object] == nil then
		return false
	end
	SetObjectDimension(object, dimension)
	return true
end)

AddFunctionExport("GetWebUI3DDimension", function (object)
	if StreamedUIs[object] == nil then
		return false
	end
	return GetObjectDimension(object)
end)

AddFunctionExport("SetWebUI3DLocation", function (object, x, y, z)
	if StreamedUIs[object] == nil then
		return false
	end

	-- We need to notify the client about the loction change with a remote event.
	-- Because SetObjectLocation does not trigger a stream event on the client if the location is within the stream radius.
	for _, v in pairs(GetAllPlayers()) do
		if IsObjectStreamedIn(v, object) then
			CallRemoteEvent(v, "SetStreamedWebUI3DLocation", object, x, y, z)
		end
	end

	-- Will trigger client stream in/out events if necessary
	SetObjectLocation(object, x, y, z)
	return true
end)

AddFunctionExport("GetWebUI3DLocation", function (object)
	if StreamedUIs[object] == nil then
		return false
	end

	local x, y, z = GetObjectLocation(object)
	return x, y, z
end)
