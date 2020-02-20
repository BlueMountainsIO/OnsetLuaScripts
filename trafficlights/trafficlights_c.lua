
local TrafficLights = { }

local LIGHT_OFF = 0
local LIGHT_GREEN = 1
local LIGHT_YELLOW = 2
local LIGHT_RED = 3

local TraffcLightModels = {
	"/Game/Geometry/ModularHousesB/Models/SM_TrafficLight_1Lane"
}

AddEvent("OnObjectStreamIn", function(object)
	
	local _trafficLight = GetObjectPropertyValue(object, "_trafficLight")

	if _trafficLight ~= nil then
		local x, y, z = GetObjectLocation(object)
		local pitch, yaw, roll = GetObjectRotation(object)

		TrafficLights[object] = { }

		-- Spawn an instance of AStaticMeshActor
		TrafficLights[object].Actor = GetWorld():SpawnActor(AStaticMeshActor.Class(), FVector(x, y, z), FRotator(pitch, yaw, roll))

		-- Set the static mesh component to "moveable", this is requried by Unreal if we want to change the mesh
		TrafficLights[object].Actor:GetStaticMeshComponent():SetMobility(EComponentMobility.Movable)

		-- Set the static mesh model
		TrafficLights[object].Actor:GetStaticMeshComponent():SetStaticMesh(UStaticMesh.LoadFromAsset(TraffcLightModels[_trafficLight]))

		-- Set it back to static for optimal performance
		TrafficLights[object].Actor:GetStaticMeshComponent():SetMobility(EComponentMobility.Static)

		-- Create a material instance of the traiffc light material
		TrafficLights[object].MaterialInstance = TrafficLights[object].Actor:GetStaticMeshComponent():CreateDynamicMaterialInstance(0)

		-- If the game was started in dev mode show an additional text label
		if IsGameDevMode() then
			TrafficLights[object].TextLabel = TrafficLights[object].Actor:AddComponent(UTextRenderComponent.Class())
			TrafficLights[object].TextLabel:SetRelativeLocation(FVector(0.0, -150.0, 485.0))
			TrafficLights[object].TextLabel:SetRelativeRotation(FRotator(0.0, 180.0, 0.0))
			TrafficLights[object].TextLabel:SetHorizontalAlignment(EHorizTextAligment.EHTA_Left)
		end

		local _trafficLightState = GetObjectPropertyValue(object, "_trafficLightState")
		SetTrafficLightState(object, _trafficLightState)
	end

end)

AddEvent("OnObjectStreamOut", function(object)

	-- When the object is streamed out make sure to destroy the actor that we have spawned!
	if TrafficLights[object] ~= nil then
		TrafficLights[object].Actor:Destroy()

		TrafficLights[object] = nil
	end

end)

AddEvent("OnObjectNetworkUpdatePropertyValue", function (object, PropertyName, PropertyValue)

	-- Update light state on property update
	if PropertyName == "_trafficLightState" then
		SetTrafficLightState(object, PropertyValue)
	end

end)

function SetTrafficLightState(object, state)

	if TrafficLights[object] == nil then
		return
	end

	TrafficLights[object].MaterialInstance:SetFloatParameter("RedLight", 0.0)
	TrafficLights[object].MaterialInstance:SetFloatParameter("YellowLight", 0.0)
	TrafficLights[object].MaterialInstance:SetFloatParameter("GreenLight", 0.0)

	local Text = "OFF"
	local TextColor = FLinearColor(0.0, 0.0, 0.0, 1.0)

	if state == LIGHT_GREEN then
		TrafficLights[object].MaterialInstance:SetFloatParameter("GreenLight", 1.0)
		TextColor.G = 1.0
		Text = "Green"
	elseif state == LIGHT_YELLOW then
		TrafficLights[object].MaterialInstance:SetFloatParameter("YellowLight", 1.0)
		TextColor.R = 1.0
		TextColor.G = 1.0
		Text = "Yellow"
	elseif state == LIGHT_RED then
		TrafficLights[object].MaterialInstance:SetFloatParameter("RedLight", 1.0)
		TextColor.R = 1.0
		Text = "Red"
	end

	if IsGameDevMode() then
		TrafficLights[object].TextLabel:SetText(Text)
		TrafficLights[object].TextLabel:SetTextRenderColor(TextColor)
	end
	
end
