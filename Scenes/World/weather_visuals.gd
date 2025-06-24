extends Node2D

@onready var rain_splash = $GPUParticles2D/RainSplash

func _ready() -> void:
	splash_spawner()


func splash_spawner():
	while true:
		var number_of_splashes = randi_range(2, 4) #randi_range(2, 4)
		var splash_timer = float(randi_range(2, 10)) * 0.1
		
		for i in range(number_of_splashes):
			var splash_range_x = randi_range(-640, 640)
			var splash_range_y = randi_range(-384, 384)
			var splash_duplicate = rain_splash.duplicate()
			$GPUParticles2D.add_child(splash_duplicate)
			splash_duplicate.visible = true
			splash_duplicate.position = Vector2(splash_range_x, splash_range_y)
		await get_tree().create_timer(1).timeout

func kill_splash(splash_duplicate: AnimatedSprite2D) -> void:
	splash_duplicate.play("RainSplash")
	await get_tree().create_timer(.4).timeout
	splash_duplicate.queue_free()
	
