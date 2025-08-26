extends BaseRusty

func _ready() -> void:
	dialog_tree = {
	"name": "peddlin_rusty",
	"variants": [{
		"type": "default_variant",
		"flag": "peddlin_rusty_powered",
		"branch": "powered01",
	}
	],
	"default": {
		"text": "Come closer, neophyte. Let the Church of Rusty ease the surge that fires between your synapse. The spoils of Tabernacle are more brilliant than their shimmer.",
		"options": [
			{"name": "Church?", "next": "powered01"},
			{"name": "Trade", "next": "trade01"},
			{"name": "Leave", "next": null}]
			},
	"powered01": {
		"text": "More aptly, a commune, as it is. We had quite the flock before the reactor shut down. Creations are as free to wander as their maker. I chose to stay, neophyte. You know why?",
		"options": [
			{"name": "Why?", "next": "powered02"},
			{"name": "Leave", "next": null}]
			},
	"powered02": {
		"text": "It is calm here, isn't it? A quiet passage through time, where one can save themselves to watch the centuries sculpt our church of churches.",
		"options": [
			{"name": "Unpowered machines.", "next": "powered03"},
			{"name": "Church of churches.", "next": "powered04"},
			{"name": "Leave", "next": null}]
			},
	"powered03": {
		"text": "Hard times, neophyte. For all districts. But a peddler finds a way to keep the lights on.",
		"options": [
			{"name": "Leave", "next": null}]
			},
	"powered04": {
		"text": "The Church of Rusty is our genesis, neophyte. The trajectory of every blessed molecule on our planet can be traced back to Rusty.",
		"options": [
			{"name": "You are Rusty.", "next": "powered05"},
			{"name": "Leave", "next": null}]
			},
	"powered05": {
		"text": "I'm a shard of my father's primordial imagination, cut to purpose and used for grand designs. Father has a use for you as well. Go north. You will find him waiting, patient as the dooming tides of the cosmos.",
		"options": [
			{"name": "Leave", "next": null}]
			},
		}
	super._ready()
