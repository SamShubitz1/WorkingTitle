extends BaseObject

func _ready() -> void:
	dialog_tree = {
	"name": "norm",
	"variants": [],
	"default": {
		"text": "I'm Norm",
		"options": [
			{"name": "OK", "next": "..."},
			{"name": "Leave", "next": null}]
			},
	"...": {
		"text": "...",
		"options": [
			{"name": "Leave", "next": null}]
			}
	}
	super._ready()
