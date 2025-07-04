extends BaseObject

func _ready() -> void:
	dialog_tree = {
	"name": "eggcharger",
	"variants": [],
	"default": {
		"text": "(A broken egg charger machine. Though the shell is cracked open, its battery vault remains securely locked in place.)",
		"options": [
			{"name": "Investigate", "next": "investigate"},
			{"name": "Leave", "next": null}]
			},
	"investigate": {
		"text": "This egg is crazy.",
		"options": [
			{"name": "Take egg", "next": "take egg"},
			{"name": "Investigate", "next": "investigate2"},
			{"name": "Interrogate", "next": "interrogate"},
			{"name": "Leave", "next": null}]	
			},
	"investigate2": {
		"text": "It's not that crazy actually.",
		"options": [
			{"name": "Take egg", "next": "take egg"},
			{"name": "Interrogate", "next": "interrogate"},
			{"name": "Leave", "next": null}]
			},
	"interrogate": {
		"text": "The egg is silent.",
		"options": [
			{"name": "Investigate", "next": "investigate"},
			{"name": "Interrogate", "next": "interrogate2"},
			{"name": "Leave", "next": null}]
			},
	"interrogate2": {
		"text": "The egg remains stoic.",
		"options": [
			{"name": "Take egg", "next": "take egg"},
			{"name": "Leave", "next": null}]
			},
	"take egg": {
		"text": "You took the egg.",
		"options": [
			{"name": "Leave", "next": null}]
			},
	}
	super._ready()
