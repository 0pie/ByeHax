if (AVL.config.ban_type == "ULX") and not ULib then
	AVL.config.ban_type = "source"
	AVL("ULib could not be found ! Changed banning engine to source !")
end
if (AVL.config.ban_type == "FADMIN") and not FAdmin then
	AVL.config.ban_type = "source"
	AVL("FADMIN could not be found ! Changed banning engine to source !")
end

if string.len(AVL.config.kick_message) > 255 then
	AVL("WARNING: 'kick_message' is too big (> 255), set to default value !")
	AVL.config.kick_message = "Account is convicted of cheating."
end
if string.len(AVL.config.alert_message) > 255 then
	AVL("WARNING: 'alert_message' is too big (> 255), set to default value !")
	AVL.config.alert_message = "%name% is a cheating cheater !"
end

local function clmap_val(field, min, max)
	if min and (AVL.config[field] < min) then
		AVL.config.max_join_time = min
		AVL("'"..field.."' was below "..min..". Changed '"..field.."' to "..min.."")
	end
	if max and (AVL.config[field] > max) then
		AVL.config.max_join_time = max
		AVL("'"..field.."' was above "..max..". Changed '"..field.."' to "..max.."")
	end
end

clmap_val("max_join_time", 30, 600)
clmap_val("max_ping_time", 10, 300)
clmap_val("max_angle", 45, 180)
clmap_val("max_bhops", 5)
clmap_val("ban_time", 0)
clmap_val("max_steamname_changes", 0)


if not file.IsDir("avl_screenshots", "data") then
	file.CreateDir("avl_screenshots")
end

if not string.EndsWith(AVL.config.log_detection_to, ".txt") then
	AVL("WARNING: 'log_detection_to' is not a writable file, changed to '"..AVL.config.log_detection_to..".txt'")
	AVL.config.log_detection_to = AVL.config.log_detection_to .. ".txt"
end

if AVL.config.warn_convars then
	timer.Create("AVL warn about the convars", 60 * 5, 0, function()
		if GetConVar("sv_cheats"):GetInt() == 1 then
			AVL("WARNING: 'sv_cheats' is set to 1")
		end
		if GetConVar("sv_allowcslua"):GetInt() == 1 then
			AVL("WARNING: 'sv_allowcslua' is set to 1")
		end
	end)
end

if AVL.config.test_mode then
	AVL("WARNING: Test mode is enabled, all punishments disabled !")
end

if CurTime() > 30 then
	AVL("WTF ?! Did you lua_openscrit me or something ??")
end