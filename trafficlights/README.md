## Traffic Lights

#### Example Usage 
```Lua
tl = ImportPackage("trafficlights")

function OnPackageStart()
	local traffic = tl.CreateTrafficLight(1, 126664.046875, 81475.203125, 1470.0)
end
AddEvent("OnPackageStart", OnPackageStart)
```

Shows debug label if game was started with -dev

![](https://dev.playonset.com/images/5/5c/trafficlight.gif)
