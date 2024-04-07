local net = require("@lune/net")
local promise = require("promise")
local server = require("server")

local module = {}
module.invoke_reserved_id = 1

type LuneMethodData = {
	type: "Method",
	method: string,
	headers: {
		[string]: any,
	},
}

type LuneInvokeData = {
	type: "Invoke",
	method: string,
	headers: {
		eventId: number,
		[string]: any,
	},
}

type LuneData = LuneMethodData | LuneInvokeData

function module.send(data: LuneData)
	print("@" .. net.jsonEncode(data) .. "\n")
end

function module.on(channel: string, listener: server.Listener)
	if server.listeners[channel] == nil then
		server.listeners[channel] = {}
	end

	local index = #server.listeners[channel] + 1
	server.listeners[channel][index] = listener

	return function()
		server.listeners[channel][index] = nil

		if #server.listeners[channel] == 0 then
			server.listeners[channel] = nil
		end
	end
end

function module.once(channel: string, listener: server.Listener)
	local disconnect
	disconnect = module.on(channel, function(...)
		disconnect()
		listener(...)
	end)

	return disconnect
end

function module.invoke(method: string, headers: { [string]: any }): promise.Promise<any>
	headers.eventId = module.invoke_reserved_id
	module.invoke_reserved_id += 1

	local data: LuneInvokeData = {
		type = "Invoke",
		method = method,
		headers = headers,
	}

	module.send(data)

	return promise.new(function(res)
		module.once("invoke:" .. data.headers.eventId, function(...)
			res(...)
		end)
	end)
end

module.invoke_listeners = function(channel: string)
	print("net.serve", tostring(server.listeners))

	local channel_listeners = server.listeners[channel]

	if not channel_listeners then
		return
	end

	for _, callback in channel_listeners do
		callback()
	end
end

return module
