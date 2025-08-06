extends BaseObject

func _ready() -> void:
	dialog_tree = {
	"name": "rounduprusty",
	"variants": [{
		"type": "default_variant",
		"flag": "roundup_rusty_powered",
		"branch": "powered01",
	}
	],
	"default": {
		"text": "An unpowered machine lies on the ground.",
		"options": [
			{"name": "Insert 100 cells", "next": "powered01"},
			{"name": "Leave", "next": null}]
			},
	"default02": {
		"text": "Howdy, stranger!",
		"options": [
			{"name": "Advice?", "next": "powered05"},
			{"name": "Light bulbs.", "next": "lightbulb01"},
			{"name": "Leave", "next": null}]
			},
	"powered01": {
		"text": "Caught me sleepin' on the job, didn't ya?",
		"options": [
			{"name": "I repowered you.", "next": "powered02"},
			{"name": "Leave", "next": null}]
			},
	"powered02": {
		"text": "Well, ain't I the damsel distressed? What the score, partner? Why the helping hand?",
		"options": [
			{"name": "The mechanical bull...", "next": "powered03"},
			{"name": "Leave", "next": null}]
			},
	"powered03": {
		"text": "Imma stop ya right there. You ain't pulled me up from the dirt just to get me kicked back down in it. Look at this chassis! That bull's kicked my plates in more times than I can count.",
		"options": [
			{"name": ">", "next": "powered04"}]
			},
	"powered04": {
		"text": "And I can count pretty high.",
		"options": [
			{"name": "Advice?", "next": "powered05"},
			{"name": "Leave", "next": null}]
			},
	"powered05": {
		"text": "You gotta take the bull down quick 'fore he starts gettin' *real* mad. If he does, I got a trick for that. But I need some old world light bulbs if there's any left lyin' around.",
		"options": [
			{"name": "Light bulbs.", "next": "lightbulb01"},
			{"name": "Leave", "next": null}]
			},
	"lightbulb01": {
		"text": "Let me see those for a minute. Think I got all the fixin's right here.",
		"options": [
			{"name": ">", "next": "lightbulb02"}]
			},
	"lightbulb02": {
		"text": "There ya go. When he starts gettin' mad, hit him with one of these.",
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
		dialog_box.queue_free()
		game_controller.play_transition()
		sprite.play("powered")
		return false
	else:
		dialog_box.update_dialog(selected_dialog)
		return true
