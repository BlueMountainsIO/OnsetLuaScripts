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

local EditorObjects = { }

function OnPlayerJoin(player)
	SetPlayerSpawnLocation(player, 125773.000000, 80246.000000, 1645.000000, 90.0)

	EditorObjects[player] = { }

	AddPlayerChatAll('<span color="#eeeeeeaa">'..GetPlayerName(player)..' joined the server</>')
	AddPlayerChat(player, "Welcome to the map editor script")
	AddPlayerChat(player, 'Press the <span color="#f4f142ff" style="bold" size="14">M</> key to start selecting a location with your mouse. Then choose an object from the object list.')
	AddPlayerChat(player, 'Remove spawned objects with the <span color="#f4f142ff" style="bold" size="14">Delete</> key.')
end
AddEvent("OnPlayerJoin", OnPlayerJoin)

function OnPlayerQuit(player)
	-- Cleanup player spawned objects
	for _, v in pairs(EditorObjects[player]) do
		DestroyObject(v)
	end

	EditorObjects[player] = nil
end
AddEvent("OnPlayerQuit", OnPlayerQuit)

function Server_EditorSpawnObject(player, modelid, x, y, z, rx, ry, rz)
	
	-- Rotation is optional
	rx = rx or 0.0
	ry = ry or 0.0
	rz = rz or 0.0

	local object = CreateObject(modelid, x, y, z, rx, ry, rz)
	if object ~= false then
		AddPlayerChat(player, "Object spawned: "..object)

		table.insert(EditorObjects[player], object)
	end
end
AddRemoteEvent("Server_EditorSpawnObject", Server_EditorSpawnObject)

function Server_EditorDeleteObject(player, object)
	if EditorObjects[player][object] == nil then
		return
	end

	DestroyObject(object)

	EditorObjects[player][object] = nil

	AddPlayerChat(player, "Object deleted.")
end
AddRemoteEvent("Server_EditorDeleteObject", Server_EditorDeleteObject)

function Server_EditorExport(player)
	if #EditorObjects[player] == 0 then
		return AddPlayerChat(player, "No objects to export")
	end

	local FileName = "map_"..os.date("%H:%M_%a_%b")..".lua"
	
	local MapFile = io.open(FileName, "w")
	for _, v in pairs(EditorObjects[player]) do
		local model = GetObjectModel(v)
		local x, y, z = GetObjectLocation(v)
		local rx, ry, rz = GetObjectRotation(v)

		MapFile:write("CreateObject("..model..", "..x..", "..y..", "..z..", "..rx..", "..ry..", "..rz..")", "\n")
	end
	io.close(MapFile)

	AddPlayerChat(player, "Map saved to "..FileName)
end
AddRemoteEvent("Server_EditorExport", Server_EditorExport)

function Server_EditorUpdateObject(player, object, x, y, z, rx, ry, rz)
	if EditorObjects[player][object] == nil then
		return
	end

	if IsValidObject(object) then
		SetObjectLocation(object, x, y, z)
		SetObjectRotation(object, rx, ry, rz)

		print(GetPlayerName(player).." updated "..object)
	end
end
AddRemoteEvent("Server_EditorUpdateObject", Server_EditorUpdateObject)
