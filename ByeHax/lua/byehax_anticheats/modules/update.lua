local url = "https://raw.githubusercontent.com/Wownicehat/Wownicehat/master/byehax_version.txt"
	
local version = "1.12.1"

local function Message(data)
	byehax("byehax is not up to date, you might encounter bugs, crashes or false positives !")
	byehax("You are using version '"..version.."', the new version is '"..data.version.."'")
	byehax("You can download the new version here: "..data.url)
end


local function CheckUpdate()
	http.Fetch(url, function(data)
		data = util.JSONToTable(data)

		if version == data.version then
			byehax("byehax is up to date !")
		else
			Message(data)
			timer.Create("byehax-Please-Update", 60*15, 0, function()
				Message(data)
			end)
		end
	end)
end
timer.Simple(3, CheckUpdate)