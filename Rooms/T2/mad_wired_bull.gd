extends BaseObject

class_name BaseNPC

@export var speed := 150
@export var move_cooldown := 5
@export var move_list := [Vector2i.LEFT, Vector2i.DOWN, Vector2i.RIGHT, Vector2i.UP]

@onready var sprite := $MadWiredBullSprite
@onready var player := get_node("/root/MainScene/Overworld/PlayerController")

var aggro_mode = false
var current_move_index = 0
var move_complete := false
var timer := 0.0

func _ready() -> void:
	super._ready()
	player.player_position_updated.connect(chase_player)

func _process(delta: float) -> void:
	if aggro_mode == false:
		patrol_character(delta)
	else:
		chase_player()
	
func patrol_character(delta) -> void:
	if move_complete: 
		set_npc_animation()
		timer += delta
		if timer >= move_cooldown:
			set_next_move()
	else: 
		move_character(delta)

	#if aggro_mode == true:
		#chase_player()
		
func chase_player() -> void:
	print(player_coords) ####NEEDS TO BE FIXED

func move_character(delta: float) -> void:
	set_npc_animation()
	var direction = move_list[current_move_index]
	var target_offset = direction * 2
	var dest_coords = self.grid_coords + target_offset

	if check_collision(dest_coords):
		return
	
	var dest_pos = map_controller.grid_to_point(dest_coords)

	self.position += direction * speed * delta
	
	map_controller.remove_from_world_map([self.grid_coords] + get_neighbor_coords())
	self.grid_coords = map_controller.point_to_grid(self.position)
	var next_coords = [grid_coords] + get_neighbor_coords()
	for coords in next_coords:
		map_controller.set_object_at_coords(self, coords)

	if move_is_complete(dest_pos, direction):
		complete_move(dest_pos)

func move_is_complete(dest_pos: Vector2, direction: Vector2i) -> bool:
	var diff := dest_pos - position
	match direction:
		Vector2i.DOWN:
			return diff.y <= 0
		Vector2i.UP:
			return diff.y >= 0
		Vector2i.RIGHT:
			return diff.x <= 0
		Vector2i.LEFT:
			return diff.x >= 0
		_:
			return false

func complete_move(dest_pos: Vector2) -> void:
	self.position = dest_pos
	self.grid_coords = map_controller.point_to_grid(position)
	
	var next_coords = [grid_coords] + get_neighbor_coords()
	for coords in next_coords:
		map_controller.set_object_at_coords(self, coords)

	move_complete = true

func set_next_move() -> void:
	move_complete = false
	timer = 0
	var last_coords = [grid_coords] + get_neighbor_coords()
	map_controller.remove_from_world_map(last_coords)
	current_move_index = (current_move_index + 1) % move_list.size()
	
func check_collision(dest_coords: Vector2i) -> bool:
	var object_coords = neighbor_coords.map(func(c): return dest_coords + c)
	for coords in object_coords:
		if map_controller.world_map.has(coords):
			return true
	return false

func get_neighbor_coords() -> Array:
	var direction = move_list[current_move_index]
	match direction:
		Vector2i.DOWN:
			var new_coords = neighbor_coords.map(func(c): return self.grid_coords + Vector2i(c.y, -c.x))
			return new_coords
		Vector2i.UP:
			var new_coords = neighbor_coords.map(func(c): return self.grid_coords + Vector2i(c.y, c.x))
			return new_coords
		Vector2i.LEFT:
			var new_coords = neighbor_coords.map(func(c): return self.grid_coords + Vector2i(-c.x, c.y))
			return new_coords
		Vector2i.RIGHT:
			var new_coords = neighbor_coords.map(func(c): return self.grid_coords + c)
			return new_coords
		_:
			return neighbor_coords
		
func set_npc_animation() -> void:
	var direction: Vector2 = move_list[current_move_index]
	var prefix: String
	if move_complete:
		prefix = "idle"
	else:
		prefix = "walk"
	
	var suffix: String
	match direction:
		Vector2.UP:
			suffix = "back"
		Vector2.DOWN:
			suffix = "front"
		Vector2.LEFT:
			sprite.flip_h = true
			suffix = "side"
		Vector2.RIGHT:
			sprite.flip_h = false
			suffix = "side"
	
	var name = prefix + "_" + suffix
	sprite.play(name)

func set_aggro_mode(should_set: bool) -> void:
	aggro_mode = should_set
