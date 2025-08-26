extends BaseObject

func _ready() -> void:
	dialog_tree = {
	"name": "tram",
	"variants": [],
	"default": {
		"text": "This tram is trammin",
		"options": [
			{"name": "Leave", "next": null}
					]
				}
	}
	super._ready()
