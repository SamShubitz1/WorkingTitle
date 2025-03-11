extends AnimatedSprite2D

func _ready() -> void:
	self.scale = Vector2(4,4)
	self.hide()
	
func start_animation(target: Node, animation: String) -> void:
	self.show()
	self.position = target.position
	self.z_index = target.z_index + 1
	self.play(animation)

func stop_animation() -> void:
	self.stop()
	self.hide()
