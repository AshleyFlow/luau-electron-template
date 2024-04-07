local process = require("@lune/process")
local net = require("@lune/net")
local fs = require("@lune/fs")

local config_path = "src/config.json"
local config = net.jsonDecode(fs.readFile(config_path)) :: {
	lunePort: number,
	mainScript: string,
}

process.spawn("lune", {
	"build",
	config.mainScript,
})
