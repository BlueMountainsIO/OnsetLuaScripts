
local ElevatorDoor1 = {
	FVector(-43.000000, 55.000000, 4.000000), --open
	FRotator(0.0, 180.0, 0.0), --open
	FVector(-90.000000, 55.000000, 4.000000) --close
}

local ElevatorDoor2 = {
	FVector(-43.000000, 52.000000, 4.000000),
	FRotator(0.0, 180.0, 0.0),
	FVector(-145.000000, 52.000000, 4.000000)
}

local ElevatorOutsideDoor1 = {
	FVector(-43.000000, 42.000000, 4.000000), --open
	FRotator(0.0, 180.0, 0.0), --open
	FVector(-90.000000, 42.000000, 4.000000) --close
}

local ElevatorOutsideDoor2 = {
	FVector(-43.000000, 46.000000, 4.000000), --open
	FRotator(0.0, 180.0, 0.0), --open
	FVector(-145.000000, 46.000000, 4.000000) --close
}

local ElevatorKey = "E"

local Elevators = { }

local ElevatorOutsideDoors = { }

AddEvent("OnPackageStop", function()
	for k, v in pairs(Elevators) do
		v.InfoText:Destroy()
		v.Door1:Destroy()
		v.Door2:Destroy()
		v.Actor:Destroy()
	end
	Elevators = { }
	
	for k, v in pairs(ElevatorOutsideDoors) do
		v.InfoText:Destroy()
		v.Door1:Destroy()
		v.Door2:Destroy()
		v.ElevatorEntrance:Destroy()
		v.Actor:Destroy()
	end
	ElevatorOutsideDoors = { }
end)

