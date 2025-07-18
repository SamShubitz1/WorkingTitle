extends BaseObject

func _ready() -> void:
	dialog_tree = {
	"name": "harvestrusty",
	"variants": [{
		"type": "default_variant",
		"flag": "harvest_rusty_powered",
		"branch": "powered01",
	}
	],
	"default": {
		"text": "An unpowered machine lies on the ground.",
		"options": [
			{"name": "Insert 100 cells", "next": "powered01"},
			{"name": "Leave", "next": "leave"}]
			},
	"powered01": {
		"text": "A nose to the air, neophyte. What do you smell?",
		"options": [
			{"name": "I smell nothing.", "next": "powered02"},
			{"name": "Leave", "next": "leave"}]
			},
	"powered02": {
		"text": "Precisely the problem. The algea farm's run down again. I was never designed for this! To be dealt failure after failure...I give up.",
		"options": [
			{"name": "Algea Farm.", "next": "powered03"},
			{"name": "Leave", "next": "leave"}]
			},
	"powered03": {
		"text": "He stuck this hat on my head and put me in charge of the algea vats and the steam furnace. Truth be told, I'm a numbers guy.",
		"options": [
			{"name": "Fixing the farm.", "next": "powered04"},
			{"name": "Leave", "next": "leave"}]
			},
	"powered04": {
		"text": "Hard part's doing it right. There's a delicate balance of pressure that needs to be maintained while filling the tanks or the growth accelerators can't do their thing. Once the furnace light goes green, the rest is automated.",
		"options": [
			{"name": "Chained Valve", "next": "chain01"},
			{"name": "Leave", "next": "leave"}]
			},
	"chain01": {
		"text": "That's just old world steel. You can break it with a pinch. I chained up the valve to discourage the runts and thumps.",
		"options": [
			{"name": "Leave", "next": "leave"}]
			},
	}
			
	super._ready()
