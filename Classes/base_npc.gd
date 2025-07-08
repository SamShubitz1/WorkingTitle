extends BaseObject

class_name BaseNPC

enum BehaviorMode
{
	CHASE,
	PATROL,
	RETURN,
	STAY
}

@export var chase_speed := 170
@export var patrol_speed := 90
@export var patrol_cooldown := 5
@export var move_list := [Vector2i.LEFT, Vector2i.DOWN, Vector2i.RIGHT, Vector2i.UP]
@export var number_of_tiles: int = 1

@onready var sprite := $NPCSprite

var range_limits: Dictionary

var behavior_mode: BehaviorMode = BehaviorMode.PATROL 
var current_move_index = 0
var move_complete := true
var timer := 0.0
var current_direction: Vector2i

var player_coords: Vector2i
var origin_coords: Vector2i

func _ready() -> void:
	super._ready()
	origin_coords = self.grid_coords
	set_npc_animation()
	
func _process(delta: float) -> void:
	match behavior_mode:
		BehaviorMode.STAY:
			return
		BehaviorMode.PATROL:
			patrol_character(delta)
		BehaviorMode.CHASE || BehaviorMode.RETURN:
			chase_target(delta)
		
	if behavior_mode == BehaviorMode.PATROL:
		patrol_character(delta)
	elif behavior_mode == BehaviorMode.CHASE || behavior_mode == BehaviorMode.RETURN:
		chase_target(delta)
	
func patrol_character(delta) -> void:
	if move_list.is_empty():
		return
		
	if move_complete: 
		set_npc_animation()
		timer += delta
		if timer >= patrol_cooldown:
			set_next_move()
	else: 
		move_character(delta)
	
func chase_target(delta) -> void:
	if move_complete:
		set_chase_direction()
		move_complete = false
	else:
		move_character(delta)
		
func set_chase_direction() -> void:
	var npc_grid_pos = map_controller.point_to_grid(self.position)
	
	var target_coords: Vector2i
	if behavior_mode == BehaviorMode.CHASE:
		target_coords = player_coords
	elif behavior_mode == BehaviorMode.RETURN:
		target_coords = origin_coords
		
	var delta: Vector2i = target_coords - npc_grid_pos
	var x_diff = abs(delta.x)
	var y_diff = abs(delta.y)

	if x_diff > y_diff:
		current_direction = Vector2i.RIGHT if delta.x > 0 else Vector2i.LEFT
	elif y_diff > x_diff:
		current_direction = Vector2i.DOWN if delta.y > 0 else Vector2i.UP
	else:
		current_direction = Vector2i.DOWN if delta.y > 0 else Vector2i.UP

func move_character(delta: float) -> void:
	set_npc_animation()
	
	var speed: int
	if behavior_mode == BehaviorMode.PATROL && move_list.is_empty():
		return
	elif behavior_mode == BehaviorMode.PATROL:
		speed = patrol_speed
		current_direction = move_list[current_move_index]
	else:
		speed = chase_speed
	
	var target_offset = current_direction * number_of_tiles
	var dest_coords = self.grid_coords + target_offset
			
	#if check_collision(dest_coords):
		#return
	
	var dest_pos = map_controller.grid_to_point(dest_coords)
	self.position += current_direction * speed * delta

	if move_is_complete(dest_pos):
		complete_move(dest_pos)

func move_is_complete(dest_pos: Vector2) -> bool:
	var diff := dest_pos - position
	match current_direction:
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
	map_controller.remove_from_world_map([self.grid_coords] + get_neighbor_coords())
	
	self.position = dest_pos
	self.grid_coords = map_controller.point_to_grid(position)
	
	var next_coords = [grid_coords] + get_neighbor_coords()
	for coords in next_coords:
		map_controller.set_object_at_coords(self, coords)
	
	check_range_limits()
	move_complete = true
	
func check_range_limits() -> void:
	if range_limits.is_empty():
		return
		
	var converted_x_range = map_controller.point_to_grid(Vector2i(range_limits["left"], range_limits["right"]))
	var converted_y_range = map_controller.point_to_grid(Vector2i(range_limits["top"], range_limits["bottom"]))
	
	if self.grid_coords == origin_coords && behavior_mode == BehaviorMode.RETURN:
		behavior_mode = BehaviorMode.PATROL
		return
		
	if self.grid_coords.x < converted_x_range.x || self.grid_coords.x > converted_x_range.y:
		behavior_mode = BehaviorMode.STAY
	elif self.grid_coords.y < converted_y_range.x || self.grid_coords.y > converted_y_range.y:
		behavior_mode = BehaviorMode.STAY

func set_next_move() -> void:
	move_complete = false
	timer = 0
	
	if move_list.is_empty():
		return
		
	current_move_index = (current_move_index + 1) % move_list.size()
	
func check_collision(dest_coords: Vector2i) -> bool:
	var object_coords = neighbor_coords.map(func(c): return dest_coords + c)
	for coords in object_coords:
		if map_controller.world_map.has(coords):
			return true
	return false

func get_neighbor_coords() -> Array:
	if move_list.is_empty():
		return []
		
	var direction = move_list[current_move_index]
	match direction:
		Vector2i.DOWN:
			return neighbor_coords.map(func(c): return self.grid_coords + Vector2i(c.y, -c.x))
		Vector2i.UP:
			return neighbor_coords.map(func(c): return self.grid_coords + Vector2i(-c.y, c.x))
		Vector2i.LEFT:
			return neighbor_coords.map(func(c): return self.grid_coords + Vector2i(-c.x, -c.y))
		Vector2i.RIGHT:
			return neighbor_coords.map(func(c): return self.grid_coords + c)
		_:
			return neighbor_coords.map(func(c): return self.grid_coords + c)
		
func set_npc_animation() -> void:
	if current_direction == Vector2i.ZERO:
		sprite.play("idle_side")
		return
		
	var prefix: String
	if move_complete:
		prefix = "idle"
	else:
		prefix = "walk"
	
	var suffix: String
	match current_direction:
		Vector2i.UP:
			suffix = "back"
		Vector2i.DOWN:
			suffix = "front"
		Vector2i.LEFT:
			sprite.flip_h = true
			suffix = "side"
		Vector2i.RIGHT:
			sprite.flip_h = false
			suffix = "side"
	
	var name = prefix + "_" + suffix
	sprite.play(name)

func set_aggro_mode(is_aggro: bool) -> void:
	if is_aggro:
		behavior_mode = BehaviorMode.CHASE
	else:
		behavior_mode = BehaviorMode.RETURN

func set_player_coords(coords: Vector2i):
	player_coords = coords
	print(" coords are " , coords)

func set_range_limits(limits: Dictionary):
	range_limits = limits
