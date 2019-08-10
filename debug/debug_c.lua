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

local webui = 0
local UpdateClientTimer = 0
local UpdateServerTimer = 0
local DebugEnabled = false

local function OnWebLoadComplete(webid)
	--AddPlayerChat("OnWebLoadComplete called ID: "..webid)
end
AddEvent("OnWebLoadComplete", OnWebLoadComplete)

function ToggleDebugStats()
	if DebugEnabled then
		DebugEnabled = false

		DestroyTimer(UpdateClientTimer)
		DestroyTimer(UpdateServerTimer)
		DestroyWebUI(webui)
		webui = 0
	else
		DebugEnabled = true

		local width, height = GetScreenSize()
		webui = CreateWebUI(1, height / 3.8, width, height, 0, 10)
		SetWebVisibility(webui, WEB_HITINVISIBLE)
		LoadWebFile(webui, "http://asset/"..GetPackageName().."/gui/debug.html")
		
		UpdateClientTimer = CreateTimer(UpdateClientData, 100)
		UpdateServerTimer = CreateTimer(UpdateServerData, 500)
	end
end
AddRemoteEvent("ToggleDebugStats", ToggleDebugStats)

function UpdateClientData()
	UpdateLocalInfo()
	UpdateNetworkStats()
	UpdateClientPools()
end

function UpdateServerData()
	CallRemoteEvent("UpdateServerData")
end

function UpdateLocalInfo()
	local x, y, z = GetPlayerLocation()
	local h = GetPlayerHeading()

	local data = "<br>LOCAL (ID: " .. GetLocalPlayer() .. ")<br>"
	data = data .. "Loc: " .. x .. ", " .. y .. ", " .. z .. ", " .. h .. "<br>"
	data = data .. "Movement: " .. GetPlayerMovementMode() .. ", " .. GetPlayerMovementSpeed() .. "<br>"

	ExecuteWebJS(webui, "SetLocalInfo('"..data.."');")
end

function UpdateNetworkStats()
	local NetStats = GetNetworkStats()
	
	local data = "<br>NET CLIENT<br>"
	data = data .. "ping: " .. GetPing() .. "ms<br>"
	data = data .. "packetLoss: " .. tostring(NetStats['packetlossTotal']) .. "%<br>"
	data = data .. "bytesSend: " .. NetStats['bytesSend'] / 1000.0 .. " KB/s<br>"
	data = data .. "bytesReceived: " .. NetStats['bytesReceived'] / 1000.0 .. " KB/s<br>"
	data = data .. "messagesResendBuff: " .. tostring(NetStats['messagesInResendBuffer']) .. "<br>"
	data = data .. "bytesResendBuff: " .. tostring(NetStats['bytesInResendBuffer']) .. "<br>"
	data = data .. "bytesResent: " .. tostring(NetStats['bytesResent']) .. "<br>"
	data = data .. "bytesResentTotal: " .. tostring(NetStats['bytesResentTotal']) .. "<br>"

	ExecuteWebJS(webui, "SetNetClient('"..data.."');")
end

function UpdateClientPools()
	local data = "<br>CLIENT SCRIPT POOLS<br>"
	data = data .. "Players: " .. GetPlayerCount() .. "<br>"
	data = data .. "Vehicles: " .. GetVehicleCount() .. "<br>"
	data = data .. "Objects: " .. tostring(GetObjectCount()) .. "<br>"
	data = data .. "NPC: " .. tostring(GetNPCCount()) .. "<br>"
	data = data .. "Pickups: " .. tostring(GetPickupCount()) .. "<br>"
	data = data .. "Text3D: " .. tostring(GetText3DCount()) .. "<br>"
	data = data .. "Lights: " .. tostring(GetLightCount()) .. "<br>"
	data = data .. "Timer: " .. tostring(GetTimerCount()) .. "<br>"
	data = data .. "WebUI: " .. tostring(GetWebUICount()) .. "<br>"
	data = data .. "Sounds: " .. tostring(GetSoundCount()) .. "<br>"

	ExecuteWebJS(webui, "SetClientPools('"..data.."');")
end

function OnGetUpdateServerPools(PoolsTable, NetStats, AvgPing)
	local data = "<br>SERVER SCRIPT POOLS<br>"
	data = data .. "Players: " .. PoolsTable[1] .. "<br>"
	data = data .. "Vehicles: " .. PoolsTable[2] .. "<br>"
	data = data .. "Objects: " .. PoolsTable[3] .. "<br>"
	data = data .. "NPC: " .. PoolsTable[4] .. "<br>"
	data = data .. "Pickups: " .. PoolsTable[5] .. "<br>"
	data = data .. "Text3D: " .. PoolsTable[6] .. "<br>"
	data = data .. "Lights: " .. PoolsTable[7] .. "<br>"
	data = data .. "Timer: " .. PoolsTable[8] .. "<br>"

	ExecuteWebJS(webui, "SetServerPools('"..data.."');")
	
	local data = "<br>NET SERVER<br>"
	data = data .. "avgPing: " .. AvgPing .. "ms<br>"
	data = data .. "packetLoss: " .. NetStats['packetlossTotal'] .. "%<br>"
	data = data .. "bytesSend: " .. NetStats['bytesSend'] / 1000.0 .. " KB/s<br>"
	data = data .. "bytesReceived: " .. NetStats['bytesReceived'] / 1000.0 .. " KB/s<br>"
	data = data .. "messagesResendBuff: " .. tostring(NetStats['messagesInResendBuffer']) .. "<br>"
	data = data .. "bytesResendBuff: " .. tostring(NetStats['bytesInResendBuffer']) .. "<br>"
	data = data .. "bytesResent: " .. tostring(NetStats['bytesResent']) .. "<br>"
	data = data .. "bytesResentTotal: " .. tostring(NetStats['bytesResentTotal']) .. "<br>"

	ExecuteWebJS(webui, "SetNetServer('"..data.."');")
end
AddRemoteEvent("OnGetUpdateServerPools", OnGetUpdateServerPools)

function OnPlayerStreamIn(player)
	if not DebugEnabled then
		return
	end

	AddPlayerChat("OnPlayerStreamIn("..player..")")
end
AddEvent("OnPlayerStreamIn", OnPlayerStreamIn)

function OnPlayerStreamOut(player)
	if not DebugEnabled then
		return
	end
	
	AddPlayerChat("OnPlayerStreamOut("..player..")")
end
AddEvent("OnPlayerStreamOut", OnPlayerStreamOut)

--[[
	If a script error occurs display it in the chat.
	This only works if the game was started with "-dev" switch
]]--
function OnScriptError(message)
	AddPlayerChat('<span color="#ff0000bb" style="bold" size="10">'..message..'</>')
end
AddEvent("OnScriptError", OnScriptError)
