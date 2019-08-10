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

local LastSoundPlayed = 0
local TextRaceInfo = 0
local UpdateTimer = 0
local CurrentCheckpoint = 0
local MaxCheckpoints = 0
local CurrentPosition = 0
local MaxRacers = 0
local RaceTime = 0
local RaceStartTime = 0

function PlayAudioFile2(file)
	local FileName = "client/"..file

	--AddPlayerChat(FileName)

	--DestroySound(LastSoundPlayed)

	LastSoundPlayed = CreateSound(FileName)
	--SetSoundVolume(LastSoundPlayed, 1.0)
	--SetSoundPitch(LastSoundPlayed, 1.5)
end
AddRemoteEvent("PlayAudioFile2", PlayAudioFile2)

function RaceCountdown(time)
	AddPlayerChat("Race countdown: "..time)

	local guiid = CreateTextBox(0.0, -200.0, '<span size="80" style="italic" color="#42f448">GO GO GO!</>', "center")
	SetTextBoxAnchors(guiid, 0.5, 0.5, 0.5, 0.5)
	SetTextBoxAlignment(guiid, 0.5, 0.5)

	if time == 3 then
		PlayAudioFile2("3.mp3")
		SetTextBoxText(guiid, '<span size="46" style="bold" color="#fc0000">3</>')
	elseif time == 2 then
		PlayAudioFile2("2.mp3")
		SetTextBoxText(guiid, '<span size="52" style="bold" color="#fc4300">2</>')
	elseif time == 1 then
		PlayAudioFile2("1.mp3")
		SetTextBoxText(guiid, '<span size="58" style="bold" color="#fcc900">1</>')
	elseif time == 0 then
		PlayAudioFile2("go.mp3")
		PlayAudioFile2("MLG_Horn.mp3")
	end

	Delay(900, function(guiid)
		DestroyTextBox(guiid)
	end, guiid)
end
AddRemoteEvent("RaceCountdown", RaceCountdown)

function OnRaceJoin(world_time)
	-- Disable player controls
	SetIgnoreMoveInput(true)
	SetIgnoreLookInput(true)

	if world_time and world_time ~= -1 then
		SetTime(world_time)
	end
end
AddRemoteEvent("OnRaceJoin", OnRaceJoin)

function OnRaceStart(TimeForRaceSeconds)
	AddPlayerChat('<span color="#88eb00" size="18">The race starts now!</>')

	-- Enable player controls
	SetIgnoreMoveInput(false)
	SetIgnoreLookInput(false)

	TextRaceInfo = CreateTextBox(50.0, 100.0, "-")
	SetTextBoxAnchors(TextRaceInfo, 0.0, 0.5, 0.0, 0.5)
	SetTextBoxAlignment(TextRaceInfo, 0.0, 0.5)
	RaceTime = TimeForRaceSeconds
	RaceStartTime = GetTimeSeconds()

	UpdateTimer = CreateTimer(function()
		SetRaceTextInfo(CurrentCheckpoint, MaxCheckpoints, CurrentPosition, MaxRacers)
	end, 50)
end
AddRemoteEvent("OnRaceStart", OnRaceStart)

function OnRaceExit()
	-- Enable player controls
	SetIgnoreMoveInput(false)
	SetIgnoreLookInput(false)

	-- Destroy the race info text box
	DestroyTextBox(TextRaceInfo)
	TextRaceInfo = 0

	-- Destroy timer
	DestroyTimer(UpdateTimer)
	UpdateTimer = 0

	-- Reset other variables
	CurrentCheckpoint = 0
	MaxCheckpoints = 0
	CurrentPosition = 0
	MaxRacers = 0
	RaceTime = 0
end
AddRemoteEvent("OnRaceExit", OnRaceExit)

function ServerUpdateRaceData(checkpoint, max_checkpoints, position, max_racers)
	CurrentCheckpoint = checkpoint
	MaxCheckpoints = max_checkpoints
	CurrentPosition = position
	MaxRacers = max_racers
end
AddRemoteEvent("ServerUpdateRaceData", ServerUpdateRaceData)

function SetRaceTextInfo(check, max_checks, pos, max_racers)
	if TextRaceInfo ~= 0 and IsPlayerInVehicle() then
		local speed = math.tointeger(math.floor(GetVehicleForwardSpeed(GetPlayerVehicle())))
		local gear = GetVehicleGear(GetPlayerVehicle())
		local rpm = math.floor(GetVehicleEngineRPM(GetPlayerVehicle()))
		local health = math.floor(GetVehicleHealth(GetPlayerVehicle()))

		local time_left = RaceTime - (GetTimeSeconds() - RaceStartTime)

		SetTextBoxText(TextRaceInfo, '<span size="30" style="bold" color="#fc4300">Checkpoint: '..check..'/'..max_checks..'</>\
<span size="30" style="bold" color="#fc4300">Time: '..FormatTime(time_left)..'</> \
<span size="30" style="bold" color="#fc4300">Position: '..pos..'/'..max_racers..'</>\
<span size="30" style="bold" color="#fc4300">Speed: '..speed..' km/h</>\
<span size="30" style="bold" color="#fc4300">Gear: '..gear..'</>\
<span size="30" style="bold" color="#fc4300">RPM: '..rpm..'</>\
<span size="30" style="bold" color="#fc4300">Health: '..health..'</>')
	end
end

function FormatTime(time)
	local minutes = string.format("%02d", math.floor(time / 60.0))
	local seconds = string.format("%02d", math.floor(time - (minutes * 60.0)))
	local milliseconds = string.format("%03d", math.floor((time - (minutes * 60.0) - seconds) * 1000))
	return minutes..':'..seconds..':'..milliseconds
end
