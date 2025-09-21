extends BaseNPC

func _ready() -> void:
	super._ready()
	set_battle_data()
	
func set_battle_data() -> void:
	battle_data.randomize = false
	set_terrain()
	set_enemy_pool()

func set_terrain() -> void:
	battle_data.terrain[Data.BattleTerrain.BLOCKED] = []
	for y in range(Data.grid_size.y):
		for x in range(Data.grid_size.x):
			if y != 1:
				battle_data.terrain[Data.BattleTerrain.BLOCKED].append(Vector2i(x,y))

func set_enemy_pool() -> void:
	battle_data.enemy_pool = [{"enemy": "Runt", "position": Vector2i(4,1)},{"enemy": "Runt", "position": Vector2i(5,1)},{"enemy": "Runt", "position": Vector2i(6,1)},{"enemy": "Runt", "position": Vector2i(7,1)}]
