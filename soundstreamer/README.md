## Sound Streamer

Serverside streamed 3D sounds.

This package allows you to add an unlimited amount of sounds in the game world.
The client can only play 8 sounds at the same time via CreateSound.
We get around this limit by taking advantage of the server side streaming algorithm via CreateObject.

[![video](http://i3.ytimg.com/vi/zwdsXZjx38s/maxresdefault.jpg)](https://www.youtube.com/watch?v=zwdsXZjx38s)

### Exported server functions
```Lua
CreateSound3D(sound_file, x, y, z, radius, volume, pitch)
DestroySound3D(soundid)
IsValidSound3D(soundid)
SetSound3DVolume(soundid, volume)
SetSound3DPitch(soundid, pitch)
SetSound3DDimension(soundid, dimension)
GetSound3DDimension(soundid)
SetSound3DLocation(soundid, x, y, z)
GetSound3DLocation(soundid)

-- 3D attached sounds, currently supporting vehicles
-- attach: ATTACH_VEHICLE, ATTACH_PLAYER, ATTACH_OBJECT, ATTACH_NPC
-- id: entity id
-- sound_file: network stream or audio file
-- radius: default 2500.0
-- volume: default 1.0
-- pitch: default 1.0
-- You can destroy attach sounds with DestroySound3D
CreateAttachedSound3D(attach, id, sound_file, radius, volume, pitch, loop)
GetAttached3DSounds(attach, id)
IsAttachedSound3D(soundid)
```

#### Example Usage 
```Lua
sr = ImportPackage("soundstreamer")

function OnPackageStart()
	local sound = sr.CreateSound3D("http://us4.internet-radio.com:8258/listen.pls&t=.pls", 125773.000000, 80246.000000, 1645.000000, 650.0)
end
AddEvent("OnPackageStart", OnPackageStart)

function cmd_radio(player)
	local v = GetPlayerVehicle(player)
	if v == false then
		AddPlayerChat(player, "You must be in a vehicle")
		return
	end

	if PlayerData[player].radio ~= 0 then
		AddPlayerChat(player, "Radio already playing")
		return
	end

	PlayerData[player].radio = sr.CreateAttachedSound3D(ATTACH_VEHICLE, v, "http://us4.internet-radio.com:8258/listen.pls&t=.pls", 1250.0)
	sr.SetSound3DVolume(PlayerData[player].radio, 0.25)
	AddPlayerChat(player, "Radio playing, /dradio to stop")

	local sounds = sr.GetAttached3DSounds(ATTACH_VEHICLE, v)
	for k, v in pairs(sounds) do
		print(k, v)
	end
end
AddCommand("radio", cmd_radio)

function cmd_dradio(player)
	local v = GetPlayerVehicle(player)
	if v == false then
		AddPlayerChat(player, "You must be in a vehicle")
		return
	end

	if PlayerData[player].radio == 0 then
		AddPlayerChat(player, "No radio playing")
		return
	end

	sr.DestroySound3D(PlayerData[player].radio)
	PlayerData[player].radio = 0
	AddPlayerChat(player, "Radio stopped")
end
AddCommand("dradio", cmd_dradio)
```
