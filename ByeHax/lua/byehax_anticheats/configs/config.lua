
-- Maximum amount of time a player can take to join the server
byehax.config.max_join_time = 300

-- Maximum amount of time a player can take to send back a ping
byehax.config.max_ping_time = 60

-- Maximum angle per tick before being snapping
byehax.config.max_angle = 60

-- Maximum number of perfect bhops
byehax.config.max_bhops = 10

-- How many time a player can change steam name (0 = none)
byehax.config.max_steamname_changes = 4

-- Alert everyone when a cheater is detected
byehax.config.alert_everyone_on_det = true

-- Disable family sharing
byehax.config.disable_family_sharing = false
-- Only if owner is banned
byehax.config.df_only_onwer_banned = true

-- Disablow alt accounts
byehax.config.disablow_alt_accounts = false
-- Only if main is banned
byehax.config.da_only_main_banned = true

-- Try to block net backdoors
byehax.config.block_backdoors = true

-- Warn convars (Warn you if a bad ConVar has the bad value (ex: sv_cheats 1))
byehax.config.warn_convars = true

-- Message to kick cheater
byehax.config.kick_message = "Kicked by ByeHax\n Your account is blacklisted."

-- Cheater alert message
byehax.config.alert_message = "%name% thought h coudl cheat !"

-- Ban cheater with : ULX, SAM, FADMIN, MAESTRO, D3A, ServerGuard, gBan, source
byehax.config.ban_type = "ulx"

-- How much time to ban cheaters (0 = perma)
byehax.config.ban_time = 0

-- Try to fix CUserCmds modified by a cheat
byehax.config.fix_usercmd = true

-- Names of admin groups
byehax.config.admin_groups = {
	["superadmin"] = true,
	["admin"] = true,
}

-- Can admin bypass detections
byehax.config.admins_bypass = true

-- Take a screenshot when a player is kicked
byehax.config.take_screenshot = false

-- Detect foreign luas executed on a client
byehax.config.detect_foreign_lua = true

-- Log to console when a player is caching a file
byehax.config.fl_log_caching = false

-- Disable net verifier
byehax.config.disable_net_verifier = true

-- Test mode : Disable all detections
byehax.config.test_mode = (function()
	if GetHostName() == "SERVER FOR TESTING" then -- Detection on this server will be disabled
		return true
	end
	return false
end)()

-- Log detections
byehax.config.log_detection_to = "byehax_detections_logs.txt"

byehax.config.punishments = {
	["Client did not join in time"] = byehax.PunishmentType.Kick,
	["Client did not send ping back in time"] = byehax.PunishmentType.Kick,
	
	["Player is forging packets (Tick manipulation)"] = byehax.PunishmentType.Kick,
	["Player is forging packets (Autofire)"] = byehax.PunishmentType.Kick,
	["Player is forging packets (Autostrafe)"] = byehax.PunishmentType.Kick,
	["Player is forging packets (BunnyHop)"] = byehax.PunishmentType.Kick,
	["Player is forging packets (Snapping)"] = byehax.PunishmentType.Kick,
	["Player is forging packets (Snapping to player)"] = byehax.PunishmentType.Kick,
	["Player is forging packets (UseSpam)"] = byehax.PunishmentType.Kick,
	["Player is forging packets (FixMove)"] = byehax.PunishmentType.Kick,

	["byehax Client detected an anomaly"] = byehax.PunishmentType.Ban,
	["Foreign lua detected"] = byehax.PunishmentType.Kick,
	["Net messages could not be verified"] = byehax.PunishmentType.Kick,

	["CanVar has been tampered with"] = byehax.PunishmentType.Ban,

	["Player changed their steam name"] = byehax.PunishmentType.Kick,
	["Player changed their steam name too much"] = byehax.PunishmentType.Kick,

	["Player is using a family shared license"] = byehax.PunishmentType.Kick,
	["Player is using a banned family shared license"] = byehax.PunishmentType.Kick,

	["Player is using an alt account"] = byehax.PunishmentType.Kick,
	["Player is using a banned alt account"] = byehax.PunishmentType.Kick,

}

-- Disable client-side detections
byehax.config.enabled = {
	["Graphite"] = true,
	["Tampering with anticheats"] = true,
	["debug.sethook tampered with"] = true,
	["Lua:RunStringEx tampered with"] = true,
	["A function has been tampered with"] = true,
	["C++ interferences (EnginePrediction)"] = true,
	["C++ interferences (FunctionCall)"] = true,
	["Call from bad source"] = true
}

-- Native Client side functions
byehax.config.native_functions = {
	["debug.gethook"] = {type="advanced", args={}},
	["collectgarbage"] = {type="advanced", args={}},
	["debug.getinfo"] = {type="advanced", args={2}},
	["util.NetworkIDToString"] = {type="advanced", args={1}},
	["file.Time"] = {type="advanced", args={"platform/platform_misc_000.vpk", "BASE_PATH"}},
	["util.Compress"] = {type="advanced", args={"get compressed"}},
	["util.Decompress"] = {type="advanced", args={"get decompressed"}},
	["type"] = {type="advanced", args={"i am a string"}},

	["render.Capture"] = {type="simple"},
	["net.Start"] = {type="simple"},
	["net.SendToServer"] = {type="simple"},
	["timer.Simple"] = {type="simple"},
	["timer.Create"] = {type="simple"},
	["string.dump"] = {type="simple"},
	["table.insert"] = {type="simple"},
	["table.concat"] = {type="simple"},
	["pairs"] = {type="simple"},
}


byehax.config.protected_convars = {
	"sv_allowcslua",
	"sv_cheats"
}

byehax.config.thresholds = {
	fixmove_violations = 10,
	tickmanip_violations = 10,
	autofire_violations = 20,
	autostrafe_violations = 20,
	snap_violations = 20,
	usespam_violations = 20,
}