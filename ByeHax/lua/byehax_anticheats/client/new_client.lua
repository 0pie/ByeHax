
local banner_lines = string.Split([[
	byehax Anti-Cheats is loading. . .
		[DONE]
]], "\n")

for k,v in pairs(banner_lines) do
	MsgC(Color(255, 10, 10), v.."\n")
end

local g = table.Copy(_G)
local byehax = {}
byehax.report = {}

byehax.ulx_hooks = g.file.Exists("ulib/shared/hook.lua", "LUA")
if byehax.ulx_hooks then
	print("[byehax] ULib is present, using backup hooks")
end
byehax.localconfig = {
	net = "byehax_BE_COOKING",
	packet_limit = 54000
}
if g.util.NetworkStringToID(byehax.localconfig.net) == 0 then
	print("byehax Could not be initialized !")
	return
end


function byehax.Debug(data)
	g.print("[byehax] "..data)
end
function byehax.SendSignal(data)
	g.RunConsoleCommand("byehax_signalserver", data)
end
function byehax.RandomString(len)
	local res = ""
	for i = 1, len do
		res = res .. g.string.char(g.math.random(97, 122))
	end
	return res
end
function byehax.GetTableValue(gtbl, tbl)
	if g.isstring(tbl) then
		tbl = g.string.Split(tbl, ".")
	end
    local TBL = gtbl
    for k=1, #tbl do
        local v = tbl[k]
        if g.istable(TBL[v]) then
            TBL = TBL[v]
        elseif k == #tbl then
            return TBL[v]
        else
            return nil
        end
    end
    return nil
end

function byehax.SetTableValue(gtbl, tbl, value)
	if g.isstring(tbl) then
		tbl = g.string.Split(tbl, ".")
	end
    local TBL = gtbl
    for k=1, #tbl do
        local v = tbl[k]
        if k ~= #tbl then
            if TBL[v] == nil then
                TBL[v] = {}
                TBL = TBL[v]
            elseif g.istable(TBL[v]) then
                TBL = TBL[v]
            else
                return false
            end
        else
            TBL[v] = value
            return true
        end
    end
    return false
end

function byehax.Detect(det)
	byehax.report.Detections = byehax.report.Detections or {}
	g.table.insert(byehax.report.Detections, det)
end
function byehax.NetStarted(det)
	byehax.report.NetVerify = byehax.report.NetVerify or {}
	byehax.report.NetVerify[det] = true
end
byehax.luasent = {}
function byehax.LuaExecuted(det)
	byehax.report.LuaFunction = byehax.report.LuaFunction or {}
	if byehax.luasent[det.hash] then return end
	g.table.insert(byehax.report.LuaFunction, det)
end
function byehax.AddReport(field, data)
	byehax.report[field] = data
