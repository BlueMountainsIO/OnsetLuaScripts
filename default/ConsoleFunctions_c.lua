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

AddEvent("OnConsoleInput", function(input)
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
		return true
	else
		print("Command '"..cmd.."' not found")
	end
end)
