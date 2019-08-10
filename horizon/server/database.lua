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

sql = false

local SQL_HOST = "localhost"
local SQL_PORT = 3306
local SQL_USER = "user"
local SQL_PASS = "pass"
local SQL_DATA = "dbname"
local SQL_CHAR = "utf8mb4"
local SQL_LOGL = "debug"

-- Setup a MariaDB connection when the package/server starts
local function OnPackageStart()
	mariadb_log(SQL_LOGL)

	sql = mariadb_connect(SQL_HOST .. ':' .. SQL_PORT, SQL_USER, SQL_PASS, SQL_DATA)

	if (sql ~= false) then
		print("MariaDB: Connected to " .. SQL_HOST)
		mariadb_set_charset(sql, SQL_CHAR)
	else
		print("MariaDB: Connection failed to " .. SQL_HOST .. ", see mariadb_log file")

		-- Immediately stop the server if we cannot connect
		ServerExit()
	end

	CallEvent("database:connected")
end
AddEvent("OnPackageStart", OnPackageStart)

-- Cleanup the MariaDB connection when the package/server stops
local function OnPackageStop()
	mariadb_close(sql)
end
AddEvent("OnPackageStop", OnPackageStop)

-- ALTER TABLE log_chat ADD FOREIGN KEY (id) REFERENCES accounts (id) ON UPDATE CASCADE ON DELETE CASCADE;
