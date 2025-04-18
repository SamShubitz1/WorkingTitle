extends Node2D

@onready var current_tile_map_layer: TileMapLayer = null
@export var TILE_SIZE: int = 16

func _ready():
	GameData.GlobalMapControllerRef = self
	load_room("res://Rooms/Stovetop/StovetopRoom.tscn")

# collection of map objects, keyed by grid-position vector
var world_map_array: Dictionary = {}

func get_current_tile_map_layer() -> TileMapLayer:
	var map_container = $"MapContainer".name
	var current_layer = $"MapContainer".get_child(0).get_child(0)
	var current_layer_lame = current_layer.name
	print("MapController - GetCurrentTileMapLayer: " + str(current_layer))
	return current_layer

# convert grid coords to stored-object
func get_object_at_coords(grid_coords: Vector2i) -> Node:
	if (not world_map_array.has(grid_coords)):
		return null
	var object = world_map_array[grid_coords]
	if object:
		return object
	return null

# store object reference at grid coords
func set_object_at_coords(object: Node, grid_coords: Vector2i):
	world_map_array[grid_coords] = object

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

# get collider count at grid coords
func check_grid_for_collider(grid_coords: Vector2i) -> bool:
	# bounds error checking
	if (grid_coords.x < 0 or grid_coords.y < 0):
		#TODO catch error for out-of-bounds array lookup for tilemap object
		print("ERROR: bad TileMap lookup coords: " + str(grid_coords))
		return true # exit for bad value

	# get tile at grid_coords
	var tile_data = current_tile_map_layer.get_cell_tile_data(grid_coords)
	if (tile_data == null):
		#TODO catch error for out-of-bounds array lookup for tilemap object
		print("ERROR: bad TileMap lookup coords: " + str(grid_coords))
		return true # exit for bad TileMap data
	# check tile for collider
	var collider_count = tile_data.get_collision_polygons_count(0)
	# return result: true = collider, false = no collider
	return collider_count

# add collider to specified tile
func add_grid_collider(grid_coords: Vector2i) -> void:
	print("Map_Controller: attempting to add collider at: " + str(grid_coords))
	# bounds error checking
	if (grid_coords.x < 0 or grid_coords.y < 0):
		#TODO catch error for out-of-bounds array lookup for tilemap object
		print("ERROR: bad TileMap lookup coords: " + str(grid_coords))
		return # exit for bad value

	# get tile at grid_coords
	var tile_data = current_tile_map_layer.get_cell_tile_data(grid_coords)
	if (tile_data == null):
		#TODO catch error for out-of-bounds array lookup for tilemap object
		print("ERROR: bad TileMap lookup coords: " + str(grid_coords))
		return # exit for bad TileMap data

	tile_data.add_collision_polygon(0)

	return

# convert grid coords to TileData object, properties
func get_tile_at_grid_coords(grid_coords: Vector2i) -> TileData:
	var tile: TileData = current_tile_map_layer.get_cell_tile_data(grid_coords)
	if (tile == null):
		#TODO catch error
		print("ERROR: Inspecting null tile at: " + str(grid_coords))
		return null
	return tile

# convert grid coords to atlas/palette-tile-coords
func get_tile_atlas_coords(grid_coords: Vector2i) -> Vector2i:
	var atlas_coords: Vector2i = current_tile_map_layer.get_cell_atlas_coords(grid_coords)
	if (atlas_coords == null): return Vector2i(0,0)
	return atlas_coords

# get dictionary/hashtable format report of various tile data at grid coords
#TODO bounds check for error
func get_world_tile_report(grid_coords: Vector2i) -> Dictionary:
	var tile: TileData = current_tile_map_layer.get_cell_tile_data(grid_coords)
	var atlas_coords: Vector2i = current_tile_map_layer.get_cell_atlas_coords(grid_coords)

	# get tile info
	var tile_report = {
		"world_coords": grid_to_point(grid_coords),
		"grid_coords": grid_coords,
		"colliders_count": tile.get_collision_polygons_count(0),
		"custom_data": tile.get_custom_data("layer_name"),
		"texture_origin": tile.texture_origin,
		"cell_atlas_coords": atlas_coords
	}

	return tile_report

# remove object reference from collection
func remove_object_from_map_collection(object: Node) -> void:
	for item in world_map_array.keys():
		if world_map_array[item] == object:
			world_map_array.erase(item)
			break
	print("MapController - no object to remove")

func destroy_room():
	var map_container = self.get_child(0)
	#var door_grid_ref = get_object_at_coords(point_to_grid(object.position))
	#remove_object_from_map_collection(door_grid_ref)
	world_map_array = {}
	map_container.get_child(0).queue_free()

func load_room(room_resource_path):
	if room_resource_path == null:
		return
	var map_container = self.get_child(0)
	# load map file
	var new_map_resource = load(room_resource_path)
	# instantiate map object
	var imported_new_map = new_map_resource.instantiate()
	# adopt map object to MapContainer
	map_container.add_child(imported_new_map)
	# update TileMapLayer reference
	current_tile_map_layer = imported_new_map.get_node("TileMapLayer")

func enter_door(object):
	destroy_room()
	load_room(object.door_destination)
