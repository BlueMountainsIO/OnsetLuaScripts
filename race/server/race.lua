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

pprint = require('packages/horizon/server/vendor/pprint')

-- Define race states
local RACE_STATE_INACTIVE = 0
local RACE_STATE_STARTING = 1
local RACE_STATE_ACTIVE = 2

-- Define settings
local MAX_RACERS = 4
local DEFAULT_RACE_DIMENSION = 10000
local DEFAULT_RACE_COUNTDOWN = 15
local DEFAULT_RACE_TIME = 121 --seconds
local DEFAULT_LICENSE_PLATE = "~RACER~"
local DEFAULT_PICKUP_OBJECT_MODEL = 340
local RACE_CONFIG = "race_config.ini"
local NUM_RACES = 0 -- The maximum races available, refers to the total amount of race files = max races

-- Race variables
local RaceState = RACE_STATE_INACTIVE
local Racers = { }
local RaceSlots = { }
local RaceTimer = 0
local RaceCountdown = 0
local RaceTotalCheckpoints = 0
local RaceFinishCounter = 0
local RaceTimeTotal = 0
local RaceStartTime = 0
local CurrentRaceId = 0 -- The current race identifier, refers to a race file
local NextRaceIdOverride = 0
local RacePositions = nil -- Holding cached player positions

local RaceInfo = { }
local RaceStartLocation = { }
local RaceCheckpoints = { }

function cmd_race(player)
	if RaceState == RACE_STATE_ACTIVE then
		return AddPlayerChat(player, "The race already started!")
	end

	if RaceState == RACE_STATE_INACTIVE then
		StartNewRace()
	end

	if RaceState == RACE_STATE_STARTING then
		if Racers[player] ~= nil then
			return AddPlayerChat(player, "You already joined this race.")
		end

		if GetNumRacers() == MAX_RACERS then
			return AddPlayerChat(player, "Maximum number of racers reached, try later!")
		end

		JoinPlayerRace(player)
	end
end
AddCommand("race", cmd_race)

function cmd_exitrace(player)
	if Racers[player] == nil then
		return AddPlayerChat(player, "You are not participating in any race.")
	end

	ExitPlayerRace(player)
end
AddCommand("exitrace", cmd_exitrace)

function cmd_nextrace(player, next_raceid)
	if (next_raceid == nil) then
		return AddPlayerChat(player, "Usage: /nextrace <next_raceid>")
	end

	next_raceid = math.tointeger(next_raceid)

	if SetNextRaceOverride(next_raceid) then
		AddPlayerChat(player, "The next race will be id #"..next_raceid.." "..RaceInfo[next_raceid].name)
	else
		AddPlayerChat(player, "Race id #"..next_raceid.." is invalid/does not exist")
	end
end
AddCommand("nextrace", cmd_nextrace)

function cmd_rstartpoint(player, id)
	local x, y, z = GetPlayerLocation(player)
	local h = GetPlayerHeading(player)

	print("start_"..id.."_x="..tostring(x))
	print("start_"..id.."_y="..tostring(y))
	print("start_"..id.."_z="..tostring(z))
	print("start_"..id.."_h="..tostring(h))
end
AddCommand("rstartpoint", cmd_rstartpoint)

function cmd_rcheckpoint(player, id)
	local x, y, z = GetPlayerLocation(player)

	print("checkpoint_"..id.."_x="..tostring(x))
	print("checkpoint_"..id.."_y="..tostring(y))
	print("checkpoint_"..id.."_z="..tostring(z))
end
AddCommand("rcheckpoint", cmd_rcheckpoint)

function OnPackageStart()
	-- Load initial race config
	LoadRaceConfig()

	-- Load races and override global how many actually loaded
	NUM_RACES = LoadRacesFromConfig()
	print("Loaded "..NUM_RACES.." races from config")

	if NUM_RACES > 0 then
		-- Reset once to get an initial state to work with
		ResetRace()
	end
end
AddEvent("OnPackageStart", OnPackageStart)

function OnPlayerJoin(player)
	Delay(2500, function(player)
		if RaceState ~= RACE_STATE_ACTIVE then
			AddPlayerChat(player, 'Have fun in <span color="#fcc900" size="17">/race</>')
		end
	end, player)
end
AddEvent("OnPlayerJoin", OnPlayerJoin)

function OnPlayerDeath(player, instigator)
	-- If a player happens to die remove them from the race
	if Racers[player] ~= nil then
		ExitPlayerRace(player)
	end
