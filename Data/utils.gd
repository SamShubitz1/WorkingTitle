extends Node

func get_neighbor_coords(origin_coords: Vector2i, shape: Data.AbilityShape, alliance: Data.Alliance, grid_size: Vector2i = Vector2i(8, 4)) -> Array[Vector2i]:
	var neighbor_coords: Array[Vector2i] = [origin_coords]
	match shape:
		GameData.AbilityShape.SINGLE:
			return neighbor_coords 
		GameData.AbilityShape.DOUBLEH:
			if alliance == Data.Alliance.HERO:
				if origin_coords.x + 1 < 4:
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
				if origin_coords.x < grid_size.x:
					neighbor_coords.append(Vector2i(origin_coords.x + 1, origin_coords.y))
				if origin_coords.x > 0:
					neighbor_coords.append(Vector2i(origin_coords.x - 1, origin_coords.y))
		GameData.AbilityShape.LINE:
			if alliance == Data.Alliance.HERO:
				var col_index = 0
				while col_index < grid_size.x:
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

func map_effect_type_to_string(effect_type: Data.EffectType) -> String:
	match effect_type:
		Data.EffectType.STATS:
			return "Stats"
		Data.EffectType.ATTRIBUTE:
			return "Attribute"
		Data.EffectType.AILMENT:
			return "Ailment"
		_:
			return ""

func map_special_stat_to_string(special_stat: Data.SpecialStat) -> String:
	match special_stat:
		Data.SpecialStat.AP:
			return "AP"
		Data.SpecialStat.HP:
			return "HP"
		Data.SpecialStat.ENERGY:
			return "Energy"
		Data.SpecialStat.AILMENTS:
			return "Ailments"
		Data.SpecialStat.MOVE_RANGE:
			return "Move Range"
		Data.SpecialStat.GUARD_RANGE:
			return "Guard Range"
		_:
			return ""
	
func map_attribute_to_string(attribute: Data.Attributes) -> String:
	match attribute:
		Data.Attributes.ARMOR:
			return "Armor"
		Data.Attributes.BATTERY:
			return "Battery"
		Data.Attributes.FLUX:
			return "Flux"
		Data.Attributes.MEMORY:
			return "Memory"
		Data.Attributes.OPTICS:
			return "Optics"
		Data.Attributes.SHIELDING:
			return "Shielding"
		Data.Attributes.MOBILITY:
			return "Mobility"
		Data.Attributes.STRENGTH:
			return "Strength"
		Data.Attributes.NONE:
			return "None"
		_:
			return ""
	
func map_ailment_to_string(ailment: Data.Ailments) -> String:
	match ailment:
		Data.Ailments.OVERHEATED:
			return "Overheated"
		Data.Ailments.CORRODED:
			return "Corroded"
		Data.Ailments.BLANKED:
			return "Blanked"
		Data.Ailments.CONCUSSED:
			return "Concussed"
		_:
			return ""
