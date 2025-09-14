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
	battle_data["terrain"] = {Data.BattleTerrain.BLOCKED: [Vector2i(4,1),Vector2i(5,1),Vector2i(6,1),Vector2i(7,1)]}
	super._ready()
