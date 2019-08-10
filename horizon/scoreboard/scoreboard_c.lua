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

local scoreboard
local sb_timer = 0

local function OnPackageStart()
	--local width, height = GetScreenSize()
	--ZOrder = 5 and FrameRate = 10
	scoreboard = CreateWebUI(0.0, 0.0, 0.0, 0.0, 5, 10)
	LoadWebFile(scoreboard, "http://asset/"..GetPackageName().."/scoreboard/gui/scoreboard.html")
	SetWebSize(scoreboard, 1065, 600)
	SetWebAlignment(scoreboard, 0.5, 0.5)
	SetWebAnchors(scoreboard, 0.5, 0.5, 0.5, 0.5)
	SetWebVisibility(scoreboard, WEB_HIDDEN)
end
AddEvent("OnPackageStart", OnPackageStart)

local function OnPackageStop()
	DestroyTimer(sb_timer)
	DestroyWebUI(scoreboard)
end
AddEvent("OnPackageStop", OnPackageStop)

function OnResolutionChange(width, height)
	AddPlayerChat("Resolution changed to "..width.."x"..height)
	--SetWebSize(scoreboard, width / 1.4, height / 1.4)
end
AddEvent("OnResolutionChange", OnResolutionChange)

local function OnKeyPress(key)
	if key == "Tab" then
		if IsValidTimer(sb_timer) then
			DestroyTimer(sb_timer)
		end
		sb_timer = CreateTimer(UpdateScoreboardData, 1500)
		UpdateScoreboardData()
		SetWebVisibility(scoreboard, WEB_VISIBLE)
	end
end
AddEvent("OnKeyPress", OnKeyPress)

local function OnKeyRelease(key)
	if key == "Tab" then
		DestroyTimer(sb_timer)
		SetWebVisibility(scoreboard, WEB_HIDDEN)
	end
end
AddEvent("OnKeyRelease", OnKeyRelease)

function UpdateScoreboardData()
	CallRemoteEvent("scoreboard:update")
end

function OnGetScoreboardData(servername, count, maxplayers, players)
	ExecuteWebJS(scoreboard, "SetServerName('"..servername.."');")
	ExecuteWebJS(scoreboard, "SetPlayerCount("..count..", "..maxplayers..");")
	ExecuteWebJS(scoreboard, "RemovePlayers();")

	for k, v in ipairs(players) do
		if v[4] == 0 then
			v[4] = ""
		else
			v[4] = "$"..v[4]
		end
		ExecuteWebJS(scoreboard, "AddPlayer("..k..", '"..v[1].."', "..v[2]..", "..v[3]..", '"..v[4].."', "..v[5]..");")
	end
end
AddRemoteEvent("scoreboard:update", OnGetScoreboardData)
