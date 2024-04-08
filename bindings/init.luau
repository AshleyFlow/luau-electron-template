local bindings = require("@pkg/luau-electron-bindings")
local port = tonumber(require("@lune/process").args[1])
assert(typeof(port) == "number")
export type Promise<T...> = bindings.Promise<T...>
export type HTMLElement = bindings.HTMLElement
return bindings(port)
