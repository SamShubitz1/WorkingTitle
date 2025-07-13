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
@export var patrol_move_list := [Vector2i.LEFT, Vector2i.DOWN, Vector2i.RIGHT, Vector2i.UP]
@export var number_of_tiles: int = 1

@onready var sprite := $NPCSprite

var range_limits: Dictionary

var behavior_mode: BehaviorMode = BehaviorMode.PATROL 
var patrol_move_index = 0
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
		BehaviorMode.CHASE:
			chase_target(delta)
		BehaviorMode.RETURN:
			chase_target(delta)
	
func patrol_character(delta) -> void:
	if patrol_move_list.is_empty():
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
		set_npc_animation()
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
		current_direction = Vector2i.DOWN if delta.y > 0 else current_direction

func move_character(delta: float) -> void:
	if behavior_mode == BehaviorMode.PATROL && patrol_move_list.is_empty():
		return
	
	var speed: int
	var dest_coords: Vector2i
	
	if behavior_mode == BehaviorMode.PATROL:
		speed = patrol_speed
		dest_coords = self.grid_coords + (current_direction * number_of_tiles)
	else:
		speed = chase_speed
		dest_coords = self.grid_coords + current_direction
	
	var is_out_of_range = check_range_limits(dest_coords)
	var dest_has_collision = check_collision(dest_coords)
	
	if is_out_of_range || dest_has_collision:
		move_complete = true
		behavior_mode = BehaviorMode.STAY
		return
	
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
	
	if self.grid_coords == origin_coords && behavior_mode == BehaviorMode.RETURN:
		patrol_move_index = 0
		behavior_mode = BehaviorMode.PATROL
	
	var next_coords = [grid_coords] + get_neighbor_coords()
	for coords in next_coords:
		map_controller.set_object_at_coords(self, coords)
	
	move_complete = true
	
func check_range_limits(dest_coords: Vector2i) -> bool:
	if range_limits.is_empty():
		return false
		
	var converted_x_range = map_controller.point_to_grid(Vector2i(range_limits["left"], range_limits["right"]))
	var converted_y_range = map_controller.point_to_grid(Vector2i(range_limits["top"], range_limits["bottom"]))

	if dest_coords.x < converted_x_range.x || dest_coords.x > converted_x_range.y:
		return true
	elif dest_coords.y < converted_y_range.x || dest_coords.y > converted_y_range.y:
		return true
	else:
		return false

func set_next_move() -> void:
	move_complete = false
	timer = 0
	
	if patrol_move_list.is_empty():
		return
		
	patrol_move_index = (patrol_move_index + 1) % patrol_move_list.size()
	current_direction = patrol_move_list[patrol_move_index]
	set_npc_animation()
	
func check_collision(dest_coords: Vector2i) -> bool:
	var tile_collision_check = map_controller.check_for_collider(dest_coords)
	var object_collision_check = map_controller.get_object_at_coords(dest_coords)
	
	if tile_collision_check || object_collision_check:
		return true
	else:
		return false

func get_neighbor_coords() -> Array:
	if patrol_move_list.is_empty():
		return []
		
	var direction = patrol_move_list[patrol_move_index]
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
		move_complete = true

func set_player_coords(coords: Vector2i):
	player_coords = coords

func set_range_limits(limits: Dictionary):
	range_limits = limits
