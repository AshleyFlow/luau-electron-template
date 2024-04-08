local net = require("@lune/net")
local process = require("@lune/process")

export type Listener = (value: any) -> ()

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
	kill = function()
		-- ipc will take over this function
	end,
}

local port = tonumber(process.args[1])
assert(typeof(port) == "number", "port must be a number")

serve_handle = net.serve(port, function(req)
	if req.method == "POST" then
		if req.path == "/channel" then
			local listeners = module.listeners[ascii_to_str(req.headers.channel :: any)]

			if listeners then
				for _, callback in listeners do
					callback(net.jsonDecode(ascii_to_str(req.headers.value :: any)))
				end
			end
		elseif req.path == "/kill" then
			serve_handle.stop()
			module.kill()
		end
	end

	return {}
end)

return module
