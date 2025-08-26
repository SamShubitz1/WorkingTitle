extends Node2D

@onready var rain_splash = $RainSplash
var splash_range: Vector2i

func _ready() -> void:
	splash_spawner()

func _process(delta) -> void:
	await splash_spawner()
	
func _set_splash_range(range: Vector2):
	
	splash_range = Vector2i(int(range.x * 32),int(range.y * 32))
	
func splash_spawner():
	var number_of_splashes = randi_range(2, 4) #randi_range(2, 4)
	var splash_timer = float(randi_range(1, 6)) * 0.1
		
	for i in range(number_of_splashes):
		var splash_range_x = randi_range(splash_range.x - 640, splash_range.x + 640)
		var splash_range_y = randi_range(splash_range.y - 384,splash_range.y + 384)
		var splash_duplicate = rain_splash.duplicate()
		self.add_child(splash_duplicate)
		splash_duplicate.visible = true
		splash_duplicate.position = Vector2(splash_range_x, splash_range_y)
		kill_splash(splash_duplicate)
	await get_tree().create_timer(splash_timer).timeout #splash_timer

func kill_splash(splash_duplicate: AnimatedSprite2D) -> void:
	splash_duplicate.play("RainSplash")
	await get_tree().create_timer(.4).timeout
	splash_duplicate.queue_free()
	
