extends BaseNPC

func set_terrain() -> void:
	battle_data.terrain[Data.BattleTerrain.BLOCKED] = []
	for y in range(Data.grid_size.y):
		for x in range(Data.grid_size.x):
			if y != 0:
				battle_data.terrain[Data.BattleTerrain.BLOCKED].append(Vector2i(x,y))

func set_enemy_pool() -> void:
	battle_data.enemy_pool.append("Runt")
