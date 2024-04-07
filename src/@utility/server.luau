local task = require("@lune/task")
local net = require("@lune/net")
local ipc = require("ipc")
local fs = require("@lune/fs")

local extracted_string = string.match(debug.info(1, "sln"), '"([^"]+)"')
assert(extracted_string, "failed to get path of current running script")

local config_path = extracted_string:sub(0, #extracted_string - #"server.luau\\" - #"@utility") .. "config.json"
local config = net.jsonDecode(fs.readFile(config_path)) :: {
	lunePort: number,
	mainScript: string,
}

local function ascii_to_str(asciiTable: { number })
	local str = ""
	for _, ascii in ipairs(asciiTable) do
		str = str .. string.char(ascii)
	end
	return str
end

local serve_handle: net.ServeHandle
serve_handle = net.serve(config.lunePort, function(req)
	if req.method == "POST" then
		if req.path == "/channel" then
			local listeners = ipc.listeners[ascii_to_str(req.headers.channel :: any)]

			if listeners then
				for _, listener in listeners do
					listener(net.jsonDecode(ascii_to_str(req.headers.value :: any)))
				end
			end
		elseif req.path == "/kill" then
			task.defer(serve_handle.stop)
		end
	end

	return {}
end)

return {}
