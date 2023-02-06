if not byehax then
	print("byehax Anti-Cheats could not load !")
	return
end

byehax.config = {}
byehax.players = {}


function byehax:LoadFile(file)
	byehax("Loading file '"..file.."'")
	include("byehax_anticheats/"..file..".lua")
end

	byehax:LoadFile("libs")
	byehax:LoadFile("configs/config")

	byehax:LoadFile("checks")

	byehax:LoadFile("internal")
	byehax:LoadFile("detections")
	byehax:LoadFile("commands")

	byehax:LoadFile("modules/cusercmd")
	byehax:LoadFile("modules/antibackdoor")
	byehax:LoadFile("modules/update")


	byehax:LoadFile("modules/network")


	byehax:LoadFile("modules/luacompile")
	byehax:LoadFile("modules/netverify")
-- ulx is ass