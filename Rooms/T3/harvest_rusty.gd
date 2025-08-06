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
			{"name": "Leave", "next": null}]
			},
	"default02": {
		"text": "Greetings, stranger.",
		"options": [
			{"name": "Chained valve", "next": "chain01"},
			{"name": "Farm restored", "next": "farm01"},
			{"name": "Leave", "next": null}]
			},
	"powered01": {
		"text": "A nose to the air, neophyte. What can you smell?",
		"options": [
			{"name": "I smell nothing.", "next": "powered02"},
			{"name": "Leave", "next": null}]
			},
	"powered02": {
		"text": "Precisely the problem. The algea farm's run down again. I was never designed for this! To be dealt failure after failure...I give up.",
		"options": [
			{"name": "Algea Farm.", "next": "powered03"},
			{"name": "Leave", "next": null}]
			},
	"powered03": {
		"text": "He stuck this hat on my head and put me in charge of the algea vats and the steam furnace. Truth be told, I'm a numbers guy.",
		"options": [
			{"name": "Fixing the farm.", "next": "powered04"},
			{"name": "Leave", "next": null}]
			},
	"powered04": {
		"text": "Hard part's doing it right. It's a delicate balance of pressure that needs to be maintained while filling the tanks or else the growth accelerators can't do their thing.",
		"options": [
			{"name": ">", "next": "powered05"}]
			},
	"powered05": {
		"text": "If the furnace light blinks red, something's wrong. Once it goes green, you know you've done it right. After that, the rest is automated.",
		"options": [
			{"name": "Chained Valve", "next": "chain01"},
			{"name": "Leave", "next": null}]
			},
	"chain01": {
		"text": "I chained up the valve to discourage the runts and thumps. That's just old world steel. You can break it with a pinch. ",
		"options": [
			{"name": "Leave", "next": null}]
			},
	"farm01": {
		"text": "Smells like the algea farm is up and running. Good work. With the furnace burning, Tabernacle's pneumatics are back online. Hopefully for good this time.",
		"options": [
			{"name": "Leave", "next": null}]
			},
	}
			
	super._ready()

func select_option():
	if dialog_box == null:
		return false
		
	var selected_dialog = dialog_box.select_option()
	if selected_dialog == null:
		dialog_box.queue_free()
		return false
	elif selected_dialog == "powered01":
		PlayerFlags.flags["harvest_rusty_powered"] = true
		dialog_box.queue_free()
		game_controller.play_transition()
		sprite.play("powered")
		return false
	else:
		dialog_box.update_dialog(selected_dialog)
		return true
