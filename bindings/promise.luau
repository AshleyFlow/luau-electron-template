local bindings = require("@pkg/luau-electron-bindings")

export type Promise<T...> = bindings.Promise<T...>

return bindings.promise
