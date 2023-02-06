function byehax.PlayerInitialSpawn(ply)
	if ply.has_been_initialzed then return end
	if ply:IsBot() then
		return
	end

	ply.byehax = {}
	ply.byehax.dets = {}

	ply.byehax.inited   = false
	ply.byehax.jointime = CurTime()
	ply.byehax.lastping = CurTime() + byehax.config.max_join_time
	ply.byehax.report = {}
	ply.byehax.funcs = {}
	ply.byehax.luastosend = {}

	ply.has_been_initialzed = true

	if ply:OwnerSteamID64() ~= ply:SteamID64() then
		-- Family shared
		if byehax.config.disable_family_sharing then
			byehax:AddDetection(ply, "Player is using a family shared license", "OSID="..ply:OwnerSteamID64())
			return
		end
		local sid = util.SteamIDFrom64(ply:OwnerSteamID64())
		if byehax.IsSteamIDBanned(sid) then
			byehax:AddDetection(ply, "Player is using a banned family shared license", "OSID="..ply:OwnerSteamID64())
		end
	end

	byehax.players[ply] = ply
end
hook.Add("PlayerInitialSpawn", "byehax PlayerInitialSpawn", function(ply)
	byehax.PlayerInitialSpawn(ply)
end)

hook.Add("PlayerDisconnected", "byehax PlayerDisconnected", function(ply)
	byehax.players[ply] = nil
end)


gameevent.Listen("player_changename")

hook.Add("player_changename", "byehax player_changename", function(data)
	local ply = Player(data.userid)
	if byehax.config.max_steamname_changes == 0 then
		byehax:AddDetection(ply, "Player changed their steam name", "ON="..data.oldname.." ;NN="..data.newname)
		return
	end
	if not isnumber(ply.byehax.changedname) then
		ply.byehax.changedname = 1
	else
		ply.byehax.changedname = ply.byehax.changedname + 1
	end
	if ply.byehax.changedname >= byehax.config.max_steamname_changes then
		byehax:AddDetection(ply, "Player changed their steam name too much", "CS="..ply.byehax.changedname)
	end
end)

timer.Create("byehax TimerCheckPings", 5, 0, function()
	for k,ply in pairs(player.GetHumans()) do
		if not ply.byehax.inited then
			if (CurTime() - ply.byehax.jointime) > byehax.config.max_join_time then
				byehax:AddDetection(ply, "Client did not join in time", "JT="..(CurTime() - ply.byehax.jointime))
			end
			return
		end
		if (CurTime() - ply.byehax.lastping) > byehax.config.max_ping_time then
			byehax:AddDetection(ply, "Client did not send ping back in time", "PT="..(CurTime() - ply.byehax.jointime))
		else
			if #ply.received_parts == 0 then
				if (CurTime() - ply.byehax.lastping) > 30 then
					byehax.FlushReport(ply)
				end
			end
		end
	end
end)