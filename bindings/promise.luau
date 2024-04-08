local bindings = require("init")
export type Promise<T...> = bindings.Promise<T...>
return bindings.promise
