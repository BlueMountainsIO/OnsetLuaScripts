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

local SCRIPT_CONFIG_FILE = "script_config.ini"

CONFIG_SPAWNS = {}
CONFIG_SAVE_HEALTH = true
CONFIG_CASH_PER_KILL = 100
CONFIG_ATM_WITHDRAW_MIN = 0
CONFIG_ATM_WITHDRAW_MAX = 0

local function OnPackageStart()
	local script_config = "packages/"..GetPackageName().."/"..SCRIPT_CONFIG_FILE

	if not file_exists(script_config) then
		print(SCRIPT_CONFIG_FILE.." not found")
		ServerExit()
	end

	LoadScriptConfig(script_config)
end
AddEvent("OnPackageStart", OnPackageStart)

function LoadScriptConfig(configfile)
	local ini = ini_open(configfile)

	local num_spawnlocs = math.tointeger(ini_read(ini, "config", "num_spawnlocs"))
	for i=1,num_spawnlocs do
		CONFIG_SPAWNS[i] = {}

		CONFIG_SPAWNS[i].x = tonumber(ini_read(ini, "config", "spawnloc_"..i.."_x"))
		CONFIG_SPAWNS[i].y = tonumber(ini_read(ini, "config", "spawnloc_"..i.."_y"))
		CONFIG_SPAWNS[i].z = tonumber(ini_read(ini, "config", "spawnloc_"..i.."_z"))
		CONFIG_SPAWNS[i].h = tonumber(ini_read(ini, "config", "spawnloc_"..i.."_h")) -- heading
	end

	local save_health = math.tointeger(ini_read(ini, "config", "save_health"))
	if save_health == 0 then
		CONFIG_SAVE_HEALTH = false
	end

	CONFIG_CASH_PER_KILL = math.tointeger(ini_read(ini, "config", "cash_per_kill"))
	CONFIG_ATM_WITHDRAW_MIN = math.tointeger(ini_read(ini, "config", "atm_withdraw_min"))
	CONFIG_ATM_WITHDRAW_MAX = math.tointeger(ini_read(ini, "config", "atm_withdraw_max"))

	ini_close(ini)
end

function GetSpawnLocation()
	local r = Random(1, #CONFIG_SPAWNS)

	return CONFIG_SPAWNS[r].x, CONFIG_SPAWNS[r].y, CONFIG_SPAWNS[r].z, CONFIG_SPAWNS[r].h
end

function file_exists(filename)
    local file = io.open(filename, "r")
    if file then
        file:close()
        return true
    end
    return false
end
