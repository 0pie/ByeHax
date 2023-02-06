concommand.Add("avl", function(ply, cmd, args)
	if not AVL.IsAdmin(ply) then
		--return
	end
	if #args <= 1 then
		return ply:ChatPrint("[AVL] Invalide command")
	end
	if args[1] == "getinfo" then
		if not args[2] then
			return ply:ChatPrint("[AVL] Please put the player id (find it in command 'status')")
		end
		local pn = Player(tonumber(args[2]))
		if not pn then
			return ply:ChatPrint("[AVL] Player not found")
		end
		local alts = AVL.GetSteamIDFromUIID(uiid, pn:SteamID())
		alts = AVL.FLToNormal(alts)
		ply:ChatPrint("[AVL Anti-Cheats] Information for player "..ply:Name().."("..ply:SteamID()..")")
		ply:ChatPrint("IP Address: "..pn:IPAddress())
		ply:ChatPrint("Install path: "..pn.avl.jdata.install_path)
		ply:ChatPrint("Unique Install ID: "..pn.avl.jdata.uiid)
		ply:ChatPrint("List of modules: "..table.concat(pn.avl.jdata.modules, ", "))
		ply:ChatPrint("List of ALTs: "..table.concat(alts, ", "))
		ply:ChatPrint("List of binds: ")
		local cur = ""
		for k,v in pairs(pn.avl.jdata.binds) do
			cur = cur .. ", ["..v[1].."]" .. v[2]
			if k % 8 == 0 then
				ply:ChatPrint(cur)
				cur = ""
			end
		end
	end
end)