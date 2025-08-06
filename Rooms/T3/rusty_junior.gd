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
	"default02": {
		"text": "You grace me? I am unworthy.",
		"options": [
			{"name": "Find any items?", "next": "items01"},
			{"name": "Leave", "next": null}]
			},
	"powered01": {
		"text": "Oh! Dearest me, I appear to be restored! If I had pockets, I'd empty 'em for you. If I had hands, I'd shake yours twice. But alas...I've only a heart full of static warmth.",
		"options": [
			{"name": "Your role?", "next": "powered02"},
			{"name": "Leave", "next": null}]
			},
	"powered02": {
		"text": "No one’s ever quite figured what I’m for. Least of all me. Unlikely to be of much use, I fear. I've no tools, nor torque. Just me little limbs and a loyal ticker.",
		"options": [
			{"name": "Items?", "next": "powered03"},
			{"name": "Leave", "next": null}]
			},
	"powered03": {
		"text": "Oh, goodness. How dreadfully sorry I am to deny you your due. Allow me to...unfasten my little latches, that you might retrieve your battery cells nestled in my chest.",
		"options": [
			{"name": "Nevermind.", "next": "powered04"},
			{"name": "Retrieve batteries.", "next": "powered05"},
			{"name": "Leave", "next": null}]
			},
	"powered04": {
		"text": "I could perhaps still be of use. My optics aren't licensed for anything but they are functional. I'll search the area for usefuls. Right this instance!",
		"options": [
			{"name": "Leave", "next": null}]
			},
	"powered05": {
		"text": "(The machine closes its optical vents and turns its head up, exposing its chest. You unbuckle the battery pack and retrieve your 50 cells.)",
		"options": [
			{"name": "Leave", "next": null}]
			},
	"items01": {
		"text": "No such luck. I won't last long outside the bounds of the church, so my search perimeter is limited.",
		"options": [
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
		PlayerFlags.flags["rusty_junior_powered"] = true
		dialog_box.queue_free()
		game_controller.play_transition()
		sprite.play("powered")
		return false
	else:
		dialog_box.update_dialog(selected_dialog)
		return true
