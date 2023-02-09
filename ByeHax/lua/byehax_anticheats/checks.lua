if (byehax.config.ban_type == "ULX") and not ULib then
	byehax.config.ban_type = "source"
	byehax("ULib could not be found ! Changed banning engine to source !")
end
if (byehax.config.ban_type == "FADMIN") and not FAdmin then
	byehax.config.ban_type = "source"
	byehax("FADMIN could not be found ! Changed banning engine to source !")
end

if string.len(byehax.config.kick_message) > 255 then
	byehax("WARNING: 'kick_message' is too big (> 255), set to default value !")
	byehax.config.kick_message = "Account is convicted of cheating."
end
if string.len(byehax.config.alert_message) > 255 then
	byehax("WARNING: 'alert_message' is too big (> 255), set to default value !")
	byehax.config.alert_message = "%name% is a cheating cheater !"
end

local function clmap_val(field, min, max)
	if min and (byehax.config[field] < min) then
		byehax.config.max_join_time = min
		byehax("'"..field.."' was below "..min..". Changed '"..field.."' to "..min.."")
	end
	if max and (byehax.config[field] > max) then
		byehax.config.max_join_time = max
		byehax("'"..field.."' was above "..max..". Changed '"..field.."' to "..max.."")
	end
end

clmap_val("max_join_time", 30, 600)
clmap_val("max_ping_time", 10, 300)
clmap_val("max_angle", 45, 180)
clmap_val("max_bhops", 5)
clmap_val("ban_time", 0)
clmap_val("max_steamname_changes", 0)


if not file.IsDir("byehax_screenshots", "data") then
	file.CreateDir("byehax_screenshots")
end

if not string.EndsWith(byehax.config.log_detection_to, ".txt") then
	byehax("WARNING: 'log_detection_to' is not a writable file, changed to '"..byehax.config.log_detection_to..".txt'")
	byehax.config.log_detection_to = byehax.config.log_detection_to .. ".txt"
end

if byehax.config.warn_convars then
	timer.Create("byehax warn about the convars", 60 * 5, 0, function()
		if GetConVar("sv_cheats"):GetInt() == 1 then
			byehax("WARNING: 'sv_cheats' is set to 1")
		end
		if GetConVar("sv_allowcslua"):GetInt() == 1 then
			byehax("WARNING: 'sv_allowcslua' is set to 1")
		end
	end)
end

if byehax.config.test_mode then
	byehax("WARNING: Test mode is enabled, all punishments disabled !")
end

if CurTime() > 30 then
	byehax("Something strange happened... Dont use lua_openscript pls")
end