end
AddEvent("OnPlayerDeath", OnPlayerDeath)

function OnPlayerQuit(player)
	-- If a player leaves the server remove them from the race
	if Racers[player] ~= nil then
		ExitPlayerRace(player)
	end
end
AddEvent("OnPlayerQuit", OnPlayerQuit)

function StartNewRace()
	if not (NUM_RACES > 0) then
		return
	end

	if RaceState == RACE_STATE_INACTIVE and IsValidRaceId(CurrentRaceId) then
		RaceState = RACE_STATE_STARTING

		AddPlayerChatAll("The race "..RaceInfo[CurrentRaceId].name.." has started, join with /race")

		RaceTotalCheckpoints = #RaceCheckpoints[CurrentRaceId]
		RaceCountdown = RaceInfo[CurrentRaceId].countdown
		RaceTimeTotal = RaceInfo[CurrentRaceId].time

		RaceTimer = CreateTimer(RaceWorker, 1000)
	end
end

function StopRace()
	DoForAllRacers(function(player)
		ExitPlayerRace(player)
	end)

	RaceState = RACE_STATE_INACTIVE

	ResetRace()
end

function ResetRace()
	SelectNextRace()
	
	for i=1,MAX_RACERS do
		RaceSlots[i] = 0
	end

	if RaceTimer ~= 0 then
		DestroyTimer(RaceTimer)
		RaceTimer = 0
	end

	RaceCountdown = 0
	RaceTotalCheckpoints = 0
	RaceFinishCounter = 0
	RaceTimeTotal = 0
	RaceStartTime = 0
end

function SelectNextRace()
	-- If there is a specific race id reserved use that, else randomly select one
	if NextRaceIdOverride ~= 0 then
		CurrentRaceId = NextRaceIdOverride
		NextRaceIdOverride = 0
	else
		local bFound = false
		while not bFound do
			CurrentRaceId = Random(1, NUM_RACES)
			if RaceInfo[CurrentRaceId].enabled == true then
				bFound = true
			end
		end
	end
end

function SetNextRaceOverride(next_raceid)
	next_raceid = math.tointeger(next_raceid)

	if not IsValidRaceId(next_raceid) then
		return false
	end

	if RaceInfo[next_raceid].enabled == false then
		return false
	end

	NextRaceIdOverride = next_raceid

	-- If there is not race right now then switch to it immediately
	if RaceState == RACE_STATE_INACTIVE then
		SelectNextRace()
	end
	return true
end

function LoadRaceConfig()
	if RaceState ~= RACE_STATE_INACTIVE then
		return 0
	end

	local config_file = "packages/"..GetPackageName().."/server/race_files/" .. RACE_CONFIG
	if not file_exists(config_file) then
		print(RACE_CONFIG .. " does not exist")
		return
	end

	local ini = ini_open(config_file)

	NUM_RACES = math.tointeger(ini_read(ini, "config", "num_races"))
	DEFAULT_RACE_TIME = math.tointeger(ini_read(ini, "config", "race_time"))
	DEFAULT_RACE_COUNTDOWN = math.tointeger(ini_read(ini, "config", "countdown_seconds"))
	DEFAULT_RACE_DIMENSION = math.tointeger(ini_read(ini, "config", "race_dimension"))
	DEFAULT_LICENSE_PLATE = ini_read(ini, "config", "license_plate")
	DEFAULT_PICKUP_OBJECT_MODEL = math.tointeger(ini_read(ini, "config", "pickup_object_model"))

	ini_close(ini)
end

