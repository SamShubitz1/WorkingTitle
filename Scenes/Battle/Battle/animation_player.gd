extends AnimatedSprite2D

func _ready() -> void:
	self.scale = Vector2(4,4)
	self.hide()
	
func start(target_position: Vector2, z_index: int, animation: String) -> void:
	self.position = target_position
	self.z_index = z_index + 1
	self.show()
	self.play(animation)

func finish() -> void:
	self.stop()
	self.queue_free()
