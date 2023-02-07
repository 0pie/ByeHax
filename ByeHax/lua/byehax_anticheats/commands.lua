concommand.Add("byehax", function(ply, cmd, args)
	if not byehax.IsAdmin(ply) then
		--return
	end
	if #args <= 1 then
		return ply:ChatPrint("[byehax] Invalide command")
	end
	if args[1] == "getinfo" then
		if not args[2] then
			return ply:ChatPrint("[byehax] Please put the player id (find it in command 'status')")
		end
		local pn = Player(tonumber(args[2]))
		if not pn then
			return ply:ChatPrint("[byehax] Player not found")
		end
		local alts = byehax.GetSteamIDFromUIID(uiid, pn:SteamID())
		alts = byehax.FLToNormal(alts)
		ply:ChatPrint("[byehax] Information for player "..ply:Name().."("..ply:SteamID()..")")
		ply:ChatPrint("IP Address: "..pn:IPAddress())
		ply:ChatPrint("Install path: "..pn.byehax.jdata.install_path)
		ply:ChatPrint("Unique Install ID: "..pn.byehax.jdata.uiid)
		ply:ChatPrint("List of modules: "..table.concat(pn.byehax.jdata.modules, ", "))
		ply:ChatPrint("List of ALTs: "..table.concat(alts, ", "))
		ply:ChatPrint("List of binds: ")
		local cur = ""
		for k,v in pairs(pn.byehax.jdata.binds) do
			cur = cur .. ", ["..v[1].."]" .. v[2]
			if k % 8 == 0 then
				ply:ChatPrint(cur)
				cur = ""
			end
		end
	end
end)