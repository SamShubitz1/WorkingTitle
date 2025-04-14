extends Node

class_name Data

var GlobalMapControllerRef = 1

enum MainMenuType {
	MAIN,
	POKEDEX
}

enum BattleMenuType {
	OPTIONS,
	ABILITIES,
	ITEMS,
	TARGETS,
	LOG,
	MOVEMENT,
	PASS_TURN
}

enum MenuType {
	MainMenuType,
	BattleMenuType
}

enum AbilityType {
	ATTACK,
	EFFECT
}

enum DamageType {
	PHYSICAL,
	ENERGY,
	NONE
}

enum TargetType {
	HERO,
	ENEMY,
}

enum AbilityShape {
	SINGLE,
	LINE,
	SQUARE,
	DIAMOND,
	MELEE,
	MULTIPLE,
	COLUMN,
	ALL
}

enum Alliance {
	HERO,
	ENEMY
}

enum Attributes {
	STRENGTH,
	FLUX,
	ARMOR,
	SHIELDING,
	MEMORY,
	BATTERY,
	OPTICS,
	MOBILITY,
	NONE
}

enum SpecialStat {
	AP,
	ENERGY,
	AILMENTS, # meaning all ailments
	MOVE_RANGE
}

enum Ailments {
	OVERHEATED,
	ACIDIZED,
	BLANCHED,
	CONCUSSED
}

enum EffectType {
	STATUS,
	ATTRIBUTE,
	AILMENT,
	RESTORE
}

enum EffectTarget {
	OTHER,
	SELF
}

enum AnimOrigin {
	OTHER,
	SELF
}

enum EnemyAction {
	ABILITY,
	MOVE,
	GUARD,
}

#enum AbilityRole {
	#EMELEE,
	#PMELEE,
	#EMIDRANGE,
	#PMIDRANGE,
	#ELONGRANGE,
	#PLONGRANGE,
	#EOFFENSIVE,
	#POFFESNIVE,
	#EDEFENSIVE,
	#PDEFENSIVE
#}

enum MachineRole {
	ETANK,
	PTANK,
	ESNIPER,
	PSNIPER,
	EASSAULTER,
	PASSAULTER,
	EOSUPPORT,
	POSUPPORT,
	EDSUPPORT,
	PDSUPPORT,
	NONE
}

#############################################################  ABILITY CREATOR  #####################################################
#AbilityType: .ATTACK , .EFFECT
#DamageType: .PHYSICAL , .ENERGY , .NONE
#TargetType: .HERO , .ENEMY
#Range: X: 3-7 , Y: 1-4
#AbilityShape: .SINGLE , .LINE , .SQUARE , .DIAMOND , .MULTIPLE , .COLUMN , .ALL
#EffectType: .STATUS , .ATTRIBUTE , .AILMENT
#EffectTarget: .OTHER , .SELF

