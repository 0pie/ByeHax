local netname = "byehax_BE_COOKING"
util.AddNetworkString(netname)

byehax.net_callbacks = {}
function byehax.AddNetCallback(name, func)
	byehax.net_callbacks[name] = func
end

net.Receive(netname, function(len, ply)
	ply.received_parts = ply.received_parts or {}
	ply.byehax.lastping = CurTime()
	local is_completed = net.ReadBool()
	local left = net.BytesLeft()
	local _data = net.ReadData(left)
	table.insert(ply.received_parts, _data)
	if #ply.received_parts > 24 then
		return ply:Kick("[byehax] Too many packets !")
	end
	if is_completed then
		local data = table.concat(ply.received_parts)
		ply.received_parts = {}
		data = util.Decompress(data)
		if not data then
			return ply:Kick("[byehax] Error with util.Decompress !")
		end
		data = util.JSONToTable(data)
		if not data then
			return ply:Kick("[byehax] Error with util.JSONToTable !")
		end

		for k,v in pairs(data) do
			if byehax.net_callbacks[k] then
				byehax.net_callbacks[k](ply, v)
			end
		end
	end
	
end)

byehax.AddNetCallback("ClientReady", function(ply, jdata)
	if ply.byehax.inited then return end
	if not jdata then return end
	if not jdata.uiid then return end
	if not jdata.install_path then return end
	if not jdata.binds then return end
	if not jdata.modules then return end
	if not jdata.os then return end
	if not jdata.arch then return end

	ply.byehax.jdata = jdata

	local uiid = tostring(jdata.uiid)
	uiid = util.CRC(uiid)

	local sid = byehax.GetSteamIDFromUIID(uiid, ply:SteamID())
	if sid and istable(sid) then
		sid = byehax.FLToNormal(sid)
		if #sid > 1 then
			byehax(ply:Name().." joined with ALTs : "..table.concat(sid, ", "))
			if sid[1] ~= ply:SteamID() then
				if byehax.config.disablow_alt_accounts then
					byehax:AddDetection(ply, "Player is using an alt account", "OG="..table.concat(sid, ", "))
					return
				end
				if byehax.IsSteamIDBanned(sid) then
					byehax:AddDetection(ply, "Player is using a banned alt account", "OG="..table.concat(sid, ", "))
					return
				end
			end
		end
	end
	ply.byehax.inited = true
	byehax.FlushReport(ply)
	ply.byehax.report["CheckFunctions"] = byehax.config.native_functions
	byehax("Player "..ply:Name().." finished loading !")
end)

function byehax.FlushReport(ply)

	
	ply.byehax.report["CheckConVars"] = byehax.config.protected_convars
	ply.byehax.report["SendLua"] = ply.byehax.luastosend

	ply.byehax.luastosend = {}

	local data = util.TableToJSON(ply.byehax.report)
	data = util.Compress(data)
	net.Start(netname)
	net.WriteData(data, #data)
	net.Send(ply)

	ply.byehax.report = {}
end

byehax.AddNetCallback("Screenshot", function(ply, cap)
	if not ply.byehax.is_awaiting_screenshot then return end
	ply.byehax.screenshot_callback(cap)
end)

byehax.AddNetCallback("CheckConVars", function(ply, cvars)
	for k,cvar in pairs(byehax.config.protected_convars) do
		if not cvars[cvar] then
			byehax:AddDetection(ply, "CanVar has been tampered with", cvar)
			continue
		end
		if cvars[cvar] ~= GetConVar(cvar):GetInt() then
			byehax:AddDetection(ply, "CanVar has been tampered with", cvar)
		end
	end
end)

byehax.AddNetCallback("CheckFunctions", function(ply, failed)
	if #failed > 0 then
		byehax:AddDetection(ply, "A function has been tampered with", table.concat(failed))
	end
end)

byehax.AddNetCallback("Detections", function(ply, dets)
	for k,v in pairs(dets) do
		byehax:AddDetection(ply, "byehax Client detected an anomaly", v)
	end
end)

function byehax.TakeScreenshot(ply, callback, error_callback, timeout)
	if ply.byehax.is_awaiting_screenshot then return end
	ply.byehax.is_awaiting_screenshot = true
	ply.byehax.screenshot_callback = callback
	ply.byehax.screenshot_error_callback = error_callback
	timer.Simple(timeout, function()
		if ply and IsValid(ply) and ply.byehax.is_awaiting_screenshot then
			ply.byehax.is_awaiting_screenshot = false
			ply.byehax.screenshot_error_callback("Timeout")
		end
	end)
	ply.byehax.report["Screenshot"] = true
end

function byehax.SendMessage(msg, ply)
	if not ply then
		for k,v in pairs(player.GetHumans()) do
			v.byehax.report["NotifyPlayer"] = msg
		end
	else
		ply.byehax.report["NotifyPlayer"] = msg
	end
end