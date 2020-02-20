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

	AddPlayerChat(player, '<span style="bold" size="14">============================</>')
	AddPlayerChat(player, '<span style="bold" size="14">Welcome to the map editor script.</>')
	AddPlayerChat(player, 'Press the <span color="#f4f142ff" style="bold" size="14">M</> key to start selecting a location with your mouse. Then choose an object from the object list.')
	AddPlayerChat(player, 'Remove spawned objects with the <span color="#f4f142ff" style="bold" size="14">Delete</> key.')
	AddPlayerChat(player, '<span color="#f4f142ff" style="bold" size="13">CTRL+W</> Duplicate selected objects')
	AddPlayerChat(player, '<span color="#f4f142ff" style="bold" size="13">Left Alt</> Switch between transform modes (move/rotate/scale)')
	AddPlayerChat(player, '<span color="#f4f142ff" style="bold" size="13">/loadmap</> To load maps saved as .ini files')
	AddPlayerChat(player, '<span style="bold" size="14">============================</>')
end
AddEvent("OnPlayerJoin", OnPlayerJoin)

function OnPlayerQuit(player)
	-- Cleanup player spawned objects
	for k, v in pairs(EditorObjects[player]) do
		DestroyObject(k)
	end

	EditorObjects[player] = nil
end
AddEvent("OnPlayerQuit", OnPlayerQuit)

function Server_EditorSpawnObject(player, modelid, x, y, z, rx, ry, rz)
	
	-- Rotation is optional
	rx = rx or 0.0
	ry = ry or 0.0
	rz = rz or 0.0

	local object = CreateMapEditorObject(player, modelid, x, y, z, rx, ry, rz, 1.0, 1.0, 1.0)

	AddPlayerChat(player, '<span style="italic" size="11">Object spawned: '..object..'</>')
end
AddRemoteEvent("Server_EditorSpawnObject", Server_EditorSpawnObject)

function Server_EditorDeleteObject(player, object)
	if EditorObjects[player][object] == nil then
		return
	end

	DestroyObject(object)

	EditorObjects[player][object] = nil

	AddPlayerChat(player, '<span style="italic" size="11">Object deleted</>')
end
AddRemoteEvent("Server_EditorDeleteObject", Server_EditorDeleteObject)

function Server_EditorExport(player, MapName)

	local counter = 0
	for _, _ in pairs(EditorObjects[player]) do
		counter = counter + 1
	end

	if counter == 0 then
		return AddPlayerChat(player, "No objects to export")
	end

	MapName = MapName or "Unnamed"

	MapName:gsub("%s+", "") -- Remove spaces

	ExportMapAsLua(player, MapName)
	ExportMapAsIni(player, MapName)
end
AddRemoteEvent("Server_EditorExport", Server_EditorExport)

function Server_EditorUpdateObject(player, object, x, y, z, rx, ry, rz, sx, sy, sz)
	if EditorObjects[player][object] == nil then
		return
	end

	if IsValidObject(object) then
		SetObjectLocation(object, x, y, z)
		SetObjectRotation(object, rx, ry, rz)

		if sx ~= nil and sx ~= 0.0 and sy ~= nil and sy ~= 0.0 and sz ~= nil and sz ~= 0.0 then
			SetObjectScale(object, sx, sy, sz)
		end

		print(GetPlayerName(player).." updated "..object)
	end
end
AddRemoteEvent("Server_EditorUpdateObject", Server_EditorUpdateObject)

function CreateMapEditorObject(player, modelid, x, y, z, rx, ry, rz, sx, sy, sz)

	local object = CreateObject(modelid, x, y, z, rx, ry, rz, sx, sy, sz)

	if object ~= false then
		SetObjectPropertyValue(object, "isPartOfMapEditor", true)
		SetObjectPropertyValue(object, "createdSteamId", GetPlayerSteamId(player), false)
		SetObjectPropertyValue(object, "createdPlayerName", GetPlayerName(player))
		SetObjectPropertyValue(object, "createdTime", os.time(os.date("!*t")), false)
		SetObjectPropertyValue(object, "createdTimeFormat", os.date('%Y-%m-%d %H:%M:%S', os.time(os.date("!*t"))))

		EditorObjects[player][object] = true
	end

	return object
end

function ExportMapAsLua(player, MapName)
	local FileName = "map_"..MapName.."_"..os.date("%H_%M_%a_%b")..".lua"
	
	local ObjectCount = 0
	local MapFile = io.open(FileName, "w")
	for k, _ in pairs(EditorObjects[player]) do
		local model = GetObjectModel(k)
		local x, y, z = GetObjectLocation(k)
		local rx, ry, rz = GetObjectRotation(k)
		local sx, sy, sz = GetObjectScale(k)

		local isRotSet = true
		if rx == 0.0 and ry == 0.0 and rz == 0.0 then
			isRotSet = false
		end

		local isScaleSet = true
		if sx == 1.0 and sy == 1.0 and sz == 1.0 then
			isScaleSet = false
		end
		
		if not isRotSet and not isScaleSet then
			MapFile:write("CreateObject("..model..", "..x..", "..y..", "..z..")", "\n")
		elseif isRotSet and not isScaleSet then
			MapFile:write("CreateObject("..model..", "..x..", "..y..", "..z..", "..rx..", "..ry..", "..rz..")", "\n")
		else
			MapFile:write("CreateObject("..model..", "..x..", "..y..", "..z..", "..rx..", "..ry..", "..rz..", "..sx..", "..sy..", "..sz..")", "\n")
		end

		ObjectCount = ObjectCount + 1
	end
	io.close(MapFile)

	AddPlayerChat(player, "Map with "..ObjectCount.." objects saved to "..FileName)