AddEvent("OnObjectStreamIn", function(object)
	
	local elevator = GetObjectPropertyValue(object, "elevator")

	if elevator == true then

		local ObjectActor = GetObjectActor(object)
		local Location = ObjectActor:GetActorLocation()
		
		ObjectActor:SetActorScale3D(FVector(0.01, 0.01, 0.01))
		ObjectActor:SetActorEnableCollision(false)
		ObjectActor:ActorAddTag("ElevatorCabinDummyActor")

		local state = GetObjectPropertyValue(object, "state")
		local num_floors = GetObjectPropertyValue(object, "num_floors")

		Elevators[object] = { }

		Elevators[object].Actor = GetWorld():SpawnActor(AStaticMeshActor.Class(), Location, FRotator(0.0, 0.0, 0.0))
		Elevators[object].Actor:GetStaticMeshComponent():SetMobility(EComponentMobility.Movable)
		Elevators[object].Actor:GetStaticMeshComponent():SetStaticMesh(UStaticMesh.LoadFromAsset("/Game/Geometry/Office/Meshes/SM_Elevator_01a"))

		Elevators[object].Door1 = Elevators[object].Actor:AddComponent(UStaticMeshComponent.Class())
		Elevators[object].Door1:SetMobility(EComponentMobility.Movable)
		Elevators[object].Door1:SetStaticMesh(UStaticMesh.LoadFromAsset("/Game/Geometry/Office/Meshes/SM_Elevator_01c"))
		Elevators[object].Door1:SetRelativeLocation(state == "open" and ElevatorDoor1[1] or ElevatorDoor1[3])
		Elevators[object].Door1:SetRelativeRotation(ElevatorDoor1[2])
		
		Elevators[object].Door2 = Elevators[object].Actor:AddComponent(UStaticMeshComponent.Class())
		Elevators[object].Door2:SetMobility(EComponentMobility.Movable)
		Elevators[object].Door2:SetStaticMesh(UStaticMesh.LoadFromAsset("/Game/Geometry/Office/Meshes/SM_Elevator_01c"))
		Elevators[object].Door2:SetRelativeLocation(state == "open" and ElevatorDoor2[1] or ElevatorDoor2[3])
		Elevators[object].Door2:SetRelativeRotation(ElevatorDoor2[2])
		
		local ATR = FAttachmentTransformRules(EAttachmentRule.SnapToTarget, true)
		ATR.ScaleRule = EAttachmentRule.KeepWorld
		Elevators[object].Actor:AttachToActor(ObjectActor, ATR, "")
		
		Elevators[object].Door2IsClosedMoved = false
		Elevators[object].DoorTimer = 0
		
		Elevators[object].InfoText = Elevators[object].Actor:AddComponent(UTextRenderComponent.Class())
		--Elevators[object].InfoText:SetRelativeLocation(FVector(-230.0, 63.85, 184.0))
		--Elevators[object].InfoText:SetRelativeLocation(FVector(-71.0, 62.8, 190.0))
		Elevators[object].InfoText:SetRelativeLocation(FVector(-151.0, 283.8, 244.0))
		Elevators[object].InfoText:SetRelativeRotation(FRotator(0.0, -90.0, 0.0))
		Elevators[object].InfoText:SetWorldSize(18.0)
		Elevators[object].InfoText:SetYScale(0.85)
		Elevators[object].InfoText:SetHorizontalAlignment(EHorizTextAligment.EHTA_Center)
		Elevators[object].InfoText:SetVerticalAlignment(EVerticalTextAligment.EVRTA_TextTop)
		local text = "Select floor:<br>"
		for i=num_floors, 1, -1 do
			text = text .. tostring(i) .. "<br>"
		end
		Elevators[object].InfoText:SetText(text)
		 
	end
	
	local elevator_door = GetObjectPropertyValue(object, "elevator_door")
	
	if elevator_door == true then
	
		local ObjectActor = GetObjectActor(object)
		local Location = ObjectActor:GetActorLocation()
		
		ObjectActor:SetActorScale3D(FVector(0.01, 0.01, 0.01))
		ObjectActor:SetActorEnableCollision(false)
		ObjectActor:ActorAddTag("ElevatorDoorDummyActor")
		
		local state = GetObjectPropertyValue(object, "state")
		
		ElevatorOutsideDoors[object] = { }
		
		ElevatorOutsideDoors[object].Actor = GetWorld():SpawnActor(AStaticMeshActor.Class(), Location, FRotator(0.0, 0.0, 0.0))
		ElevatorOutsideDoors[object].Actor:GetStaticMeshComponent():SetMobility(EComponentMobility.Movable)
		
		ElevatorOutsideDoors[object].ElevatorEntrance = GetWorld():SpawnActor(AStaticMeshActor.Class(), Location, FRotator(0.0, 0.0, 0.0))
		ElevatorOutsideDoors[object].ElevatorEntrance:GetStaticMeshComponent():SetMobility(EComponentMobility.Movable)
		ElevatorOutsideDoors[object].ElevatorEntrance:GetStaticMeshComponent():SetStaticMesh(UStaticMesh.LoadFromAsset("/Game/Geometry/Office/Meshes/SM_Elevator_01b"))
		ElevatorOutsideDoors[object].ElevatorEntrance:GetStaticMeshComponent():SetMobility(EComponentMobility.Static)
		
		ElevatorOutsideDoors[object].Door1 = ElevatorOutsideDoors[object].Actor:AddComponent(UStaticMeshComponent.Class())
		ElevatorOutsideDoors[object].Door1:SetMobility(EComponentMobility.Movable)
		ElevatorOutsideDoors[object].Door1:SetStaticMesh(UStaticMesh.LoadFromAsset("/Game/Geometry/Office/Meshes/SM_Elevator_01c"))
		ElevatorOutsideDoors[object].Door1:SetRelativeLocation(state == "open" and ElevatorOutsideDoor1[1] or ElevatorOutsideDoor1[3])
		ElevatorOutsideDoors[object].Door1:SetRelativeRotation(ElevatorOutsideDoor1[2])

		ElevatorOutsideDoors[object].Door2 = ElevatorOutsideDoors[object].Actor:AddComponent(UStaticMeshComponent.Class())
		ElevatorOutsideDoors[object].Door2:SetMobility(EComponentMobility.Movable)
		ElevatorOutsideDoors[object].Door2:SetStaticMesh(UStaticMesh.LoadFromAsset("/Game/Geometry/Office/Meshes/SM_Elevator_01c"))
		ElevatorOutsideDoors[object].Door2:SetRelativeLocation(state == "open" and ElevatorOutsideDoor1[1] or ElevatorOutsideDoor2[3])
		ElevatorOutsideDoors[object].Door2:SetRelativeRotation(ElevatorOutsideDoor2[2])
		
		ElevatorOutsideDoors[object].InfoText = ElevatorOutsideDoors[object].Actor:AddComponent(UTextRenderComponent.Class())
		ElevatorOutsideDoors[object].InfoText:SetRelativeLocation(FVector(-220.0, -1.25, 145.0))
		ElevatorOutsideDoors[object].InfoText:SetRelativeRotation(FRotator(0.0, -90.0, 0.0))
		ElevatorOutsideDoors[object].InfoText:SetWorldSize(12.0)
		ElevatorOutsideDoors[object].InfoText:SetHorizontalAlignment(EHorizTextAligment.EHTA_Center)
		ElevatorOutsideDoors[object].InfoText:SetText(ElevatorKey)
		
		ElevatorOutsideDoors[object].Floor = GetObjectPropertyValue(object, "floor")
		ElevatorOutsideDoors[object].Door2IsClosedMoved = false
		ElevatorOutsideDoors[object].DoorTimer = 0
		
	end

end)

