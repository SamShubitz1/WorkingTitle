extends Node2D

@onready var current_tile_map_layer: TileMapLayer = null
@onready var map_container = self.get_child(0)
@export var TILE_SIZE: int = 32

func _ready():
	#GameData.GlobalMapControllerRef = self
	load_room("res://Rooms/Stovetop/StovetopRoom.tscn")


# collection of map objects, keyed by grid-position vector
var world_map: Dictionary = {}

# convert grid coords to stored-object
func get_object_at_coords(grid_coords: Vector2i) -> Node:
	if !world_map.has(grid_coords):
		return null
	var object = world_map[grid_coords]
	return object

# store object reference at grid coords
func set_object_at_coords(object: Node, grid_coords: Vector2i):
	world_map[grid_coords] = object

# translate from world coords to grid coords
func point_to_grid(point_coords: Vector2i, img_offset: Vector2i = Vector2i(0,0)) -> Vector2i:
	var x = round((point_coords.x - img_offset.x) / TILE_SIZE)
	var y = round((point_coords.y - img_offset.y) / TILE_SIZE)
	return Vector2i(x,y)

# translate from grid coords to world coords
func grid_to_point(grid_coords: Vector2i, img_offset: Vector2i = Vector2i(0,0)) -> Vector2:
	var x = round((grid_coords.x * TILE_SIZE) + img_offset.x)
	var y = round((grid_coords.y * TILE_SIZE) + img_offset.y)
	return Vector2(x,y)

func check_for_collider(grid_coords: Vector2i) -> bool:
	if grid_coords.x < 0 or grid_coords.y < 0:
		return true

	# get tile at grid_coords
	var tile_data = current_tile_map_layer.get_cell_tile_data(grid_coords)
	if tile_data == null:
		return true
		
	var collider_count = tile_data.get_collision_polygons_count(0)
	return collider_count
	return false

# add collider to specified tile
func add_collider(grid_coords: Vector2i) -> void:
	if grid_coords.x < 0 or grid_coords.y < 0:
		#TODO catch error for out-of-bounds array lookup for tilemap object
		return

	var tile_data = current_tile_map_layer.get_cell_tile_data(grid_coords)
	if tile_data == null:
		#TODO catch error for out-of-bounds array lookup for tilemap object
		return

	tile_data.add_collision_polygon(0)

func get_tile_at_coords(grid_coords: Vector2i) -> TileData:
	var tile: TileData = current_tile_map_layer.get_cell_tile_data(grid_coords)
	if tile == null:
		#TODO catch error
		return null
	return tile

# convert grid coords to atlas/palette-tile-coords
func get_tile_atlas_coords(grid_coords: Vector2i) -> Vector2i:
	var atlas_coords: Vector2i = current_tile_map_layer.get_cell_atlas_coords(grid_coords)
	if (atlas_coords == null): return Vector2i(0,0)
	return atlas_coords
	
#func get_current_tile_map_layer() -> TileMapLayer:
	#var map_container = get_child(0)
	#var current_layer = map_container.get_child(0).get_child(0)
	#var current_layer_name = current_layer.name
	#return current_layer

#TODO bounds check for error
#func get_world_tile_report(grid_coords: Vector2i) -> Dictionary:
	#var tile: TileData = current_tile_map_layer.get_cell_tile_data(grid_coords)
	#var atlas_coords: Vector2i = current_tile_map_layer.get_cell_atlas_coords(grid_coords)
	#if !tile:
		#return {}
	## get tile info
	#var tile_report = {
		#"world_coords": grid_to_point(grid_coords),
		#"grid_coords": grid_coords,
		#"colliders_count": tile.get_collision_polygons_count(0),
		#"custom_data": tile.get_custom_data("layer_name"),
		#"texture_origin": tile.texture_origin,
		#"cell_atlas_coords": atlas_coords
	#}
#
	#return tile_report

func remove_from_world_map(object: Node) -> void:
	for item in world_map.keys():
		if world_map[item] == object:
			world_map.erase(item)
			break

func kill_room():
	world_map = {}
	var map_container = self.get_child(0)
	map_container.get_child(0).queue_free()

func load_room(room_resource_path):
	if room_resource_path == null:
		return

	var new_map_resource = load(room_resource_path)
	var imported_new_map = new_map_resource.instantiate()
	
	var map_container = self.get_child(0)
	map_container.add_child(imported_new_map)
	current_tile_map_layer = imported_new_map.get_node("TileMapLayer")

func enter_door(object):
	kill_room()
	load_room(object.door_destination)

func init(data: Dictionary) -> void:
	pass