end

function ExportMapAsIni(player, MapName)
	if _G["ini_open"] == nil then
		return AddPlayerChat(player, "Can't export map as ini as ini-plugin is missing")
	end

	local FileName = "map_"..MapName.."_"..os.date("%H_%M_%a_%b")..".ini"

	local ini = ini_open(FileName)

	local ObjectCount = 0
	for k, _ in pairs(EditorObjects[player]) do
		ObjectCount = ObjectCount + 1
	end

	ini_write(ini, "info", "version", 1)
	ini_write(ini, "info", "numobjects", ObjectCount)
	ini_write(ini, "info", "createdbySteamId", GetPlayerSteamId(player))
	ini_write(ini, "info", "createdbyName", GetPlayerName(player))
	ini_write(ini, "info", "savedtime", os.time(os.date("!*t")))

	ObjectCount = 1
	for k, _ in pairs(EditorObjects[player]) do
		local model = GetObjectModel(k)
		local x, y, z = GetObjectLocation(k)
		local rx, ry, rz = GetObjectRotation(k)
		local sx, sy, sz = GetObjectScale(k)

		ini_write(ini, "objects", "model_"..ObjectCount, model)
		ini_write(ini, "objects", "x_"..ObjectCount, x)
		ini_write(ini, "objects", "y_"..ObjectCount, y)
		ini_write(ini, "objects", "z_"..ObjectCount, z)
		ini_write(ini, "objects", "rx_"..ObjectCount, rx)
		ini_write(ini, "objects", "ry_"..ObjectCount, ry)
		ini_write(ini, "objects", "rz_"..ObjectCount, rz)
		ini_write(ini, "objects", "sx_"..ObjectCount, sx)
		ini_write(ini, "objects", "sy_"..ObjectCount, sy)
		ini_write(ini, "objects", "sz_"..ObjectCount, sz)

		ObjectCount = ObjectCount + 1
	end
	ini_close(ini)

	AddPlayerChat(player, "Map with "..(ObjectCount-1).." objects saved to "..FileName)
end

function LoadMapFromIni(player, FileName)
	if _G["ini_open"] == nil then
		return AddPlayerChat(player, "Can't load map from ini as ini-plugin is missing")
	end

	if not file_exists(FileName) then
		return AddPlayerChat(player, "Map ini file does not exist "..FileName)
	end

	local ini = ini_open(FileName)
	local numobjects = math.tointeger(ini_read(ini, "info", "numobjects"))
	local createdbySteamId = ini_read(ini, "info", "createdbySteamId")
	local createdbyName = ini_read(ini, "info", "createdbyName")

	local ObjectsLoaded = 0
	for i=1, numobjects do
		local modelid = math.tointeger(ini_read(ini, "objects", "model_"..i))
		local x = tonumber(ini_read(ini, "objects", "x_"..i))
		local y = tonumber(ini_read(ini, "objects", "y_"..i))
		local z = tonumber(ini_read(ini, "objects", "z_"..i))
		local rx = tonumber(ini_read(ini, "objects", "rx_"..i))
		local ry = tonumber(ini_read(ini, "objects", "ry_"..i))
		local rz = tonumber(ini_read(ini, "objects", "rz_"..i))
		local sx = tonumber(ini_read(ini, "objects", "sx_"..i))
		local sy = tonumber(ini_read(ini, "objects", "sy_"..i))
		local sz = tonumber(ini_read(ini, "objects", "sz_"..i))

		if CreateMapEditorObject(player, modelid, x, y, z, rx, ry, rz, sx, sy, sz) ~= false then
			ObjectsLoaded = ObjectsLoaded + 1
		end
	end
	ini_close(ini)

	AddPlayerChat(player, '<span style="bold" size="14">Map objects loaded '..ObjectsLoaded..' from '..FileName..'</>')
	AddPlayerChat(player, '<span style="bold" size="14">Map created by '..createdbyName..'</>')
end

function file_exists(filename)
    local file = io.open(filename, "r")
    if file then
        file:close()
        return true
    end
    return false
end

function cmd_objects(player)
	CallRemoteEvent(player, "ToggleMapEditorUI")
end
AddCommand("objects", cmd_objects)
AddCommand("mapeditor", cmd_objects)

function cmd_clearmap(player)
	-- Cleanup player spawned objects
	for k, v in pairs(EditorObjects[player]) do
		DestroyObject(k)
	end

	EditorObjects[player] = nil
	EditorObjects[player] = { }

	AddPlayerChat(player, '<span color="#ff0000">Map cleared!</>')
end
AddCommand("clearmap", cmd_clearmap)

function cmd_loadmap(player, FileName)
	if (FileName == nil) then
		return AddPlayerChat(player, "Usage: /loadmap <FileName>")
	end

	LoadMapFromIni(player, FileName)
end
AddCommand("loadmap", cmd_loadmap)
