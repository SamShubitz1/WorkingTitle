extends BaseObject

class_name BaseNPC

@export var speed := 150
@export var move_cooldown := 3
@export var move_list := [Vector2i.LEFT, Vector2i.DOWN, Vector2i.RIGHT, Vector2i.UP]

@onready var sprite := $AnimatedSprite2D

var current_move_index := 0
var move_complete := true
var timer := 0.0

func _process(delta: float) -> void:
	if move_complete:
		timer += delta
		if timer >= move_cooldown:
			move_complete = false
			timer = 0
	else:
		move_character(delta)

func move_character(delta: float) -> void:
	var direction = move_list[current_move_index]
	var target_offset = direction * 2
	var dest_coords = grid_coords + target_offset

	if check_collision(dest_coords):
		return
	
	var dest_pos = map_controller.grid_to_point(dest_coords) + Vector2(16, 16)  #temp? sprite offset

	position += direction * speed * delta

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
	var last_coords := [grid_coords] + neighbor_coords.map(func(c): return grid_coords + c)
	map_controller.remove_from_world_map(last_coords)
	
	self.position = dest_pos
	self.grid_coords = map_controller.point_to_grid(position)
	
	var next_coords := [grid_coords] + neighbor_coords.map(func(c): return grid_coords + c)
	for coords in next_coords:
		map_controller.set_object_at_coords(self, coords)
	
	current_move_index = (current_move_index + 1) % move_list.size()
	move_complete = true
	
func check_collision(dest_coords: Vector2i) -> bool:
	var object_coords = neighbor_coords.map(func(c): return dest_coords + c)
	for coords in object_coords:
		if map_controller.world_map.has(coords):
			return true
	return false
