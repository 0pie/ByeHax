if byehax.config.disable_net_verifier then return end

local _netIncoming = net.Incoming
local _netReadHeader = net.ReadHeader

local current_net = -1
function net.ReadHeader()
	if current_net == -1 then
		return _netReadHeader()
	end
	return current_net -- I don't know if you have to do that, but just to be sure. . .
end
function net.Incoming(len, ply)
	current_net = _netReadHeader()
	if not ply.byehax then
		byehax.PlayerInitialSpawn(ply)
		return _netIncoming(len, ply)
	end
	local str = util.NetworkIDToString(current_net)
	if str ~= "byehax_BE_COOKING" then
		ply.byehax.used_nets = ply.byehax.used_nets or {}
		ply.byehax.used_nets[str] = true
	end
	return _netIncoming(len, ply)
end
byehax.AddNetCallback("NetVerify", function(ply, nets)
	for k,v in pairs(ply.byehax.used_nets) do
		if not nets[k] then
			byehax:AddDetection(ply, "Net messages could not be verified", k)
		end
	end
	ply.byehax.used_nets = {}
end)