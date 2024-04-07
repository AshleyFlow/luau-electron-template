local task = require("@lune/task")
local net = require("@lune/net")
local fs = require("@lune/fs")

export type Listener = (value: any) -> ()

local config = net.jsonDecode(fs.readFile("src/config.json")) :: {
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
local module = {
	listeners = {} :: { [string]: { Listener } },
}

serve_handle = net.serve(config.lunePort, function(req)
	if req.method == "POST" then
		if req.path == "/channel" then
			local listeners = module.listeners[ascii_to_str(req.headers.channel :: any)]

			if listeners then
				for _, callback in listeners do
					callback(net.jsonDecode(ascii_to_str(req.headers.value :: any)))
				end
			end
		elseif req.path == "/kill" then
			task.defer(serve_handle.stop)
		end
	end

	return {}
end)

return module
