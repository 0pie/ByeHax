local function AngleDiff(a, b)
	return Angle(math.abs(math.AngleDifference(a.p, b.p)), math.abs(math.AngleDifference(a.y, b.y)), math.abs(math.AngleDifference(a.r, b.r)))
end
local function RoundAngle(a)
	return Angle(math.floor(a.p), math.floor(a.y), math.floor(a.r))
end

local function IsTracePly(trace)
	return (trace.Entity and trace.Entity:IsPlayer())
end

local function IsSnaping(ply, cmd)
	local curr = cmd:GetViewAngles()
	local last = table.GetLastValue(ply.byehax.lastmovs)
	local diff = AngleDiff(curr, last.vang)
	if diff.y >= byehax.config.max_angle then
		return true
	end
	if diff.p >= byehax.config.max_angle then
		return true
	end
	return false
end

local function FixMove(ply, cmd)
	if ply.byehax.fixmove_violations == nil then
		ply.byehax.fixmove_violations = 0
	end
	if ply.byehax.fixmove_violations > byehax.config.thresholds.fixmove_violations then
		byehax:AddDetection(ply, "Player is forging packets (FixMove)", "VI="..ply.byehax.fixmove_violations)
	end
	if (math.abs(cmd:GetForwardMove()) > 10) or (math.abs(cmd:GetForwardMove()) > 10) then
		if (cmd:GetForwardMove() % 2) ~= 0 then
			ply.byehax.fixmove_violations = ply.byehax.fixmove_violations + 1
			if byehax.config.fix_usercmd then
				cmd:SetForwardMove(0)
			end
		end
		if (cmd:GetSideMove() % 2) ~= 0 then
			ply.byehax.fixmove_violations = ply.byehax.fixmove_violations + 1
			if byehax.config.fix_usercmd then
				cmd:SetSideMove(0)
			end
		end
	end
	if ply.byehax.fixmove_violations > 0 then
		ply.byehax.fixmove_violations = ply.byehax.fixmove_violations - 1
	end

end

local function TimeMachine(ply, cmd)
	local violations = 0
	local lasttick, lastcmd = 0,0
	for k,v in pairs(ply.byehax.lastmovs) do
		if v.cmdn <= lastcmd then
			violations = violations + 1
		end
		if v.tick <= lasttick then
			violations = violations + 1
		end
		if violations > byehax.config.thresholds.tickmanip_violations then
			if byehax.config.fix_usercmd then
				cmd:SetButtons(0)
			end
			byehax:AddDetection(ply, "Player is forging packets (Tick manipulation)", "VI="..violations)
		end
	end
end

local function AutoFire(ply, cmd)
	local violations = 0
	local prev = false
	for k,v in pairs(ply.byehax.lastmovs) do
		local fir = byehax.CUserCmd:IsFiring(v.btns)
		if (prev ~= fir) then
			violations = violations + 1
		end
		prev = fir
	end
	if violations > byehax.config.thresholds.autofire_violations then
		byehax:AddDetection(ply, "Player is forging packets (Autofire)", "VI="..violations)
	end
end


local function AutoStrafe(ply, cmd)
	local violations = 0
	local prev = false
	for k,v in pairs(ply.byehax.lastmovs) do
		if v.simv == 0 then continue end
		local cur = v.simv > 0

		if (prev ~= cur) then
			violations = violations + 1
		end

		prev = cur
	end
	if violations > byehax.config.thresholds.autostrafe_violations then
		if byehax.config.fix_usercmd then
			ply:SetVelocity(Vector(0, 0, 0))
		end
		byehax:AddDetection(ply, "Player is forging packets (Autostrafe)", "VI="..violations)
	end
end


local function BunnyHop(ply, cmd)
	if ply.byehax.bhop_violations == nil then ply.byehax.lastjump = false ply.byehax.bhop_violations = 0 end
	local jumping  = byehax.CUserCmd:IsJumping(cmd:GetButtons())
	local onground   = ply:IsOnGround()
	if onground and not jumping then
		if ply.byehax.bhop_violations ~= 0 then
			ply.byehax.bhop_violations = ply.byehax.bhop_violations - 1
		end
	end

	if onground and jumping then
		if not ply.byehax.lastjump then
			ply.byehax.bhop_violations = ply.byehax.bhop_violations + 1
		end
	end

	ply.byehax.lastjump = jumping
	if ply.byehax.bhop_violations > byehax.config.max_bhops then
		if byehax.config.fix_usercmd then
			cmd:SetButtons(0)
		end
		byehax:AddDetection(ply, "Player is forging packets (BunnyHop)", "VI="..ply.byehax.bhop_violations)
	end
end

local function SnapDetecor(ply, cmd)
	local violations = 0
	if ply.byehax.issnaping and IsTracePly(ply.byehax.ctrace) then
		if byehax.config.fix_usercmd then
			local last = ply.byehax.lastmovs[#ply.byehax.lastmovs - 5]
			cmd:SetViewAngles(last.vang)
		end
		return byehax:AddDetection(ply, "Player is forging packets (Snapping to player)", "")
	end
	for k,v in pairs(ply.byehax.lastmovs) do
		if (v.snap) then
			violations = violations + 1
		end
	end
	if violations > byehax.config.thresholds.snap_violations then
		byehax:AddDetection(ply, "Player is forging packets (Snapping)", "VI="..violations)
	end
end


local function UseSpam(ply, cmd)
	local violations = 0
	local prev = false
	for k,v in pairs(ply.byehax.lastmovs) do
		local cur = byehax.CUserCmd:IsUsing(v.btns)

		if (prev ~= cur) then
			violations = violations + 1
		end

		prev = cur
	end
	if violations > byehax.config.thresholds.usespam_violations then
		byehax:AddDetection(ply, "Player is forging packets (UseSpam)", "VI="..violations)
	end
end

hook.Add("StartCommand", "byehax StartCommand", function(ply, cmd)
	byehax.PlayerInitialSpawn(ply)
	if ply:IsBot() or not ply.byehax or not ply.byehax.inited then return end
	if ply:IsTimingOut() or (ply:PacketLoss() >= 80) then return end
	if cmd:IsForced() then return end

	ply.byehax.lastmovs = ply.byehax.lastmovs or {}

	ply.byehax.ctrace = util.TraceLine(util.GetPlayerTrace(ply))


	if table.Count(ply.byehax.lastmovs) > 40 then

		ply.byehax.issnaping = IsSnaping(ply, cmd)
		
		TimeMachine(ply, cmd)
		AutoFire   (ply, cmd)
		AutoStrafe (ply, cmd)
		BunnyHop   (ply, cmd)
		SnapDetecor(ply, cmd)
		UseSpam    (ply, cmd)
		FixMove    (ply, cmd)

		table.remove(ply.byehax.lastmovs, 1)
	end


	table.insert(ply.byehax.lastmovs, {
		tick = cmd:TickCount(),
		cmdn = cmd:CommandNumber(),
		vang = cmd:GetViewAngles(),
		btns = cmd:GetButtons(),
		simv = cmd:GetSideMove(),
		snap = ply.byehax.issnaping,
		trac = ply.byehax.ctrace,
		isog = ply:IsOnGround(),
	})


end)