AddEvent("OnObjectStreamOut", function(object)

	if Elevators[object] ~= nil then
	
		Elevators[object].Door1:Destroy()
		Elevators[object].Door2:Destroy()
		Elevators[object].Actor:Destroy()
	
		Elevators[object] = nil
		
	end
	
	if ElevatorOutsideDoors[object] ~= nil then
	
		ElevatorOutsideDoors[object].InfoText:Destroy()
		ElevatorOutsideDoors[object].Door1:Destroy()
		ElevatorOutsideDoors[object].Door2:Destroy()
		ElevatorOutsideDoors[object].ElevatorEntrance:Destroy()
		ElevatorOutsideDoors[object].Actor:Destroy()
	
		ElevatorOutsideDoors[object] = nil
		
	end
	
end)

AddRemoteEvent("Elevator:OpenClose", function(object, openorclose)
	OpenCloseElevator(Elevators, ElevatorDoor1, ElevatorDoor2, tonumber(object), openorclose)
end)

AddRemoteEvent("ElevatorOutside:OpenClose", function(object, openorclose)
	OpenCloseElevator(ElevatorOutsideDoors, ElevatorOutsideDoor1, ElevatorOutsideDoor2, tonumber(object), openorclose)
end)

function OpenCloseElevator(Table, DoorTable1, DoorTable2, object, openorclose)

	if Table[object] == nil then return end

	DestroyTimer(Table[object].DoorTimer)
	Table[object].Door2IsClosedMoved = false
	
	Table[object].DoorTimer = CreateTimer(function()
	
		if openorclose == "close" then
		
			local Current = Table[object].Door1:GetRelativeLocation()
			local Target = DoorTable1[3]
			local New = FMath.VInterpConstantTo(Current, Target, 0.016, 35.0)

			if math.abs(Target.X - New.X) < 0.2 then
				
				Current = Table[object].Door2:GetRelativeLocation()
				Target = DoorTable2[3]
				New = FMath.VInterpConstantTo(Current, Target, 0.016, 35.0)
				
				Table[object].Door2:SetRelativeLocation(New)
				
				if Target.X == New.X then
					DestroyTimer(Table[object].DoorTimer)
					Table[object].DoorTimer = 0
				end
				
			else
			
				New.Y = DoorTable1[1].Y
				Table[object].Door1:SetRelativeLocation(New)
				New.Y = DoorTable2[1].Y
				Table[object].Door2:SetRelativeLocation(New)		
				
			end
			
		else
		
			local Current = Table[object].Door2:GetRelativeLocation()
			local Target = DoorTable1[3]
			Target.Y = DoorTable2[1].Y
			local New = FMath.VInterpConstantTo(Current, Target, 0.016, 35.0)

			if Target.X == New.X or Table[object].Door2IsClosedMoved == true then
				
				Table[object].Door2IsClosedMoved = true
				
				Current = Table[object].Door1:GetRelativeLocation()
				Target = DoorTable1[1]
				New = FMath.VInterpConstantTo(Current, Target, 0.016, 35.0)
				
				Table[object].Door1:SetRelativeLocation(New)
				New.Y = DoorTable2[1].Y
				Table[object].Door2:SetRelativeLocation(New)				
				
				if Target.X == New.X then
					Table[object].Door2IsClosedMoved = false
					DestroyTimer(Table[object].DoorTimer)
					Table[object].DoorTimer = 0
				end
				
			else
			
				New.Y = DoorTable2[1].Y
				Table[object].Door2:SetRelativeLocation(New)
				
			end
			
		end
		
	end, 10)
	
end

AddEvent("OnKeyPress", function(key)
	if key == ElevatorKey then
		local x, y, z = GetPlayerLocation()
		local PlayerLocation = FVector(x, y, z)
		for k, v in pairs(ElevatorOutsideDoors) do
			if FVector.PointsAreNear(PlayerLocation, v.InfoText:GetWorldLocation(), 100.0) then
				--print("Near door", k)
				CallRemoteEvent("Elevator:RequestDoor", k)
				break
			end
		end
	else
		if key == "Ampersand" then
			key = "1"
		elseif key == "é" then
			key = "2"
		elseif key == "Quote" then
			key = "3"
		elseif key == "Apostrophe" then
			key = "4"
		elseif key == "Left Parantheses" then
			key = "5"
		elseif key == "Hyphen" then
			key = "6"
		elseif key == "è" then
			key = "7"
		elseif key == "Underscore" then
			key = "8"
		elseif key == "ç" then
			key = "9"
		end
		local numkey = tonumber(key)
		if numkey ~= nil and numkey < 10 and numkey > 0 then
			--print(tostring(numkey))
			local x, y, z = GetPlayerLocation()
			local PlayerLocation = FVector(x, y, z)
			for k, v in pairs(Elevators) do
				if FVector.PointsAreNear(PlayerLocation, v.InfoText:GetWorldLocation(), 200.0) then
					--print("Near info label elevator", k)
					CallRemoteEvent("Elevator:RequestFloor", k, numkey)
					break
				end
			end
		end
	end
end)
