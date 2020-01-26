## WebUI (3D) Streamer

Serverside streamed 3D webuis.

This package allows you to add an unlimited amount of webuis to the game world.
The client can only play 32 webuis at the same time with the CreateWebUI* functions.
We get around this limit by exploting the server side streaming algorithm via CreateObject.

#### Example Usage 
```Lua
ws = ImportPackage("webuistreamer")

function OnPackageStart()
	-- Creates a remote webui that can load whitelisted websites like youtube.
	local web = ws.CreateRemoteWebUI3D(126016.046875, 81475.203125, 1870.0, 0.0, -90.0, 0.0, 1280, 720, 30, 10000)
	--ws.SetWebUI3DUrl(web, "https://www.youtube.com/watch?v=bDWc9rlLdhY?autoplay=1")
	ws.SetWebUI3DUrl(web, "https://www.youtube.com/embed/YiYm01qX2u4?autoplay=1")
end
AddEvent("OnPackageStart", OnPackageStart)
```

![](https://dev.playonset.com/images/9/9e/3dwebui.png)

### Exported serverside functions
```Lua
CreateWebUI3D(x, y, z, rx, ry, rz, width, height, frame_rate, radius)
CreateRemoteWebUI3D(x, y, z, rx, ry, rz, width, height, frame_rate, radius)
DestroyWebUI3D(webui)
IsValidWebUI3D(webui)
SetWebUI3DUrl(webui, url)
SetWebUI3DDimension(webui, dimension)
GetWebUI3DDimension(webui)
SetWebUI3DLocation(webui, x, y, z)
GetWebUI3DLocation(webui)
```
