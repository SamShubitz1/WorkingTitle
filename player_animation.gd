extends AnimatedSprite2D

func _ready() -> void:
	play("idle")
	self.scale = Vector2(5,5)
	
func attack(duration: float) -> void:
	play("attack")
	await get_tree().create_timer(duration).timeout
	finish()
	
func finish() -> void:
	play("idle")
