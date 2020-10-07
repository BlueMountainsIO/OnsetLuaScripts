local commandMap = {}
local helpMap = {}

function AddConsoleCommand(name, help_or_callback, callback)
	if name == nil or help_or_callback == nil then
		return false
	end
	if type(help_or_callback) == "string" then
		if type(callback) ~= "function" then
			return false
		end
		helpMap[name] = help_or_callback
		commandMap[name] = callback
	else
		commandMap[name] = help_or_callback
	end
	return true
end
AddFunctionExport("AddConsoleCommand", AddConsoleCommand)

AddEvent("OnPackageStart", function()
	print("Type 'help' to get a list of consle commands")
end)

function ProcessInput(input)
	local cmd
	local args = {}
	for word in input:gmatch("%w+") do
		if cmd == nil then
			cmd = word
		else
			table.insert(args, word)
		end
	end
	if commandMap[cmd] ~= nil then
		commandMap[cmd](table.unpack(args))
	else
		print("Command '"..cmd.."' not found")
	end
end

AddEvent("OnConsoleInput", function(input)
	ProcessInput(input)
end)

AddRemoteEvent("OnClientConsoleInput", function(player, input)
	ProcessInput(input)
end)

AddConsoleCommand("help", function()
	print("Available commands:")
	
	table.sort(commandMap, function(a, b)
		return a:upper() < b:upper()
	end)
	
	for k, v in pairs(commandMap) do
		print("", k, helpMap[k] or "")
	end	
end)

AddConsoleCommand("restart", "Restarts a package", function(package_name)
	if package_name == nil then
		return print("Syntax: restart <package_name>")
	end
	if IsPackageStarted(package_name) then
		StopPackage(package_name)
		Delay(100, function()
			StartPackage(package_name)
		end)
	else
		print("Package "..package_name.." not started, use 'start' command")
	end
end)

AddConsoleCommand("start", "Starts a package", function(package_name)
	if package_name == nil then
		return print("Syntax: start <package_name>")
	end
	if IsPackageStarted(package_name) then
		print("Package "..package_name.." already started")
	else
		StartPackage(package_name)
	end
end)

AddConsoleCommand("stop", "Stops a package", function(package_name)
	if package_name == nil then
		return print("Syntax: stop <package_name>")
	end
	if not IsPackageStarted(package_name) then
		print("Package "..package_name.." not started")
	else
		StopPackage(package_name)
	end
end)

AddConsoleCommand("list", "List all started packages", function()
	print("Started packages:")
	for _, v in pairs(GetAllPackages()) do
		print("", v)
	end
end)

AddConsoleCommand("exit", "Stops the server", function(reason)
	ServerExit(reason)
end)
