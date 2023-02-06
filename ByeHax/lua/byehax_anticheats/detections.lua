hook.Add("byehaxPlayerDetectedOnce", "LogToFile", function(ply, det, data)
	if string.len(byehax.config.log_detection_to) ~= 0 then
		local ttime = util.DateStamp()
		local str = string.format("[%s] %s (%s) was detected : %s (%s)\r\n", ttime, ply:Name(), ply:SteamID(), det, data)
		file.Append(byehax.config.log_detection_to, str)
	end
end)

function byehax:AddDetection(ply, det_string, data)
	if byehax.config.test_mode then print(det_string, data) return end
	if byehax.config.admins_bypass then
		if byehax.IsAdmin(ply) then
			return
		end
	end
	hook.Run("byehaxPlayerDetected", ply, det_string, data)
	local pun = byehax.config.punishments[det_string]
	if pun == nil then pun = byehax.PunishmentType.Kick end

	if pun == byehax.PunishmentType.None then
		return
	end
	ply.byehax.detected = ply.byehax.detected or {}
	if ply.byehax.detected[det_string] then return end
	ply.byehax.detected[det_string] = true

	hook.Run("byehaxPlayerDetectedOnce", ply, det_string, data)
	byehax(ply:Name().." is cheating ! ("..det_string..")("..data..")")
	if byehax.config.alert_everyone_on_det then
		local msg = byehax.config.alert_message
		msg = string.Replace(msg, "%name%", ply:Name())
		byehax.SendMessage(msg)
	end
	if pun == byehax.PunishmentType.Warn then
		if byehax.config.take_screenshot then
			byehax.TakeScreenshot(ply, function(screenshot)
				if (not ply) or (not IsValid(ply)) then return end

				file.Write("byehax_screenshots/"..ply:SteamID64()..".jpg", screenshot)
				
				byehax(ply:Name().."'s screenshot received !")
				byehax("The screenshot can be found in data/byehax_screenshots/"..ply:SteamID64()..".jpg")
			end,function(err)
				if (not ply) or (not IsValid(ply)) then return end
				byehax("Error while taking a screenshot of "..ply:Name()..": "..err)
			end, 300)
		end
		return
	end
	
	if pun == byehax.PunishmentType.Kick then
		if (det_string == "Client did not send ping back in time") or (det_string == "Client did not join in time") then
			return ply:Kick("Kicked by byehax : Timeout")
		end
		if byehax.config.take_screenshot then
			byehax.TakeScreenshot(ply, function(screenshot)
				if (not ply) or (not IsValid(ply)) then return end

				file.Write("byehax_screenshots/"..ply:SteamID64()..".jpg", screenshot)

				byehax(ply:Name().."'s screenshot received ! Kicking. . .")
				byehax("The screenshot can be found in data/byehax_screenshots/"..ply:SteamID64()..".jpg")

				ply:Kick(byehax.config.kick_message)
			end,function(err)
				if (not ply) or (not IsValid(ply)) then return end

				byehax("Error while taking a screenshot of "..ply:Name()..": "..err) -- lmao
				ply:Kick(byehax.config.kick_message)
			end, 60)
			return
		end
		ply:Kick(byehax.config.kick_message)
		return
	end
	if pun == byehax.PunishmentType.Ban then
		byehax:Ban(ply, ply:SteamID64(), byehax.config.kick_message)
		return
	end

end

function byehax:Ban(ply, sid64, reason)
	byehax("Banning "..ply:Name())
	if byehax.config.ban_type == "source" then
		ply:Ban(byehax.config.ban_time, false)
		ply:Kick(reason)
	end
	if byehax.config.ban_type == "ULX" then
		ULib.ban(ply, byehax.config.ban_time, reason)
	end
	if byehax.config.ban_type == "SAM" then
		RunConsoleCommand("sam", "banid", ply:SteamID(), byehax.config.ban_time, reason)
	end
	if byehax.config.ban_type == "FADMIN" then
		RunConsoleCommand("_FAdmin", "ban", ply:SteamID(), "execute", byehax.config.ban_time, reason)
	end
	if byehax.config.ban_type == "gBan" then
		gBan:PlayerBan(nil, ply, byehax.config.ban_time, reason)
	end
	if byehax.config.ban_type == "MAESTRO" then
		maestro.ban(ply:SteamID(), byehax.config.ban_time, reason)
	end
	if byehax.config.ban_type == "ServerGuard" then
		serverguard:BanPlayer(nil, ply:SteamID(), byehax.config.ban_time, reason, nil, nil, "byehax Anti-Cheats")
	end
	if byehax.config.ban_type == "D3A" then
		if byehax.config.ban_time == 0 then
			RunConsoleCommand("d3a", "perma", ply, reason)
		else
			RunConsoleCommand("d3a", "ban", ply, byehax.config.ban_time, "minutes", reason)
		end
	end

end