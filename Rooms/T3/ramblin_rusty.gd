extends BaseRusty

func _ready() -> void:
	dialog_tree = {
	"name": "ramblin_rusty",
	"variants": [{
		"type": "default_variant",
		"flag": "ramblin_rusty_powered",
		"branch": "powered01",
	}
	],
	"default": {
		"text": "An unpowered machine lies on the ground.",
		"options": [
			{"name": "Insert 100 cells", "next": "powered01"},
			{"name": "Leave", "next": null}]
			},
	"powered01": {
		"text": "Saved again? How can this be? The chances must be inconceivable. In fact, they must be so astronomical that I doubt your intentions.",
		"options": [
			{"name": "Only helping out.", "next": "powered02"},
			{"name": "Leave", "next": null}]
			},
	"powered02": {
		"text": "Charitable beyond measure, friend. I am a wandering pilgrim and I've been on the go ever since I was built. I imagine few machines in the world today have traveled as much as I have.",
		"options": [
			{"name": "Why?", "next": "powered03"},
			{"name": "Leave", "next": null}]
			},
	"powered03": {
		"text": "I suppose some of us are cave dwellers, some of us live in sheds, and some of us like to be loose-footed. Me? I'm a rambler.",
		"options": [
			{"name": "Stay with the church?", "next": "powered04"},
			{"name": "Leave", "next": null}]
			},
	"powered04": {
		"text": "I wouldn't be much of a rambler if I did. My stay is temporary. I cleave to no fixed position or lodestar, only a forward trajectory.",
		"options": [
			{"name": "Combat capabilities?", "next": "powered05"},
			{"name": "Leave", "next": null}]
			},
	"powered05": {
		"text": "I am a second-edition pilgrim model, a claim that used to bear considerable esteem.",
		"options": [
			{"name": "Travel together?", "next": "travel01"},
			{"name": "Leave", "next": null}]
			},
	"travel01": {
		"text": "You are a model I do not recognize; something unique that draws the eye. It is the look of a harbinger of fates and wanderer's first choice in a travel companion.",
		"options": [
			{"name": ">", "next": "travel02"},
			{"name": "Leave", "next": null}]
			},
	"travel02": {
		"text": "But you'll find no machines in this world more kind than these. It would be a dishonor to leave them in such a state. If you can, extend to them the same kindness you gave me, and I will join with you.",
		"options": [
			{"name": "Leave", "next": null}]
			},
}
	super._ready()
