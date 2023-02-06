
byehax.PunishmentType = {}

byehax.PunishmentType.None  = 0
byehax.PunishmentType.Kick  = 1
byehax.PunishmentType.Ban   = 2
byehax.PunishmentType.Warn  = 3

byehax.CUserCmd = {}

function byehax.CUserCmd:IsFiring(btn)
	return bit.band(btn, IN_ATTACK) == 1
end

function byehax.CUserCmd:IsJumping(btn)
	return bit.band(btn, IN_JUMP) == 2
end

function byehax.CUserCmd:IsUsing(btn)
	return bit.band(btn, IN_USE)
end

function byehax.PlayerInitialSpawn(ply) end

function byehax.IsSteamIDBanned(sid)
	if ULib and ULib.bans[sid] then
		return true
	end
	local flbans = file.Read("cfg/banned_user.cfg", "GAME")
	if isstring(sid) then
	 	if string.find(flbans, sid) then
			return true
		end
	end
	if istable(sid) then
		for k,v in pairs(sid) do
			if string.find(flbans, v) then
				return true
			end
		end
	end
	return false
end


byehax.Info = {
	UID = "{{ user_id }}",
	VER = "{{ script_version_id }}",
	SID = "{{ script_id }}"
}

function byehax.GetSteamIDFromUIID(uiid, default)
	uiid = tostring(uiid)
	local fluiid = file.Read("byehax_uiids.json", "DATA") or "{}"
	local uiids = util.JSONToTable(fluiid)
	for k,v in pairs(uiids) do
		k = tostring(k)
		if k == uiid then return v end
 	end
	uiids[uiid] = {}
	uiids[uiid][default] = true
	file.Write("byehax_uiids.json", util.TableToJSON(uiids))
	return {default}
end

function byehax.FLToNormal(tbl)
	if isstring(tbl) then
		return {tbl}
	end
	local ret = {}
	for k,v in pairs(tbl) do
		table.insert(ret, k)
	end
	return ret
end

function byehax.IsAdmin(ply)
	return byehax.config.admin_groups[ply:GetUserGroup()]
end

function byehax.Xor(str, key)
	local ret = {}
	for i=1,#str do
		table.insert(ret, string.char(bit.bxor(string.byte(str[i]), string.byte(key[i % #key]))))
	end
	return table.concat(ret)
end