function LoadRacesFromConfig()
	if RaceState ~= RACE_STATE_INACTIVE then
		return 0
	end
	
	if NUM_RACES < 1 then
		return 0
	end

	local loaded_races = 0

	for i=1,NUM_RACES do
		local race_file = "packages/"..GetPackageName().."/server/race_files/race_"..i..".ini"

		if not file_exists(race_file) then
			print("Race file race_"..i..".ini does not exist")
			goto continue
		end

		local ini = ini_open(race_file)

		RaceInfo[i] =  {}
		RaceInfo[i].enabled = ini_read(ini, "config", "enabled")
		RaceInfo[i].name = ini_read(ini, "config", "name")
		RaceInfo[i].vehicle_model = math.tointeger(ini_read(ini, "config", "vehicle_model"))
		RaceInfo[i].time = math.tointeger(ini_read(ini, "config", "time_seconds"))
		RaceInfo[i].countdown = math.tointeger(ini_read(ini, "config", "countdown_seconds"))
		RaceInfo[i].dimension = math.tointeger(ini_read(ini, "config", "race_dimension"))
		RaceInfo[i].world_time = tonumber(ini_read(ini, "config", "world_time"))
		RaceInfo[i].license_plate = ini_read(ini, "config", "license_plate")
		RaceInfo[i].pickup_object_model = math.tointeger(ini_read(ini, "config", "pickup_object_model"))

		if RaceInfo[i].enabled == nil or RaceInfo[i].enabled == "true" then
			RaceInfo[i].enabled = true
		else
			RaceInfo[i].enabled = false
		end

		if RaceInfo[i].name == nil then
			RaceInfo[i].name = "Unamed race"
		end
		if RaceInfo[i].vehicle_model == nil or not IsValidVehicleModel(RaceInfo[i].vehicle_model) then
			RaceInfo[i].vehicle_model = 1
		end
		if RaceInfo[i].time == nil or RaceInfo[i].time == -1 then
			RaceInfo[i].time = DEFAULT_RACE_TIME
		end
		if RaceInfo[i].countdown == nil or RaceInfo[i].countdown == -1 then
			RaceInfo[i].countdown = DEFAULT_RACE_COUNTDOWN
		end
		if RaceInfo[i].dimension == nil or RaceInfo[i].dimension == -1 then
			RaceInfo[i].dimension = DEFAULT_RACE_DIMENSION
		end
		if RaceInfo[i].world_time == nil then
			RaceInfo[i].world_time = -1
		end
		if RaceInfo[i].license_plate == nil then
			RaceInfo[i].license_plate = DEFAULT_LICENSE_PLATE
		end
		if RaceInfo[i].pickup_object_model == nil or RaceInfo[i].pickup_object_model == -1  then
			RaceInfo[i].pickup_object_model = DEFAULT_PICKUP_OBJECT_MODEL
		end

		local num_startpoints = tonumber(ini_read(ini, "config", "num_startpoints"))
		local num_checkpoints = tonumber(ini_read(ini, "config", "num_checkpoints"))

		RaceStartLocation[i] = {}

		for c=1,num_startpoints do
			RaceStartLocation[i][c] = {}
			RaceStartLocation[i][c][1] = tonumber(ini_read(ini, "startpoints", "start_"..c.."_x"))
			RaceStartLocation[i][c][2] = tonumber(ini_read(ini, "startpoints", "start_"..c.."_y"))
			RaceStartLocation[i][c][3] = tonumber(ini_read(ini, "startpoints", "start_"..c.."_z"))
			RaceStartLocation[i][c][4] = tonumber(ini_read(ini, "startpoints", "start_"..c.."_h"))
		end

		RaceCheckpoints[i] = {}

		for c=1,num_checkpoints do
			RaceCheckpoints[i][c] = {}
			RaceCheckpoints[i][c][1] = tonumber(ini_read(ini, "checkpoints", "checkpoint_"..c.."_x"))
			RaceCheckpoints[i][c][2] = tonumber(ini_read(ini, "checkpoints", "checkpoint_"..c.."_y"))
			RaceCheckpoints[i][c][3] = tonumber(ini_read(ini, "checkpoints", "checkpoint_"..c.."_z"))
		end

		loaded_races = loaded_races + 1

		ini_close(ini)

		::continue::
	end

	return loaded_races
end

function RaceWorker()
	if RaceState == RACE_STATE_STARTING then
		if GetNumRacers() == 0 then
			StopRace()
			return
		end

		RaceCountdown = RaceCountdown - 1

		if RaceCountdown == 0 then
			RaceState = RACE_STATE_ACTIVE
			RaceStartTime = GetTimeSeconds()

			DoForAllRacers(function(player)
				CallRemoteEvent(player, "RaceCountdown", 0)
				CallRemoteEvent(player, "OnRaceStart", RaceTimeTotal)
			end)			
		else
			if RaceCountdown <= 3 then
				DoForAllRacers(function(player)
					CallRemoteEvent(player, "RaceCountdown", RaceCountdown)
				end)
			end
		end
	elseif RaceState == RACE_STATE_ACTIVE then
		if GetNumRacers() == 0 then
			StopRace()
			return
		end

		RaceCalculatePositions()

		DoForAllRacers(function(player)
			PlayerUpdateRaceData(player)
		end)

		local TimeLeft = RaceTimeTotal - (GetTimeSeconds() - RaceStartTime)
		if TimeLeft <= 0.1 then
			DoForAllRacers(function(player)
				AddPlayerChat(player, '<span color="#fcc900" size="19">Race time is up, next time hurry up!</>')
			end)

			StopRace()
			return
		end
	end
