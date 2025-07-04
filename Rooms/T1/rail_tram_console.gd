extends BaseObject

func _ready() -> void:
	dialog_tree = {
	"name": "tram_console",
	"variants": [{
		"type": "options_variant",
		"flag": "tram_console_button_pressed",
		"branch": "default",
		"options": [
			{"name": "Call Button", "next": "trambutton02"},
			{"name": "Open Panel", "next": "panel01"},
			{"name": "Leave", "next": null}]}
		],
	"default": {
		"text": "(The screen on the tram console is off. Below the screen is a call button. Along the base of the console, its panel is ajar.)",
		"options": [
			{"name": "Call Button", "next": "trambutton01"},
			{"name": "Open Panel", "next": "panel01"},
			{"name": "Leave", "next": null}]
			},
	"trambutton01": {
		"text": "(No reaction. The railway station is unpowered.)",
		"options": [
			{"name": "Open Panel", "next": "panel01"},
			{"name": "Leave", "next": null}]
			},
	"trambutton02": {
		"text": "(The button clicks. Nothing happens. The railway station remains unpowered.)",
		"options": [
			{"name": "Open Panel", "next": "panel01"},
			{"name": "Leave", "next": null}]
			},
	"panel01": {
		"text": "(Inside is the housing for a battery stack but it's empty.)",
		"options": [
			{"name": "Insert Battery [500]", "next": "panel02"},
			{"name": "Leave", "next": null}]
			},
	"panel02": {
		"text": "You win!",
		"options": [
			{"name": "Insert Battery [500]", "next": "panel02"},
			{"name": "Leave", "next": null}]
			},
		}
	super._ready()
