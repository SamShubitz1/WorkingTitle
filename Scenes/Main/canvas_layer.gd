# FadeLayer.gd
extends CanvasLayer

@onready var fade_to_black: AnimatedSprite2D = $FadeToBlack

func play_transition():
	fade_to_black.visible = true
	fade_to_black.play()
	await get_tree().create_timer(1).timeout
	fade_to_black.stop()
	fade_to_black.visible = false
