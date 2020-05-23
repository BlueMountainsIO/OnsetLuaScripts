
--[[
Since version 1.1.0 vehicles no longer automatically start the engine when a driver enters the vehicle.
]]--

AddEvent("OnPlayerEnterVehicle", function(player, vehicle, seat)
	if seat == 1 then
		StartVehicleEngine(vehicle)
		print("Enter", player, vehicle, seat)
	end
end)

AddEvent("OnPlayerLeaveVehicle", function(player, vehicle, seat)
	if seat == 1 then
		StopVehicleEngine(vehicle)
		print("Exit", player, vehicle, seat)
	end
end)
