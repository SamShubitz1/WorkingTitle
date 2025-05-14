extends AnimatedSprite2D

func _ready() -> void:
	play("idle")
	
func attack(duration: float) -> void:
	play("attack")
	await get_tree().create_timer(duration).timeout
	finish()
	
func finish() -> void:
	play("idle")
