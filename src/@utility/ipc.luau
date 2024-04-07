local net = require("@lune/net")
local promise = require("promise")

local listeners: { [string]: { Listener } } = {}
local invoke_reserved_id = 1

type Listener = (value: any) -> ()

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

local function send(data: LuneData)
	print("@" .. net.jsonEncode(data) .. "\n")
end

local function on(channel: string, listener: Listener)
	if listeners[channel] == nil then
		listeners[channel] = {}
	end

	local index = #listeners[channel] + 1
	listeners[channel][index] = listener

	return function()
		listeners[channel][index] = nil

		if #listeners[channel] == 0 then
			listeners[channel] = nil
		end
	end
end

local function once(channel: string, listener: Listener)
	local disconnect
	disconnect = on(channel, function(...)
		disconnect()
		listener(...)
	end)

	return disconnect
end

local function invoke(method: string, headers: { [string]: any }): promise.Promise<any>
	headers.eventId = invoke_reserved_id
	invoke_reserved_id += 1

	local data: LuneInvokeData = {
		type = "Invoke",
		method = method,
		headers = headers,
	}

	send(data)

	return promise.new(function(res)
		once("invoke:" .. data.headers.eventId, function(...)
			res(...)
		end)
	end)
end

return {
	send = send,
	on = on,
	once = once,
	invoke = invoke,
	print = print,
	listeners = listeners,
}