end

function JoinPlayerRace(player)
	-- Check if player is already in a race
	if Racers[player] ~= nil then
		return
	end

	-- Players can only join while race is starting
	if RaceState ~= RACE_STATE_STARTING then
		return
	end

	local Slot = GetFreeRaceSlot()
	RaceSlots[Slot] = player

	local StartLoc = RaceStartLocation[CurrentRaceId][Slot]

	SetPlayerDimension(player, RaceInfo[CurrentRaceId].dimension)

	SetPlayerLocation(player, StartLoc[1], StartLoc[2], StartLoc[3])

	Racers[player] = { }
	Racers[player].vehicle = CreateVehicle(RaceInfo[CurrentRaceId].vehicle_model, StartLoc[1], StartLoc[2], StartLoc[3], StartLoc[4])
	Racers[player].slot = Slot
	Racers[player].checkpoint = 0
	Racers[player].checkpoint_pickup = 0
	Racers[player].finished_position = 0

	SetVehicleDimension(Racers[player].vehicle, RaceInfo[CurrentRaceId].dimension)
	SetVehicleLicensePlate(Racers[player].vehicle, RaceInfo[CurrentRaceId].license_plate)
	AttachVehicleNitro(Racers[player].vehicle, true)

	SetPlayerInVehicle(player, Racers[player].vehicle, 1)

	SetCheckpointsForPlayer(player)

	CallRemoteEvent(player, "OnRaceJoin", RaceInfo[CurrentRaceId].world_time)
end

function GetNumRacers()
	local count = 0
	for i=1,MAX_RACERS do
		if RaceSlots[i] ~= 0 then
			count = count + 1
		end
	end
	return count
end

function GetFreeRaceSlot()
	for i=1,MAX_RACERS do
		if RaceSlots[i] == 0 then
			return i
		end
	end
	return 1
end

function ExitPlayerRace(player)
	if Racers[player] == nil then
		return
	end

	-- Cleanup checkpoint
	if Racers[player].checkpoint_pickup ~= 0 then
		DestroyPickup(Racers[player].checkpoint_pickup)
		Racers[player].checkpoint_pickup = 0
	end

	-- Cleanup vehicle
	DestroyVehicle(Racers[player].vehicle)

	-- Cleanup variables
	RaceSlots[Racers[player].slot] = 0
	Racers[player] = nil

	-- Reset player dimension
	SetPlayerDimension(player, 0)

	-- Client cleanup
	CallRemoteEvent(player, "OnRaceExit")
end

function SetCheckpointsForPlayer(player)
	if Racers[player] == nil then
		return
	end

	if Racers[player].checkpoint_pickup ~= 0 then
		DestroyPickup(Racers[player].checkpoint_pickup)
		Racers[player].checkpoint_pickup = 0
	end

	local NextCheckpoint = Racers[player].checkpoint + 1

	PlayerUpdateRaceData(player)

	-- Check if the last checkpoint was reached
	if NextCheckpoint > RaceTotalCheckpoints then
		return
	end

	local CheckpointLoc = RaceCheckpoints[CurrentRaceId][NextCheckpoint]

	Racers[player].checkpoint_pickup = CreatePickup(RaceInfo[CurrentRaceId].pickup_object_model, CheckpointLoc[1], CheckpointLoc[2], CheckpointLoc[3] + 1000.0)
	SetPickupVisibleForPlayers(Racers[player].checkpoint_pickup, { player })
	SetPickupDimension(Racers[player].checkpoint_pickup, RaceInfo[CurrentRaceId].dimension)

	local xy_scale = 10.0
	if NextCheckpoint == RaceTotalCheckpoints then
		-- Make the last checkpoint bigger so other vehicles cant block it
		xy_scale = 30.0
	end
	SetPickupScale(Racers[player].checkpoint_pickup, xy_scale, xy_scale, 25.0)
end

