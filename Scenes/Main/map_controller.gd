extends Node2D

@onready var Current_Tile_Map = $TileMapLayer

@export var GRID_CELL_SIZE_PX: int = 16

# collection of map objects, keyed by grid-position vector
var world_map_array = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

# convert grid coords to stored-object
func get_object_at_coords(grid_coords: Vector2i) -> Node:
	var object = world_map_array[grid_coords]
	if object:
		return object
	return null

# store object reference at grid coords
func set_object_at_coords(object: Node, grid_coords: Vector2i) -> bool:
	world_map_array[grid_coords] = object
	return true

# translate from world coords to grid coords
func point_to_grid(point_coords: Vector2i, img_offset: Vector2i = Vector2i(0,0)) -> Vector2i:
	var x = round((point_coords.x - img_offset.x) / GRID_CELL_SIZE_PX)
	var y = round((point_coords.y - img_offset.y) / GRID_CELL_SIZE_PX)
	return Vector2i(x,y)

# translate from grid coords to world coords
func grid_to_point(grid_coords: Vector2i, img_offset: Vector2i = Vector2i(0,0)) -> Vector2i:
	var x = round((grid_coords.x * GRID_CELL_SIZE_PX) + img_offset.x)
	var y = round((grid_coords.y * GRID_CELL_SIZE_PX) + img_offset.y)
	return Vector2i(x,y)

# get collider count at grid coords
func check_grid_for_collider(grid_coords: Vector2i) -> bool:
	if (grid_coords.x < 0 or grid_coords.y < 0):
		#TODO catch error for out-of-bounds array lookup for tilemap object
		print("ERROR: bad TileMap lookup coords: " + str(grid_coords))
		return true # exit for bad value

	# get tile at grid_coords
	var tile_data = Current_Tile_Map.get_cell_tile_data(grid_coords)
	if (tile_data == null):
		#TODO catch error for out-of-bounds array lookup for tilemap object
		print("ERROR: bad TileMap lookup coords: " + str(grid_coords))
		return true # exit for bad TileMap data
	# check tile for collider
	var collider_count = tile_data.get_collision_polygons_count(0)
	# return result: true = collider, false = no collider
	return collider_count

# convert grid coords to TileData object, properties
func get_tile_at_world_coords(grid_coords: Vector2i) -> TileData:
	var tile: TileData = Current_Tile_Map.get_cell_tile_data(grid_coords)
	if (tile == null):
		#TODO catch error
		print("ERROR: Inspecting null tile at: " + str(grid_coords))
		return null
	return tile

# convert grid coords to atlas/palette-tile-coords
func get_tile_atlas_coords(grid_coords: Vector2i) -> Vector2i:
	var atlas_coords: Vector2i = Current_Tile_Map.get_cell_atlas_coords(grid_coords)
	if (atlas_coords == null): return Vector2i(0,0)
	return atlas_coords

# get dictionary/hashtable format report of various tile data at grid coords
func get_world_tile_report(grid_coords: Vector2i) -> Dictionary:
	var tile: TileData = Current_Tile_Map.get_cell_tile_data(grid_coords)
	var atlas_coords: Vector2i = Current_Tile_Map.get_cell_atlas_coords(grid_coords)

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
