extends BaseObject

func _ready() -> void:
	dialog_tree = {
	"name": "repository",
	"variants": [],
	"default": {
		"text": "(There is a slot where battery cells can be inserted. The call button will send your deposit through a tube that leads to the reactor.)",
		"options": [
			{"name": "Insert Batteries [10]", "next": "repository01"},
			{"name": "Leave", "next": null}]
			},
	"repository01": {
		"text": "(The machine prints out a ticket.)[p][center]Thank you for your contribution.",
		"options": [
			{"name": "Leave", "next": null}]
			},
		}
	super._ready()