function CheckIfFinished(player)
	if Racers[player] == nil then
		return
	end

	if Racers[player].checkpoint == RaceTotalCheckpoints then
		RaceFinishCounter = RaceFinishCounter + 1

		Racers[player].finished_position = RaceFinishCounter

		local FinishTime = FormatTime(GetTimeSeconds() - RaceStartTime)
		for k,v in pairs(Racers) do
			AddPlayerChat(k, '<span color="#fcc900" size="18">'..GetPlayerName(player).." ("..player..") finished the race at position "..Racers[player].finished_position..' in '..FinishTime..'</>')
		end
		CallEvent("OnPlayerFinishRace", player, Racers[player].finished_position, FinishTime)
	end

	local bAllRacersFinished = true
	for k,v in pairs(Racers) do
		if Racers[k].finished_position == 0 then
			bAllRacersFinished = false
			break
		end
	end

	if bAllRacersFinished then
		StopRace()
	end
end

function OnPlayerPickupHit(player, pickup)
	if RaceState ~= RACE_STATE_ACTIVE then
		return
	end

	if GetPickupDimension(pickup) ~= RaceInfo[CurrentRaceId].dimension then
		return
	end

	if GetPlayerVehicle(player) == 0 then
		return
	end
	
	for k,v in pairs(Racers) do
		if Racers[k].checkpoint_pickup == pickup then
			AddPlayerChat(k, "You have hit the checkpoint")

			Racers[k].checkpoint = Racers[k].checkpoint + 1
			SetCheckpointsForPlayer(k)

			CheckIfFinished(k)

			CallRemoteEvent(k, "PlayAudioFile2", "checkpoint.wav")
			break
		end
	end
end
AddEvent("OnPlayerPickupHit", OnPlayerPickupHit)

function OnPlayerLeaveVehicle(player, vehicle, seat)
	if Racers[player] == nil then
		return
	end

	if RaceState == RACE_STATE_INACTIVE then
		return
	end

	SetPlayerInVehicle(player, vehicle, 1)
	AddPlayerChat(player, "Don't get out of your vehicle while racing :)")
end
AddEvent("OnPlayerLeaveVehicle", OnPlayerLeaveVehicle)	

function PlayerUpdateRaceData(player)
	if RaceState ~= RACE_STATE_ACTIVE then
		return
	end

	if Racers[player] == nil then
		return
	end

	-- Only update if player has not finished already
	if Racers[player].finished_position ~= 0 then
		return
	end

	CallRemoteEvent(player, "ServerUpdateRaceData", Racers[player].checkpoint, RaceTotalCheckpoints, GetPlayerRacePosition(player), GetNumRacers())
end

function RaceCalculatePositions()
	if RaceState ~= RACE_STATE_ACTIVE then
		return
	end

	RacePositions = nil
	RacePositions = {}

	for i=1, RaceTotalCheckpoints do
		RacePositions[i] = {}

		for k, v in pairs(Racers) do
			if Racers[k].checkpoint + 1 == i then
				table.insert(RacePositions[i], { player = k, dist = 0.0 } )
			end
		end
	end

	for i=1, RaceTotalCheckpoints do
		if #RacePositions[i] > 1 then
			local CheckpointLoc = RaceCheckpoints[CurrentRaceId][i]

			for k, v in ipairs(RacePositions[i]) do
				local x, y, z = GetVehicleLocation(Racers[v.player].vehicle)

				v.dist = GetDistance3D(x, y, z, CheckpointLoc[1], CheckpointLoc[2], CheckpointLoc[3])
			end

			table.sort(RacePositions[i], function(a, b)
				return a.dist > b.dist
			end)
		end
	end
end

function GetPlayerRacePosition(player)
	local max_positions = GetNumRacers()
	local position = -1
	for i=1, RaceTotalCheckpoints do
		for k, v in ipairs(RacePositions[i]) do
			if v.player == player then
				position = max_positions
				break
			else
				max_positions = max_positions -1
			end
		end
	end
	return position
end

function DoForAllRacers(func)
	for k,v in ipairs(Racers) do
		func(k)
	end
end

function FormatTime(time)
	local minutes = string.format("%02d", math.floor(time / 60.0))
	local seconds = string.format("%02d", math.floor(time - (minutes * 60.0)))
	local milliseconds = string.format("%03d", math.floor((time - (minutes * 60.0) - seconds) * 1000))
	return minutes..':'..seconds..':'..milliseconds
end

function IsValidRaceId(race_id)
	if race_id < 1 or race_id > NUM_RACES then
		return false
	end
	return true
end

function file_exists(filename)
    local file = io.open(filename, "r")
    if file then
        file:close()
        return true
    end
    return false
end
