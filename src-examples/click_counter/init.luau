local app = require("@utility/app")
local document = app.document
local body = document.querySelector("body").await()

body:set_props({
	style = {
		margin = "0",
		height = "100vh",
		display = "flex",
		flexDirection = "column",
		justifyContent = "center",
		alignItems = "center",
	},
})

local clicks = 0

local _, update_counter = require("components/counter")({
	parent = body,
	get_count = function()
		return `Clicks: {clicks}`
	end,
})

require("components/button")({
	parent = body,
	on_click_callback = function()
		clicks += 1
		update_counter()
	end,
})

return true
