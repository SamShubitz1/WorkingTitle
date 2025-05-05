############### NEWSBOY ###############

extends BaseNPC
var newspaper2_options = []

var dialog = {
			"default": {
				"text": "(The Newsboy rests against a waste receptacle as he waves a scroll of printed paper. His walkers have been broken into a pile of twigs. There was an attempt to mend the hobbled legs back together but it looks as though he gave up halfway through.)",
				"options": [
					{"name": "Proceed", "next": "greeting"},
					{"name": "Leave", "next": "leave01"}] ## Need to replace this as option after leave warning is displayed.
					},
			"greeting": {
				"text": "Extra! Extra! Read all about it! Top Church hikes tithes! Dean of Denominations descends from Stovetop for tax collections!",
				"options": [
					{"name": "Proceed", "next": "stovetop"},
					{"name": "Leave", "next": "leave01"}]
					},
			"stovetop": {
				"text": "(The name 'Stovetop' exists in your dictionary. No defintion or contextual data available.)",
				"options": [
					{"name": "From where?", "next": "stovetop2"},
					{"name": "Leave", "next": "leave01"}]
					},
			"stovetop2": {
				"text": "What's the matter, mista? Don't'cha read the paper?",
				"options": [
					{"name": "Take the paper", "next": "newspaper"},
					{"name": "Leave", "next": "leave01"}]
					},
			"newspaper": {
				"text": "(The headline of the paper reads 'Stovetop Officials Grace the Lowland Districts' and the subject reads 'Historic First! Top Dean Comes to Strengthen the Faith'.)",
				"options": [
					{"name": "Proceed", "next": "newspaper2"},
					{"name": "Leave", "next": "leave01"}]
					},
			"newspaper2": {
				"text": "Hey! That costs a two-cell, pal!",
				"options": newspaper2_options
					},
			"eggcharger": {
				"text": "The Egg Charger over there? No idea, pal. Are you gonna buy a paper or not?",
				"options": [
					{"name": "Tram", "next": "tram"},
					{"name": "Leave", "next": "leave01"}]
					},
			"tram": {
				"text": "That? Couldn't help ya, pal. Hasn't budged in years. Figured it was one of Top's pointless architectural displays. The whole city's taken by round shapes.",
				"options": [
					{"name": "Tram", "next": "tram"},
					{"name": "Leave", "next": "leave01"}]
					},
			"leave01": {
				"text": "You'd take care not to head east, pal. The airfield's been run amok by a mad-wired bull!",
				"options": [
					{"name": "Broken Legs", "next": "leave02"},
					{"name": "Leave", "next": null}]
					},
			"leave02": {
				"text": "It was them miserable pilgrims that did me in like this. Said somethin’ about how buying my own batteries is blasphemy. I tell ya, everything’s blasphemy with those bolt-heads. A bot’s got a right to live, don’t he?",
				"options": [
					{"name": "Leave", "next": null}]
					},
			}

# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()
	var neighbor_coords = Vector2i(grid_coords.x - 1, grid_coords.y)
	map_controller.set_object_at_coords(self, neighbor_coords)
	resolve_options()
	dialog_tree = dialog


func get_flags():
	return []

func resolve_options() -> void:
	if PlayerFlags.flags.has("egg_charger_greeted"):
		newspaper2_options = [
					{"name": "Egg Charger", "next": "eggcharger"},
					{"name": "Tram", "next": "tram"},
					{"name": "Leave", "next": null}]
	else:
		newspaper2_options = [
					{"name": "Tram", "next": "tram"},
					{"name": "Leave", "next": null}]
	dialog.newspaper2.options = newspaper2_options
