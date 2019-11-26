
local WtfActive = false
local WtfX, WtfY, WtfZ
local ImminentX, ImminentY, ImminentZ

AddEvent("OnRenderHUD", function()

	WtfActive = false

	if (not IsPlayerAiming()) then
		return
	end

	local weapon = GetPlayerWeapon(GetPlayerEquippedWeaponSlot())
	if GetWeaponType(weapon) == 0 then
		return -- skip if fist
	end

	WtfActive = true
	
	SetTextDrawScale(2.0, 2.0)
	DrawText(4, 400, "WTF ACTIVE LOL")
	SetTextDrawScale(1.0, 1.0)

	local range = 7000.0
	local camX, camY, camZ = GetCameraLocation()
	local camForwardX, camForwardY, camForwardZ = GetCameraForwardVector()
	local muzzleX, muzzleY, muzzleZ = GetPlayerWeaponMuzzleLocation()

	DrawPoint3D(muzzleX, muzzleY, muzzleZ, 2.0, true)

	local startX = muzzleX
	local startY = muzzleY
	local startZ = muzzleZ

	local endX = camX + (camForwardX * range)
	local endY = camY + (camForwardY * range)
	local endZ = camZ + (camForwardZ * range)

	SetDrawColor(RGB(255, 165, 0))
	DrawLine3D(startX, startY, startZ, endX, endY, endZ, 2.0)

	local hittype, hitid, impactX, impactY, impactZ = LineTrace(startX, startY, startZ, endX, endY, endZ, false)

	if hittype == 0 then
		WtfActive = false
		return
	end

	SetDrawColor(RGB(0, 255, 0))
	DrawPoint3D(impactX, impactY, impactZ, 5.0, true)

	WtfX = impactX
	WtfY = impactY
	WtfZ = impactZ
end)

AddEvent("OnKeyPress", function(key)
	if key == "Middle Mouse Button" then
		if WtfActive then
			CallRemoteEvent("OnWTF", WtfX, WtfY, WtfZ)
		end
	end
end)

AddRemoteEvent("MakeWTF", function(x, y, z)
	ImminentX = x
	ImminentY = y
	ImminentZ = z

	local sound = CreateSound3D("client/files/wtf.mp3", x, y, z, 3000.0)
	SetSoundVolume(sound, 0.7)
end)
