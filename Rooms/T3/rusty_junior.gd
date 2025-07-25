extends BaseObject

func _ready() -> void:
	dialog_tree = {
	"name": "rustyjunior",
	"variants": [{
		"type": "default_variant",
		"flag": "rusty_junior_powered",
		"branch": "powered01",
	}
	],
	"default": {
		"text": "An unpowered machine lies on the ground.",
		"options": [
			{"name": "Insert 50 cells", "next": "powered01"},
			{"name": "Leave", "next": null}]
			},
	"powered01": {
		"text": "asdf",
		"options": [
			{"name": "I smell nothing.", "next": "powered02"},
			{"name": "Leave", "next": null}]
			},
}
	super._ready()

func select_option():
	if dialog_box == null:
		return false
		
	var selected_dialog = dialog_box.select_option()
	if selected_dialog == null:
		dialog_box.queue_free()
		return false
	elif selected_dialog == "powered01":
		dialog_box.queue_free()
		game_controller.play_transition()
		sprite.play("powered")
		return false
	else:
		dialog_box.update_dialog(selected_dialog)
		return true
