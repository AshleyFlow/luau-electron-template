local app = require("../../../src/@utility/app")
local document = app.document

type Props = {
	on_click_callback: () -> (),
	parent: app.HTMLElement?,
}

return function(props: Props)
	local button = document.create_element("button", "Click").await()

	button:set_props({
		style = {
			width = "25%",
			borderRadius = "5px",
			transition = "scale 0.5s",
		},
	})

	button.set_event("onclick", props.on_click_callback)

	button.set_event("onmouseenter", function()
		button:set_props({
			style = {
				scale = "1.05",
			},
		})
	end)

	button.set_event("onmouseleave", function()
		button:set_props({
			style = {
				scale = "1",
			},
		})
	end)

	button.parent = props.parent

	return button
end
