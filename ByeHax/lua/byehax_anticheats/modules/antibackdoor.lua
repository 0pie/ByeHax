if not byehax.config.block_backdoors then return end
local _netReadString = net.ReadString
local _stringlen = string.len
local _CompileString = CompileString
local _isfunction = isfunction
local _debugTrace = debug.Trace
local _stringStartWith = string.StartWith
local _stringfind = string.find
function net.ReadString()
	local str = _netReadString()
	if _stringlen(str) <= 6 then
		return str
	end
	if _stringStartWith(str, "--") or _stringStartWith(str, "//") then
		if not _stringfind(str, "\n") then
			return str
		end
	end
	local func = _CompileString(str, "byehax-AntiBackdoor", false)
	if _isfunction(func) then
		byehax("Stopped LUA code from net, see stack trace :") -- bro tried to sneak lua code in 💀
		_debugTrace()
		return [==[--[[ [byehax Anti-Cheats] LUA code has been transmited tought net, if this is an error, disable the anti backdoor in the config file !]] ]==]
	end
	return str
end