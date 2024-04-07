local task = require("@lune/task")

export type Promise<T...> = {
	andThen: (callback: (T...) -> ()) -> (),
	await: () -> T...,
}

type Resolve<T...> = (T...) -> ()

local module = {}

function module.new<T...>(promise: (res: Resolve<T...>) -> ()): Promise<T...>
	local callbacks: { (...any) -> () } = {}
	local resolved = false
	local resolved_value: { any }

	promise(function(...)
		resolved = true
		resolved_value = table.pack(...)

		for _, v in callbacks do
			v(table.unpack(resolved_value))
		end
	end)

	local self = {}

	self.andThen = function(callback)
		if resolved then
			callback(table.unpack(resolved_value))
		else
			table.insert(callbacks, callback)
		end
	end

	self.await = function(): T...
		local thread = coroutine.running()

		self.andThen(function(...)
			task.spawn(thread, ...)
		end)

		return coroutine.yield()
	end

	return self
end

return module
