
local TrafficLights = { }

local LIGHT_OFF = 0
local LIGHT_GREEN = 1
local LIGHT_YELLOW = 2
local LIGHT_RED = 3

local LightChangeInterval = 1000 -- Milliseconds

local TrafficLightTimer = 0

AddEvent("OnPackageStart", function()

	TrafficLightTimer = CreateTimer(function()

		for k, v in pairs(TrafficLights) do
			if v.state == LIGHT_OFF or v.state == LIGHT_RED then
				v.state = LIGHT_GREEN
			elseif v.state == LIGHT_GREEN then
				v.state = LIGHT_YELLOW
			elseif v.state == LIGHT_YELLOW then
				v.state = LIGHT_RED
			end

			SetObjectPropertyValue(k, "_trafficLightState", v.state)
		end

	end, LightChangeInterval)

end)

AddEvent("OnPackageStop", function()

	DestroyTimer(TrafficLightTimer)
	TrafficLightTimer = 0

	for k, v in pairs(TrafficLights) do
		DestroyObject(k)
	end

	TrafficLights = nil
end)

AddFunctionExport("CreateTrafficLight", function (model, x, y, z, rx, ry, rz)
	rx = rx or 0.0
	ry = ry or 0.0
	rz = rz or 0.0

	-- Create a dummy object that will help us streaming the traffic light
	local object = CreateObject(1, x, y, z, rx, ry, rz, 0.01, 0.01, 0.01)
	SetObjectPropertyValue(object, "_trafficLight", model)
	--SetObjectStreamDistance(tl, 4000.0)

	TrafficLights[object] = { }
	TrafficLights[object].state = LIGHT_OFF

	SetObjectPropertyValue(object, "_trafficLightState", TrafficLights[object].state)

	return object
end)

AddFunctionExport("DestroyTrafficLight", function (object)
	if TrafficLights[object] == nil then
		return false
	end
	TrafficLights[object] = nil
	return DestroyObject(object)
end)

AddFunctionExport("SetTrafficLightState", function (object, state)
	if TrafficLights[object] == nil then
		return false
	end
	TrafficLights[object].state = state
	SetObjectPropertyValue(object, "_trafficLightState", TrafficLights[object].state)
end)