end
function byehax.FlushReport()
	local data = g.util.TableToJSON(byehax.report)
	byehax.report = {}
	if not data then return byehax.Debug("util.TableToJSON: nil") end
	data = g.util.Compress(data)
	if not data then return byehax.Debug("util.Compress: nil") end

	local limit = byehax.localconfig.packet_limit

	local nb = g.math.ceil(g.string.len(data) / limit)
	local parts = {}
	for i=1,nb do
		local min
		local max
		if i == 1 then
			min = i
			max = limit
		elseif i > 1 and i ~= parts then
			min = ( i - 1 ) * limit + 1
			max = min + limit - 1
		elseif i > 1 and i == parts then
			min = ( i - 1 ) * limit + 1
			max = len
		end
		local str = g.string.sub(data, min, max)
		g.table.insert(parts, str)
	end

	for k,v in g.pairs(parts) do
		g.timer.Simple((k-1) * 2, function()
			g.net.Start(byehax.localconfig.net)
			g.net.WriteBool(#parts == k)
			g.net.WriteData(v, #v)
			g.net.SendToServer()
		end)
	end
end

byehax.hooks = {}
function byehax.Hook(hi, hn, hf)
	if byehax.ulx_hooks then
		if g.string.StartWith(hi, "GMRUN:") or g.string.StartWith(hi, "GMCALL:") then
			hi = string.Replace(hi, "GMRUN:", "")
			hi = string.Replace(hi, "GMCALL:", "")
			hn = "_byehaxAC:"..hn
			hook.Add(hi, hn, hf)
			return
		end
	end
	byehax.hooks[hi] = byehax.hooks[hi] or {}
	byehax.hooks[hi][hn] = hf
end
function byehax.Unhook(hi, hn)
	if byehax.ulx_hooks then
		if g.string.StartWith(hi, "GMRUN:") or g.string.StartWith(hi, "GMCALL:") then
			hi = string.Replace(hi, "GMRUN:", "")
			hi = string.Replace(hi, "GMCALL:", "")
			hn = "_byehaxAC:"..hn
			hook.Remove(hi, hn)
			return
		end
	end
	byehax.hooks[hi] = byehax.hooks[hi] or {}
	byehax.hooks[hi][hn] = nil
end
function byehax.Call(evnt, ...)
	if not byehax.hooks[evnt] then return end
	for k,v in g.pairs(byehax.hooks[evnt]) do
		local a,b,c,d,e,f,g = v(...)
		if a then
			return a,b,c,d,e,f,g
		end
	end
end

function byehax.PreDetour(fn, func)
	local og = byehax.GetTableValue(_G, fn)
	if not og then byehax.Debug(fn.." not found") return false end
	local new = function(...)
		local a,b,c,d,e,f,g = func(og, ...)
		if a then
			return a,b,c,d,e,f,g
		end
		return og(...)
	end
	byehax.SetTableValue(_G, fn, new)
	if byehax.GetTableValue(_G, fn) == og then
		byehax.Debug(fn.." not set !")
		return false
	end
	return true
end

function byehax.GetBinds()
	local binds = {}
	for i=1,159 do
		local bind = g.input.LookupKeyBinding(i)
		if bind then
			local kkey = input.LookupBinding(bind)
			g.table.insert(binds, {kkey, bind})
		end
	end
	return binds
end

function byehax.GetInstallPath()
	if not g.util.RelativePathToFull then
		return "Unknown"
	end
	return g.util.RelativePathToFull("garrysmod_000.vpk")
end

function byehax.ExecInfo(func, ...)
	local lns = 0
	g.collectgarbage()
	local bcg = g.collectgarbage("count")
	g.debug.sethook(function()
		lns = lns + 1
	end, "l")
	func(...)
	g.debug.sethook()
	local acg = g.collectgarbage("count")
	return {
		lines = lns,
		garbadge = acg - bcg
	}
end

function byehax.CheckNative(fn, advanced, ...)
	local func = byehax.GetTableValue(g, fn)
	if not g.isfunction(func) then return end
	local info = g.debug.getinfo(func)
	if info.what ~= "C" then return false end
	local err = g.pcall(g.string.dump, func)
	if err ~= false then
		return false
	end
	if advanced then
		local info = byehax.ExecInfo(func, ...)
		if info.lines > 4 then
			return false
		end
	end
	return true
end

function byehax.HashFunctions(func)
	local finfo = g.jit.util.funcinfo(func)
	if finfo.addr then return "-1" end
	local sofar = {}
	for i=1,finfo.bytecodes - 1 do
		local ins, opt = g.jit.util.funcbc(func, i)
		g.table.insert(sofar, opt)
	end

	for i=1,100 do
		local vn = g.jit.util.funck(func, -i)
		if not vn then break end
		if g.type(vn) == "proto" then vn = "proto" end
		if g.type(vn) == "table" then vn = "table" end
		g.table.insert(sofar, vn)
	end
	return g.util.CRC(g.table.concat(sofar,","))
end

function byehax.CompileFuncData(func)
	local fi = g.jit.util.funcinfo(func)
	local tab = {
		hash = byehax.HashFunctions(func),
		linedefined = fi.linedefined or -1,
		lastlinedefined = fi.lastlinedefined or -1,
		bytecodes = fi.bytecodes or -1,
		source = fi.source or "!Invalid",
		currentline = fi.currentline or -1,
		type = g.type(func)
	}
	return tab
end

function byehax.GetCalling()
	return g.debug.getinfo(4)
end
function byehax.CalledFromC()
	local l = byehax.GetCalling()
	if l == nil then return true end
	return l.short_src == "[C]"
end

byehax.badsauces = {
	["sillyguy"] = true, ["dragondildos"] = true
}
function byehax.AddBadSauce(n)
	byehax.badsauces[n] = true
	byehax.ignoresources["@"..n] = true
	g.RunString("local function print()end print([[Why are you cheating !?]])", n)
end

function byehax.IsBadSauce()
	return byehax.badsauces[byehax.GetCalling()] or false
end

function byehax.SNE(fn)
	if fn then
		byehax.Detect("Tampering with anticheats")
	end
end

byehax.ignoresources = {}
byehax.PreDetour("RunString", function(og, script, source)
	source = source or "RunString"
	byehax.ignoresources["@"..source] = true
end)
byehax.PreDetour("RunStringEx", function(og, script, source)
	source = source or "RunString"
	byehax.ignoresources["@"..source] = true
end)
byehax.PreDetour("CompileString", function(og, script, source)
	byehax.ignoresources["@"..source] = true
end)


byehax.checkingfuncs = {
	"team.GetColor", "team.GetName",
	"file.Exists", "file.Read",
	"hook.Add", "hook.Remove",
	"timer.Create", "timer.Remove", "timer.Destroy", "timer.Simple",
	"concommand.Add", "concommand.Remove",
	"collectgarbage",
	"debug.getupvalue",
	"render.Capture",
	"surface.CreateFont", "surface.PlaySound",
	"gameevent.Listen",
	"vgui.Create",
	"RunConsoleCommand"
}

for k,v in pairs(byehax.checkingfuncs) do
	byehax.PreDetour(v, function()
		if byehax.CalledFromC() then
			byehax.Detect("C++ interferences (FunctionCall)")
		end
		if byehax.IsBadSauce() then
			byehax.Detect("Call from bad source")
		end

	end)
end

function byehax.ReAttach()
	g.jit.attach(function(trac)
		local d = byehax.CompileFuncData(trac)
		if byehax.ignoresources[d.source] then return end
		byehax.LuaExecuted(d)
	end, "bc")
end

if not byehax.ulx_hooks then
	byehax.PreDetour("hook.Call", function(og, evnt, gmtbl, ...)
		return byehax.Call("GMCALL:"..evnt, ...)
	end)
	byehax.PreDetour("hook.Run", function(og, evnt, ...)
		return byehax.Call("GMRUN:"..evnt, ...)
	end)
end
byehax.current_net_header = -1


byehax.PreDetour("net.ReadHeader", function(og)
	if byehax.current_net_header == -1 then
		return g.net.ReadHeader()
	end
	return byehax.current_net_header
end)

byehax.PreDetour("MsgC", function(og, a, b)
	if b == "[Graphite] " then
		byehax.Detect("Graphite")
	end
end)
local current_net = ""
byehax.PreDetour("net.Start", function(og, a, b)
	current_net = a
end)
byehax.PreDetour("net.SendToServer", function(og, a, b)
	byehax.NetStarted(current_net)
end)

byehax.Hook("GMCALL:InitPostEntity", "LockAndLoad", function()
	byehax.PreDetour("net.Incoming", function(og, len)
		byehax.current_net_header = g.net.ReadHeader()
		if g.util.NetworkIDToString(byehax.current_net_header) == byehax.localconfig.net then
			byehax.Call("byehax:NetIncoming", len - 16)
			return true
		end
	end)
	local p1 = g.file.Time("platform/platform_misc_000.vpk","BASE_PATH")
	local p2 = g.file.Time("platform/platform_misc_dir.vpk","BASE_PATH")
	byehax.AddReport("ClientReady", {
		uiid = p1 + p2,
		binds = byehax.GetBinds(),
		modules = g.file.Find("lua/bin/*", "GAME"),
		install_path = byehax.GetInstallPath(),
		os = g.jit.os,
		arch = g.jit.arch
	})
	local exinfo = byehax.ExecInfo(g.RunString, "local abab = {1, 2, 3}", "lua/includes/init.lua")
	if exinfo.lines <= 0 then
		byehax.Detect("debug.sethook tampered with")
	end
	if exinfo.lines > 50 then
		byehax.Detect("Lua:RunStringEx tampered with")
	end
	byehax.FlushReport()
	byehax.ReAttach()

	for i=1,80 do
		byehax.AddBadSauce("lua/"..byehax.RandomString(16)..".lua")
	end

	byehax.SNE(debug.setupvalue)
	byehax.SNE(debug.upvalueid)
	byehax.SNE(debug.upvaluejoin)

end)

byehax.Hook("byehax:NetIncoming", "ProcessData", function(len)
	local data = g.net.ReadData(len)
	data = g.util.Decompress(data)
	data = g.util.JSONToTable(data)
	for k,v in pairs(data) do
		byehax.Call("byehax:"..k, v)
	end
	byehax.FlushReport()
	byehax.ReAttach()
end)

byehax.Hook("byehax:Screenshot", "ProcessScreenshot", function()
	byehax.Hook("GMCALL:PostRender", "TakeScreenshot", function()
		byehax.Unhook("GMCALL:PostRender", "TakeScreenshot")
		local cap = g.render.Capture({
			format = "jpg",
			x = 0,
			y = 0,
			w = g.ScrW(),
			h = g.ScrH(),
			quality = 50
		})
		byehax.AddReport("Screenshot", cap)
	end)
end)

byehax.Hook("byehax:NotifyPlayer", "NotifyPlayer", function(notif)
	chat.AddText(Color(255, 0, 0), "[byehax]", Color(0, 0, 0), notif)
end)

byehax.Hook("byehax:SendLua", "RunLuaScript", function(scripts)
	for k,script in pairs(scripts) do
		g.RunString(script, "LuaCmd")
	end
end)

byehax.Hook("byehax:CheckConVars", "CheckConVars", function(data)
	local ret = {}
	for k,v in g.pairs(data) do
		ret[v] = g.GetConVar(v):GetInt()
	end
	byehax.AddReport("CheckConVars", ret)
end)

byehax.Hook("byehax:CheckFunctions", "CheckFunctions", function(data)
	local failed = {}
	for fname,info in g.pairs(data) do
		if info.type == "disabled" then continue end
		if info.type == "advanced" then
			if not byehax.CheckNative(fname, true, g.unpack(info.args)) then
				g.table.insert(failed, fname)
			end
		end
		if info.type == "simple" then
			if not byehax.CheckNative(fname) then
				g.table.insert(failed, fname)
			end
		end
	end
	byehax.AddReport("CheckFunctions", failed)
end)


local nb = 0
byehax.Hook("GMCALL:CreateMove", "DetectEnginePred", function()
	nb = nb + 1
end)
byehax.Hook("GMCALL:SetupMove", "DetectEnginePred", function()
	nb = nb - 1
end)

local violations = 0
local function DetectEnginePred()
	if nb <-1 then
		violations = violations + 1
	else
		if violations > 0 then
			violations = violations - 1
		end
	end

	g.timer.Simple(g.engine.TickInterval(), DetectEnginePred)
	if violations > 5 then
		violations = 0
		byehax.Detect ("C++ interferences (EnginePrediction)")
	end
	nb = 0
end
DetectEnginePred()

