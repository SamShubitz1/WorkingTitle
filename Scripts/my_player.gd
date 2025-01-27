extends CharacterBody2D

var speed: int = 100
var positionDirty = false
var destination_grid_x: int = 2
var destination_grid_y: int = 2
var player_grid_x: int = 2
var player_grid_y: int = 2
var player_offset_x: int = 8
var player_offset_y: int = 8
var grid_pixel_size: int = 16
var direction = "none"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# set player initial position
	#position.x = 0
	#position.y = 0
	update_player_grid_coords()
	$AnimatedSprite2D.play("idle_down")
	#print("current player position: " + str(position.x) + ", " + str(position.y))
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_pressed("testbutton"):
		position.x = 56
	move_player(delta)
	process_player_inputs()
	pass

func process_player_inputs() -> void:
	if positionDirty:
		return

	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	if Input.is_action_pressed("ui_up"):
		input_dir.x = 0
		positionDirty = true
		destination_grid_y -= 1
		$AnimatedSprite2D.play("walk_up")
		direction = "up"
	elif Input.is_action_pressed("ui_down"):
		input_dir.x = 0
		positionDirty = true
		destination_grid_y += 1
		$AnimatedSprite2D.play("walk_down")
		direction = "down"
	elif Input.is_action_pressed("ui_left"):
		input_dir.y = 0
		positionDirty = true
		destination_grid_x -= 1
		$AnimatedSprite2D.play("walk_side")
		$AnimatedSprite2D.flip_h = true
		direction = "left"
	elif Input.is_action_pressed("ui_right"):
		input_dir.y = 0
		positionDirty = true
		destination_grid_x += 1
		$AnimatedSprite2D.play("walk_side")
		$AnimatedSprite2D.flip_h = false
		direction = "right"

	velocity = input_dir * speed

	return # end process_player_inputs()

func move_player(delta) -> void:
	if not positionDirty:
		return
	var collision = move_and_collide(velocity * delta)

	# update grid coords
	update_player_grid_coords()

	if (direction == "left" and position.x-1 <= ((destination_grid_x * grid_pixel_size) + player_offset_x)) or (direction == "right" and position.x+1 >= ((destination_grid_x * grid_pixel_size) + player_offset_x)):
		position.x = round((destination_grid_x * grid_pixel_size) + player_offset_x)
		position.y = round((destination_grid_y * grid_pixel_size) + player_offset_y)
		positionDirty = false
		$AnimatedSprite2D.play("idle_side")
		if direction == "left":
			$AnimatedSprite2D.flip_h = true
		player_grid_x = destination_grid_x
		player_grid_y = destination_grid_y

	elif (direction == "up" and position.y-1 <= ((destination_grid_y * grid_pixel_size) + player_offset_y)) or (direction == "down" and position.y+1 >= ((destination_grid_y * grid_pixel_size) + player_offset_y)):
		position.x = round((destination_grid_x * grid_pixel_size) + player_offset_x)
		position.y = round((destination_grid_y * grid_pixel_size) + player_offset_y)
		positionDirty = false
		$AnimatedSprite2D.play("idle_" + direction)
		player_grid_x = destination_grid_x
		player_grid_y = destination_grid_y

	# check if at destination
	#if player_grid_x == destination_grid_x and player_grid_y == destination_grid_y:
		#positionDirty = false
		#$AnimatedSprite2D.play("idle_down")
		#print("player grid spot: " + str(player_grid_x) + ", " + str(player_grid_y))
		#player_grid_x = destination_grid_x
		#player_grid_y = destination_grid_y

		#position.x = (player_grid_x + player_offset_x) * grid_pixel_size
		#position.y = (player_grid_y + player_offset_y) * grid_pixel_size

	if collision != null:
		positionDirty = false
		destination_grid_x = player_grid_x
		destination_grid_y = player_grid_y
		position.x = round(position.x)
		position.y = round(position.y)
		
		var normal = collision.get_normal()
		if normal.x < 0:
			$AnimatedSprite2D.play("idle_side")
		elif normal.x > 0:
			$AnimatedSprite2D.play("idle_side")
			$AnimatedSprite2D.flip_h = true;
		elif normal.y < 0:
			$AnimatedSprite2D.play("idle_down")
		elif normal.y > 0:
			$AnimatedSprite2D.play("idle_up")

	return # end move_player()

func update_player_grid_coords() -> void:
	player_grid_x = round((position.x - player_offset_x) / grid_pixel_size)
	player_grid_y = round((position.y - player_offset_y) / grid_pixel_size)
	#print("update player grid ran: " + str(player_grid_x) + ", " + str(player_grid_y))
	pass
