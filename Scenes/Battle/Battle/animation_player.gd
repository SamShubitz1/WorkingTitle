extends AnimatedSprite2D

func _ready() -> void:
	self.scale = Vector2(4,4)
	
func start(animation: Dictionary, current_player: Character, target: Character, alliance: Data.Alliance) -> void:
	if alliance == Data.Alliance.ENEMY:
		self.flip_h = true
	
	var target_position: Vector2i
	if animation.origin == Data.AnimOrigin.OTHER:
		target_position = target.positiona
	elif animation.origin == Data.AnimOrigin.SELF:
		target_position = current_player.position
	if animation.has("offset") && alliance == Data.Alliance.ENEMY:
		target_position.x -= animation.offset
	elif animation.has("offset") && alliance == Data.Alliance.HERO:
		target_position.x += animation.offset
			
	self.position = target_position
	self.z_index = z_index + 1
	self.play(animation.name)

	await get_tree().create_timer(animation.duration).timeout
	finish()

func finish() -> void:
	self.queue_free()
	
func display_digit(digit: int, offset: Vector2i) -> void:
	self.z_index = z_index + 1
	self.animation = "Digits"
	self.frame = digit
	self.position = offset
	
	var duration = 10
	for i in duration:
		self.position.y -= 8
		self.modulate.a -= .1
		await get_tree().create_timer(0.1).timeout
		
