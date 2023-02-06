local byehax_load_from_init = true
if SERVER then
	byehax = {}
	local _byehax = {}
	function _byehax.__call(s, arg)
		print("[byehax] "..arg)
	end
	setmetatable(byehax, _byehax)

	byehax("Loading the loader")
	AddCSLuaFile "byehax_anticheats/client/new_client.lua"
	if byehax_load_from_init then
		AddCSLuaFile "includes/init.lua"
		byehax("byehax Client will be loaded from init.lua")
	else
		byehax("byehax Client will be loaded from autorun/byehax_anticheats.lua")
	end
	include "byehax_anticheats/loader.lua"
	byehax("byehax Anti-Cheats has loaded !")
	return
end
if not CLIENT then return end


if not byehax_load_from_init then
	include "byehax_anticheats/client/new_client.lua"
end