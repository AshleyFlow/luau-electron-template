local bindings = require("@pkg/luau-electron-bindings")
local port = tonumber(require("@lune/process").args[1])

assert(typeof(port) == "number")
bindings.server.start_server(port)

return bindings.server
