local ipc = require("ipc")
local promise = require("promise")
local task = require("@lune/task")

type HTMLElementRequested = {
	selector: string?,
	tagName: string?,
	id: number,
}

type Property = { [string]: Property | any }

export type HTMLElement = {
	id: number,
	set_prop: (property: string, value: any) -> (),
	set_props: (self: HTMLElement, properties: { [string]: Property | any }) -> (),
	set_event: (event: string, callback: () -> ()) -> () -> (),
	[string]: any,
}

local app = {}
app.reserved_id = 1
app.reserved_event_id = 1

local function is_table_a_html_element(element: any): boolean
	if element.is_element then
		return true
	end

	return false
end

local function create_html_element_from_id(id: number): HTMLElement
	local t: HTMLElement = {
		id = id,
		set_prop = function(k, v: HTMLElement | string | number)
			if typeof(v) == "table" and is_table_a_html_element(v) then
				v = v.id
			end

			ipc.send({
				type = "Method",
				method = "setProperty",
				headers = {
					id = id,
					k = k,
					v = v,
				},
			})
		end,
		set_props = function(self, props: { [string]: Property })
			for k, v in props do
				if typeof(v) == "table" then
					if is_table_a_html_element(v) then
						self.set_prop(k, v)
					else
						task.defer(function()
							ipc.send({
								type = "Method",
								method = "setNestedProperties",
								headers = {
									id = id,
									k = k,
									v = v,
								},
							})
						end)
					end
				else
					self.set_prop(k, v)
				end
			end
		end,
		set_event = function(event: string, callback: () -> ())
			local event_id = app.reserved_event_id
			app.reserved_event_id += 1

			ipc.send({
				type = "Method",
				method = "setEvent",
				headers = {
					id = id,
					event = event,
					eventId = event_id,
				},
			})

			local disconnect = ipc.on("event:" .. event_id, callback)

			return function()
				ipc.send({
					type = "Method",
					method = "disconnectEvent",
					headers = {
						id = id,
						event = event,
						eventId = event_id,
					},
				})

				disconnect()
			end
		end,
	}

	local mt = {
		__index = function(_, i)
			if i == "is_element" then
				return true
			end

			if rawget(t, i) then
				return rawget(t, i)
			else
				error("__index is not implemented yet.")
			end
		end,
		__newindex = function(_, i, v)
			if v == nil then
				if i == "parent" then
					t.set_prop(i, "null")
				else
					error(`Not allowed to set {i} to nil.`)
				end
			else
				t.set_prop(i, v)
			end
		end,
	}

	return setmetatable({}, mt) :: any
end

app.document = {}
app.document.querySelector = function(selector: string): promise.Promise<HTMLElement>
	ipc.send({
		type = "Method",
		method = "querySelector",
		headers = {
			selector = selector,
		},
	})

	return promise.new(function(res)
		ipc.invoke("querySelector", {
			selector = selector,
		}).andThen(function(info: HTMLElementRequested)
			app.reserved_id = info.id
			res(create_html_element_from_id(info.id))
		end)
	end)
end

app.document.create_element = function(tag_name: string, inner_html: string?): promise.Promise<HTMLElement>
	return promise.new(function(res)
		ipc.invoke("createElement", {
			tagName = tag_name,
			innerHTML = inner_html,
		}).andThen(function(info: HTMLElementRequested)
			res(create_html_element_from_id(info.id))
		end)
	end)
end

ipc.send({
	type = "Method",
	method = "ready",
	headers = {},
})

return app