var abilities: Dictionary = {
	"Clobber": {"name": "Clobber", "ability_type": AbilityType.ATTACK, "damage": { "type": DamageType.PHYSICAL, "value": 80}, "action_cost": 3, "energy_cost": 0, "target_type": TargetType.ENEMY, "attribute_bonus": Attributes.STRENGTH, "description": "80 physical damage.", "range": Vector2i(3,1), "shape": AbilityShape.SINGLE, "effects": [], "animation": {"name": "Clobber", "origin": AnimOrigin.OTHER, "duration": 0.7}},
	
	"Heat Ray": {"name": "Heat Ray", "ability_type": AbilityType.ATTACK, "damage": { "type": DamageType.ENERGY, "value": 55}, "action_cost": 3, "energy_cost": 16, "target_type": TargetType.ENEMY, "attribute_bonus": Attributes.FLUX, "description": "50 energy damage and 2 overheated to all enemies in a line.", "range": Vector2i.ZERO, "shape": AbilityShape.LINE, "effects": [
		{"effect_type": EffectType.AILMENT, "target": EffectTarget.OTHER, "value": 2, "property": Ailments.OVERHEATED, "dialog": "gained 2 overheated"}], "animation": {"name": "Laser", "origin": AnimOrigin.SELF, "duration": 0.7}},
	
	"Ripjaw": {"name": "Ripjaw", "ability_type": AbilityType.ATTACK, "damage": { "type": DamageType.PHYSICAL, "value": 70}, "action_cost": 3, "energy_cost": 0, "target_type": TargetType.ENEMY, "attribute_bonus": Attributes.STRENGTH, "description": "70 physical damage and loses 1 armor.", "range": Vector2i(3,1), "shape": AbilityShape.SINGLE, "effects": [
		{"effect_type": EffectType.ATTRIBUTE, "duration": -1, "target": EffectTarget.OTHER, "value": -1, "property": Attributes.ARMOR, "dialog": "lost 1 armor"}], "animation": {"name": "Bite", "origin": AnimOrigin.OTHER, "duration": 0.7}},
	
	"Reinforce": {"name": "Reinforce", "ability_type": AbilityType.EFFECT, "damage": { "type": DamageType.NONE, "value": 0}, "action_cost": 3, "energy_cost": 4, "target_type": TargetType.HERO, "attribute_bonus": Attributes.NONE, "description": "Increases armor to allies in a line", "range": Vector2i.ZERO, "shape": AbilityShape.LINE, "effects": [
		{"effect_type": EffectType.ATTRIBUTE, "duration": -1, "target": EffectTarget.OTHER, "value": -1, "property": Attributes.ARMOR, "dialog": "gained 1 armor", "animation": {"name": "Reinforce", "origin": AnimOrigin.OTHER, "duration": 0.7}}]},
	
	"Sonic Pulse": {"name": "Sonic Pulse", "ability_type": AbilityType.ATTACK, "damage":{ "type": DamageType.ENERGY, "value": 75}, "action_cost": 3, "energy_cost": 18, "target_type": TargetType.ENEMY, "attribute_bonus": Attributes.FLUX, "description": "A simple energy attack", "range": Vector2i(2,0), "shape": AbilityShape.SINGLE, "effects": [
		{"effect_type": EffectType.AILMENT, "target": EffectTarget.OTHER, "value": 2, "property":
			Ailments.BLANCHED, "dialog": "gained 2 blanched", "animation": {"name": "Wavebeam", "origin": AnimOrigin.SELF, "duration": 0.6}}]},
	
	"Bulk Inversion": {"name": "Bulk Inversion", "ability_type": AbilityType.EFFECT, "damage": { "type": DamageType.NONE, "value": 0}, "action_cost": 3, "energy_cost": 26, "target_type": TargetType.ENEMY, "attribute_bonus": Attributes.NONE, "description": "Steals 2 armor from a target", "range": Vector2i(4,2), "shape": AbilityShape.SINGLE, "effects": [
		{"effect_type": EffectType.ATTRIBUTE, "duration": -1, "target": EffectTarget.OTHER, "value": -2, "property": Attributes.ARMOR, "dialog": "lost 2 armor", "animation": {"name": "ArmorInversionOther", "origin": AnimOrigin.OTHER, "duration": 0.9}},
		{"effect_type": EffectType.ATTRIBUTE, "duration": -1, "target": EffectTarget.SELF, "value": 2, "property": Attributes.ARMOR, "dialog": "gained 2 armor", "animation": {"name": "ArmorInversionSelf", "origin": AnimOrigin.OTHER, "duration": 0.9}}]},
		
	"Ignite": {"name": "Ignite", "ability_type": AbilityType.EFFECT, "damage": {"type": DamageType.NONE, "value": 0}, "action_cost": 2, "energy_cost": 2, "target_type": TargetType.ENEMY, "attribute_bonus": Attributes.NONE, "description": "Enemy gains +2 overheat", "range": Vector2i(5, 0), "shape": AbilityShape.SINGLE, "effects": [
		{"effect_type": EffectType.AILMENT, "target": EffectTarget.OTHER, "value": 2, "property":
			Ailments.OVERHEATED, "dialog": "gained 2 overheat", "animation": {"name": "Ignite", "duration": 0.8, "origin": AnimOrigin.OTHER}}]},
	
	"Acid Cloud": {"name": "Acid Cloud", "ability_type": AbilityType.EFFECT, "damage": {"type": DamageType.NONE, "value": 0}, "action_cost": 3, "energy_cost": 8, "target_type": TargetType.ENEMY, "attribute_bonus": Attributes.NONE, "description": "Applies 2 acidize to enemies in a circle", "range": Vector2i(7,4), "shape": AbilityShape.DIAMOND, "effects": [
		{"effect_type": EffectType.AILMENT, "target": EffectTarget.OTHER, "value": 2, "property":
			Ailments.ACIDIZED, "dialog": "gained 2 acidized", "animation": {"name": "AcidCloud", "origin": AnimOrigin.OTHER, "duration": 0.9}}]},
			
	"Screen Flash": {"name": "Screen Flash", "ability_type": AbilityType.EFFECT, "damage": {"type": DamageType.NONE, "value": 0}, "action_cost": 3, "energy_cost": 14, "target_type": TargetType.ENEMY, "attribute_bonus": Attributes.NONE, "description": "Applies 2 blanched to all enemies", "range": Vector2i.ZERO, "shape": AbilityShape.ALL, "effects": [
		{"effect_type": EffectType.AILMENT, "target": EffectTarget.OTHER, "value": 2, "property":
			Ailments.BLANCHED, "dialog": "gained 2 blanched", "animation": {"name": "ScreenFlash", "origin": AnimOrigin.OTHER, "duration": 1}}]},
		
	"Zap": {"name": "Zap", "ability_type": AbilityType.ATTACK, "damage":{ "type": DamageType.ENERGY, "value": 40}, "action_cost": 2, "energy_cost": 2, "target_type": TargetType.ENEMY, "attribute_bonus": Attributes.FLUX, "description": "40 energy damage.", "range": Vector2i(4,1), "shape": AbilityShape.SINGLE, "effects": [], "animation": {"name": "Zap", "origin": AnimOrigin.OTHER, "duration": 0.6}},
		
	"Power Strike": {"name": "Power Strike", "ability_type": AbilityType.ATTACK, "damage":{ "type": DamageType.PHYSICAL, "value": 40}, "action_cost": 2, "energy_cost": 0, "target_type": TargetType.ENEMY, "attribute_bonus": Attributes.STRENGTH, "description": "40 physical damage.", "range": Vector2i(4,1), "shape": AbilityShape.SINGLE, "effects": [], "animation": {"name": "PowerStrike", "origin": AnimOrigin.OTHER, "duration": 0.6}},
	
	"Contemplate": {"name": "Contemplate", "ability_type": AbilityType.EFFECT, "damage": { "type": DamageType.NONE, "value": 0}, "action_cost": 0, "energy_cost": 0, "target_type": TargetType.HERO, "attribute_bonus": Attributes.NONE, "description": "Gain +2 action points and +2 memory.", "range": Vector2i.ZERO, "shape": AbilityShape.SINGLE, "effects": [
		{"effect_type": EffectType.RESTORE, "target": EffectTarget.SELF, "value": 2, "property": SpecialStat.AP, "dialog": "gained +2 action points", "animation": {"name": "Contemplate", "origin": AnimOrigin.OTHER, "duration": 0.9}},
		{"effect_type": EffectType.ATTRIBUTE, "duration": -1, "target": EffectTarget.SELF, "value": 2, "property": Attributes.MEMORY, "dialog": "gained +2 memory", "animation": {"name": "Contemplate", "origin": AnimOrigin.OTHER, "duration": 0.9}}]},
		
	"Process Crunch": {"name": "Process Crunch", "ability_type": AbilityType.EFFECT, "damage": { "type": DamageType.NONE, "value": 0}, "action_cost": 2, "energy_cost": 10, "target_type": TargetType.HERO, "attribute_bonus": Attributes.NONE, "description": "Removes all ailments. Gain +4 memory and +4 flux during your next turn.", "range": Vector2i.ZERO, "shape": AbilityShape.SINGLE, "effects": [
		{"effect_type": EffectType.RESTORE, "target": EffectTarget.SELF, "value": 0, "property": SpecialStat.AILMENTS, "dialog": "removed all ailments", "animation": {"name": "ArmorInversionOther", "origin": AnimOrigin.SELF, "duration": 0.9}},
		{"effect_type": EffectType.ATTRIBUTE, "duration": 1, "target": EffectTarget.SELF, "value": 4, "property": Attributes.FLUX, "dialog": "gained +4 flux until end of next turn", "animation": {"name": "ArmorInversionOther", "origin": AnimOrigin.OTHER, "duration": 0.9}},
		{"effect_type": EffectType.ATTRIBUTE, "duration": 1, "target": EffectTarget.SELF, "value": 4, "property": Attributes.MEMORY, "dialog": "gained +4 memory end of until next turn", "animation": {"name": "ArmorInversionSelf", "origin": AnimOrigin.OTHER, "duration": 0.9}}]},
		
	"Trample": {"name": "Trample", "ability_type": AbilityType.ATTACK, "damage": { "type": DamageType.PHYSICAL, "value": 70}, "action_cost": 3, "energy_cost": 0, "target_type": TargetType.ENEMY, "attribute_bonus": Attributes.STRENGTH, "description": "+70 physical damage. If a move action was made, increase damage by 20.", "range": Vector2i(3,1), "shape": AbilityShape.SINGLE, "effects": [], "animation": {"name": "Trample", "origin": AnimOrigin.OTHER, "duration": 0.7}},
	
	"Wave Beam": {"name": "Wave Beam", "ability_type": AbilityType.ATTACK, "damage":{ "type": DamageType.ENERGY, "value": 65}, "action_cost": 3, "energy_cost": 10, "target_type": TargetType.ENEMY, "attribute_bonus": Attributes.FLUX, "description": "65 energy damage to the front two enemies in this row", "range": Vector2i(4,0), "shape": AbilityShape.LINE, "effects": [], "animation": {"name": "Wavebeam", "origin": AnimOrigin.OTHER, "duration": 0.6}},
		
	"Burst Rifle": {"name": "Burst Rifle", "ability_type": AbilityType.ATTACK, "damage": { "type": DamageType.PHYSICAL, "value": 90}, "action_cost": 3, "energy_cost": 5, "target_type": TargetType.ENEMY, "attribute_bonus": Attributes.NONE, "description": "90 physical damage. You gain +2 overheated.", "range": Vector2i(7,1), "shape": AbilityShape.SINGLE, "effects": [
		{"effect_type": EffectType.AILMENT, "target": EffectTarget.SELF, "value": 2, "property":
			Ailments.OVERHEATED, "dialog": "gained 2 overheated",}], "animation": {"name": "BurstRifle", "origin": AnimOrigin.SELF, "duration": 0.8}},
		
	"Self Repair": {"name": "Self Repair", "ability_type": AbilityType.EFFECT, "damage":{ "type": DamageType.NONE, "value": -75}, "action_cost": 3, "energy_cost": 12, "target_type": TargetType.HERO, "attribute_bonus": Attributes.NONE, "description": "Restore 75 health. On its next turn, restore 75 health, then skip the turn.", "range": Vector2i(4,0), "shape": AbilityShape.LINE, "effects": [], "animation": {"name": "Wavebeam", "origin": AnimOrigin.OTHER, "duration": 0.6}},
	
	"Rallied Surge": {"name": "Rallied Surge", "ability_type": AbilityType.EFFECT, "damage": { "type": DamageType.NONE, "value": 0}, "action_cost": 3, "energy_cost": 20, "target_type": TargetType.HERO, "attribute_bonus": Attributes.NONE, "description": "Each adjacent ally gains +2 Strength and +2 Flux", "range": Vector2i.ZERO, "shape": AbilityShape.SQUARE, "effects": [
		{"effect_type": EffectType.ATTRIBUTE, "duration": -1, "target": EffectTarget.SELF, "value": 2, "property": Attributes.STRENGTH, "dialog": "gained 2 power", "animation": {"name": "ArmorInversionOther", "origin": AnimOrigin.OTHER, "duration": 0.9}},
		{"effect_type": EffectType.ATTRIBUTE, "duration": -1, "target": EffectTarget.SELF, "value": 2, "property": Attributes.MEMORY, "dialog": "gained 2 flux", "animation": {"name": "ArmorInversionSelf", "origin": AnimOrigin.OTHER, "duration": 0.9}}]},
		
	"Seeker Rockets": {"name": "Seeker Rockets", "ability_type": AbilityType.ATTACK, "damage":{ "type": DamageType.PHYSICAL, "value": 45}, "action_cost": 3, "energy_cost": 0, "target_type": TargetType.ENEMY, "attribute_bonus": Attributes.NONE, "description": "Two random enemies are dealt 40 physical damage.", "range": Vector2i(4,1), "shape": AbilityShape.SINGLE, "effects": [], "animation": {"name": "Wavebeam", "origin": AnimOrigin.OTHER, "duration": 0.6}},
		
	"Crush": {"name": "Crush", "ability_type": AbilityType.ATTACK, "damage": {"type": DamageType.PHYSICAL, "value": 70}, "action_cost": 3, "energy_cost": 0, "target_type": TargetType.ENEMY, "attribute_bonus": Attributes.STRENGTH, "description": "A melee attack that applies -1 strength", "range": Vector2i(4,0), "shape": AbilityShape.MELEE, "animation": {"name": "Crush", "origin": AnimOrigin.OTHER, "duration": 0.7}, "effects": [
		{"effect_type": EffectType.AILMENT, "target": EffectTarget.OTHER, "value": 1, "property":
			Ailments.CONCUSSED, "dialog": "gained 1 concussed"}]},
	}
	
var items: Dictionary = {
	"Extra Rock": {"name": "Extra Rock", "effect_type": "Rock", "description": "Rock attack went up!", "menu_description": "Adds damage to rock attacks", "multiplier": .3},
	
	"Sharpener":{"name": "Sharpener", "effect_type": "Scissors", "description": "Scissors attack went up!", "menu_description": "Adds damage to scissors attacks", "multiplier": .3},
	
	"Extra Paper":{"name": "Extra Paper", "effect_type": "Paper", "description": "Paper attack went up!", "menu_description": "Adds damage to paper attacks", "multiplier": .3}}

var pokedex = {
	"Bulbasaur": {"name": "Bulbasaur", "type": ["Grass", "Poison"], "description": "A small, squat Pokémon with a plant bulb on its back, which grows into a large plant as it evolves."},
	"Ivysaur": {"name": "Ivysaur", "type": ["Grass", "Poison"], "description": "The evolved form of Bulbasaur, with a larger plant on its back that blooms into a flower."},
	"Venusaur": {"name": "Venusaur", "type": ["Grass", "Poison"], "description": "The final form of Bulbasaur, with a massive flower blooming from its back."},
}

var pokedex_entries = ["Bulbasaur", "Ivysaur", "Venusaur"]
