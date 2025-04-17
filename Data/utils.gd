extends Node

func get_neighbor_coords(origin_coords: Vector2i, shape: Data.AbilityShape, alliance: Data.Alliance, grid_size: Vector2i = Vector2i(8, 4)) -> Array:
	var neighbor_coords = [origin_coords]
	match shape:
		GameData.AbilityShape.SINGLE:
			return neighbor_coords
		GameData.AbilityShape.DOUBLEH:
			if alliance == Data.Alliance.HERO:
				neighbor_coords.append(Vector2i(origin_coords.x + 1, origin_coords.y))
			if alliance == Data.Alliance.ENEMY:
				neighbor_coords.append(Vector2i(origin_coords.x - 1, origin_coords.y))
			return neighbor_coords
		GameData.AbilityShape.MELEE:
			return neighbor_coords
		GameData.AbilityShape.DIAMOND:
				if origin_coords.y < grid_size.y - 1:
					neighbor_coords.append(Vector2i(origin_coords.x, origin_coords.y + 1))
				if origin_coords.y > 0:
					neighbor_coords.append(Vector2i(origin_coords.x, origin_coords.y - 1))
				if alliance == Data.Alliance.HERO:
					if origin_coords.x < grid_size.x / 2 - 1:
						neighbor_coords.append(Vector2i(origin_coords.x + 1, origin_coords.y))
				else:
					if origin_coords.x < grid_size.x:
						neighbor_coords.append(Vector2i(origin_coords.x + 1, origin_coords.y))
				if origin_coords.x > 0:
						neighbor_coords.append(Vector2i(origin_coords.x - 1, origin_coords.y))
		GameData.AbilityShape.LINE:
			if alliance == Data.Alliance.HERO:
				var col_index = 0
				while col_index < grid_size.x / 2:
					if col_index != origin_coords.x:
						neighbor_coords.append(Vector2i(col_index, origin_coords.y))
					col_index += 1
			elif alliance == Data.Alliance.ENEMY:
				var col_index = origin_coords.x
				while col_index >= 0:
					if col_index != origin_coords.x:
						neighbor_coords.append(Vector2i(col_index, origin_coords.y))
					col_index -= 1
		GameData.AbilityShape.ALL:
			for x in grid_size.x / 2:
				for y in grid_size.y:
					var next_pos = Vector2i(x, y)
					if next_pos != origin_coords:
						neighbor_coords.append(Vector2i(x, y))
	return neighbor_coords
