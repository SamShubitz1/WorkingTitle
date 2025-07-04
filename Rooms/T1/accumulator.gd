extends BaseObject

func _ready() -> void:
	dialog_tree = {
	"name": "accumulator",
	"variants": [],
	"default": {
		"text": "It seems to be accumulating.",
		"options": [
			{"name": "Leave", "next": null}]
			},
	}
	super._ready()
