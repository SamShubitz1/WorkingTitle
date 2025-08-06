extends BaseObject

func _ready() -> void:
	dialog_tree = {
	"name": "newsboy",
	"variants": [{
		"type": "options_variant",
		"flag": "egg_charger_greeted",
		"branch": "newspaper2",
		"options": [
			{"name": "Egg Charger", "next": "eggcharger"},
			{"name": "Tram", "next": "tram"},
			{"name": "Leave", "next": null}]
				}, {
		"type": "next_variant",
		"flag": "newsboy_leave_attempted",
		"option_name": "Leave",
		"next": null}],
	"default": {
		"text": "(The Newsboy waves a scroll of printed paper in the air. His walkers have been crushed into broken twigs. An attempt was made to mend the hobbled legs back together but it looks like he gave up halfway through.)",
		"options": [
			{"name": ">", "next": "greeting"}]
			},
	"greeting": {
		"text": "Extra! Extra! Read all about it! Top Church hikes tithes! Dean of Denominations descends from Stovetop for tax collections!",
		"options": [
			{"name": "Proceed", "next": "stovetop"},
			{"name": "Leave", "next": "leave01"}]
			},
	"stovetop": {
		"text": "(The name 'Stovetop' exists in your dictionary. No definition or contextual data available.)",
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
		"options": [
			{"name": "Tram", "next": "tram"},
			{"name": "Leave", "next": null}]
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
			{"name": "Leave", "next": "leave01"}]
			},
	"leave01": {
		"text": "You'd take care not to head west, pal. The airfield's been run amok by a mad-wired bull!",
		"options": [
			{"name": "Broken Legs", "next": "leave02"},
			{"name": "Leave", "next": null}]
			},
	"leave02": {
		"text": "It was them miserable pilgrims that did me in like this. Said somethin’ about how buying my own batteries is blasphemy. Everything's blasphemy with them. All they ever do is damn the rest of us.",
		"options": [
			{"name": "Leave", "next": null}]
			},
		}
	super._ready()
