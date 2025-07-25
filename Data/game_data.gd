extends Node

class_name Data

const permanent = -1

var GlobalMapControllerRef = 1

enum Scenes {
	OVERWORLD,
	BATTLE
}

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
	DOUBLEH,
	DOUBLEV,
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
	HP,
	ENERGY,
	AILMENTS, # meaning all ailments
	MOVE_RANGE,
	GUARD_RANGE
}

enum Ailments {
	OVERHEATED,
	ACIDIZED,
	BLANCHED,
	CONCUSSED
}

enum EffectType {
	STATS, #AP, HP, EP
	ATTRIBUTE,
	AILMENT
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
	AIM
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

enum SoundAction {
	START,
	ATTACK,
	DEATH,
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
	"Clobber": {"name": "Clobber", "ability_type": AbilityType.ATTACK, "damage": { "type": DamageType.PHYSICAL, "value": 90}, "action_cost": 3, "energy_cost": 0, "target_type": TargetType.ENEMY, "attribute_bonus": Attributes.STRENGTH, "description": "90 physical damage.", "range": Vector2i(3,1), "shape": AbilityShape.MELEE, "sound": "res://Scenes/Battle/Animations/Animation_Sounds/Clobber.wav", "effects": [], "animation": {"name": "Clobber", "origin": AnimOrigin.OTHER, "duration": 0.8}},
	
	"Heat Ray": {"name": "Heat Ray", "ability_type": AbilityType.ATTACK, "damage": { "type": DamageType.ENERGY, "value": 40}, "action_cost": 3, "energy_cost": 22, "target_type": TargetType.ENEMY, "attribute_bonus": Attributes.FLUX, "description": "40 energy damage and 2 overheated to all enemies in a line.", "range": Vector2i.ZERO, "shape": AbilityShape.LINE, "sound": "res://Scenes/Battle/Animations/Animation_Sounds/Heat_Ray.wav",  "effects": [
		{"effect_type": EffectType.AILMENT, "target": EffectTarget.OTHER, "value": 2, "property": Ailments.OVERHEATED, "dialog": "gained 2 overheated"}], "animation": {"name": "Laser", "origin": AnimOrigin.SELF, "duration": 0.8, "offset": 340}}, ##### ANIMATION OFFSET EXAMPLE
	
	"Ripjaw": {"name": "Ripjaw", "ability_type": AbilityType.ATTACK, "damage": { "type": DamageType.PHYSICAL, "value": 65}, "action_cost": 3, "energy_cost": 0, "target_type": TargetType.ENEMY, "attribute_bonus": Attributes.STRENGTH, "description": "65 physical damage and loses 1 armor.", "range": Vector2i(3,1), "shape": AbilityShape.MELEE, "sound": "res://Scenes/Battle/Animations/Animation_Sounds/Ripjaw.wav", "effects": [
		{"effect_type": EffectType.ATTRIBUTE, "duration": permanent, "target": EffectTarget.OTHER, "value": -1, "property": Attributes.ARMOR, "dialog": "lost 1 armor"}], "animation": {"name": "Bite", "origin": AnimOrigin.OTHER, "duration": 0.8}},
	
	"Reinforce": {"name": "Reinforce", "ability_type": AbilityType.EFFECT, "damage": { "type": DamageType.NONE, "value": 0}, "action_cost": 3, "energy_cost": 4, "target_type": TargetType.HERO, "attribute_bonus": Attributes.NONE, "description": "Increases 2 armor to allies in a line", "range": Vector2i.ZERO, "shape": AbilityShape.LINE, "sound": "res://Scenes/Battle/Animations/Animation_Sounds/Beam_Slice.wav", "effects": [
		{"effect_type": EffectType.ATTRIBUTE, "duration": permanent, "target": EffectTarget.OTHER, "value": 2, "property": Attributes.ARMOR, "dialog": "gained 2 armor", "animation": {"name": "Reinforce", "origin": AnimOrigin.OTHER, "duration": 0.8}}]},
	
	"Sonic Pulse": {"name": "Sonic Pulse", "ability_type": AbilityType.ATTACK, "damage":{ "type": DamageType.ENERGY, "value": 90}, "action_cost": 3, "energy_cost": 6, "target_type": TargetType.ENEMY, "attribute_bonus": Attributes.FLUX, "description": "90 energy damage", "range": Vector2i(4,0), "shape": AbilityShape.SINGLE, "sound": "res://Scenes/Battle/Animations/Animation_Sounds/Beam_Slice.wav", "effects": []},
	
	"Bulk Inversion": {"name": "Bulk Inversion", "ability_type": AbilityType.EFFECT, "damage": { "type": DamageType.NONE, "value": 0}, "action_cost": 3, "energy_cost": 16, "target_type": TargetType.ENEMY, "attribute_bonus": Attributes.NONE, "description": "Steals 2 armor from a target", "range": Vector2i(4,1), "shape": AbilityShape.SINGLE, "sound": "res://Scenes/Battle/Animations/Animation_Sounds/Bulk_Inversion.wav", "effects": [
		{"effect_type": EffectType.ATTRIBUTE, "duration": permanent, "target": EffectTarget.OTHER, "value": -2, "property": Attributes.ARMOR, "dialog": "lost 2 armor", "animation": {"name": "ArmorInversionOther", "origin": AnimOrigin.OTHER, "duration": 0.8}},
		{"effect_type": EffectType.ATTRIBUTE, "duration": permanent, "target": EffectTarget.SELF, "value": 2, "property": Attributes.ARMOR, "dialog": "gained 2 armor", "animation": {"name": "ArmorInversionSelf", "origin": AnimOrigin.OTHER, "duration": 0.8}}]},
		
	"Ignite": {"name": "Ignite", "ability_type": AbilityType.EFFECT, "damage": {"type": DamageType.NONE, "value": 0}, "action_cost": 1, "energy_cost": 2, "target_type": TargetType.ENEMY, "attribute_bonus": Attributes.NONE, "description": "Enemy gains +3 overheat", "range": Vector2i(4, 1), "shape": AbilityShape.SINGLE, "sound": "res://Scenes/Battle/Animations/Animation_Sounds/Ignite.wav", "effects": [
		{"effect_type": EffectType.AILMENT, "target": EffectTarget.OTHER, "value": 3, "property":
			Ailments.OVERHEATED, "dialog": "gained 3 overheat", "animation": {"name": "Ignite", "duration": 0.8, "origin": AnimOrigin.OTHER}}]},
	
	"Acid Cloud": {"name": "Acid Cloud", "ability_type": AbilityType.EFFECT, "damage": {"type": DamageType.NONE, "value": 0}, "action_cost": 3, "energy_cost": 16, "target_type": TargetType.ENEMY, "attribute_bonus": Attributes.NONE, "description": "Applies 3 acidize to enemies in a circle", "range": Vector2i(4,1), "shape": AbilityShape.DIAMOND, "sound": "res://Scenes/Battle/Animations/Animation_Sounds/Acid_Cloud.wav", "effects": [
		{"effect_type": EffectType.AILMENT, "target": EffectTarget.OTHER, "value": 3, "property":
			Ailments.ACIDIZED, "dialog": "gained 3 acidized", "animation": {"name": "AcidCloud", "origin": AnimOrigin.OTHER, "duration": 0.8}}]},
			
	"Screen Flash": {"name": "Screen Flash", "ability_type": AbilityType.EFFECT, "damage": {"type": DamageType.NONE, "value": 0}, "action_cost": 3, "energy_cost": 14, "target_type": TargetType.ENEMY, "attribute_bonus": Attributes.NONE, "description": "Enemies lose 1 AP and 1 memory", "range": Vector2i.ZERO, "shape": AbilityShape.ALL, "sound": "res://Scenes/Battle/Animations/Animation_Sounds/Beam_Slice.wav", "effects": [
		{"effect_type": EffectType.STATS, "target": EffectTarget.OTHER, "value": -1, "property": SpecialStat.AP, "dialog": "lost 1 AP", "animation": {"name": "ScreenFlash", "origin": AnimOrigin.SELF, "duration": 0.9, "offset": 185}},
		{"effect_type": EffectType.ATTRIBUTE, "duration": permanent, "target": EffectTarget.OTHER, "value": -1, "property": Attributes.MEMORY, "dialog": "lost 1 memory", "animation": {"name": "ScreenFlash", "origin": AnimOrigin.OTHER, "duration": 0.0}}]},
		
	"Zap": {"name": "Zap", "ability_type": AbilityType.ATTACK, "damage":{ "type": DamageType.ENERGY, "value": 45}, "action_cost": 1, "energy_cost": 2, "target_type": TargetType.ENEMY, "attribute_bonus": Attributes.FLUX, "description": "45 energy damage.", "range": Vector2i(4,1), "shape": AbilityShape.SINGLE, "sound": "res://Scenes/Battle/Animations/Animation_Sounds/Beam_Slice.wav", "effects": [], "animation": {"name": "Zap", "origin": AnimOrigin.OTHER, "duration": 0.8}},
		
	"Power Strike": {"name": "Power Strike", "ability_type": AbilityType.ATTACK, "damage":{ "type": DamageType.PHYSICAL, "value": 50}, "action_cost": 1, "energy_cost": 0, "target_type": TargetType.ENEMY, "attribute_bonus": Attributes.STRENGTH, "description": "50 physical damage.", "range": Vector2i(3,1), "shape": AbilityShape.MELEE, "sound": "res://Scenes/Battle/Animations/Animation_Sounds/Power Strike.wav", "effects": [], "animation": {"name": "PowerStrike", "origin": AnimOrigin.OTHER, "duration": 0.8}},
	
	"Contemplate": {"name": "Contemplate", "ability_type": AbilityType.EFFECT, "damage": { "type": DamageType.NONE, "value": 0}, "action_cost": 1, "energy_cost": 1, "target_type": TargetType.HERO, "attribute_bonus": Attributes.NONE, "description": "Gain 3 memory.", "range": Vector2i.ZERO, "shape": AbilityShape.SINGLE, "sound": "res://Scenes/Battle/Animations/Animation_Sounds/Contemplate.wav", "effects": [
		{"effect_type": EffectType.ATTRIBUTE, "duration": permanent, "target": EffectTarget.SELF, "value": 3, "property": Attributes.MEMORY, "dialog": "gained +3 memory", "animation": {"name": "Contemplate", "origin": AnimOrigin.OTHER, "duration": 0.8}}]},
		
	"Innervate": {"name": "Innervate", "ability_type": AbilityType.EFFECT, "damage": { "type": DamageType.NONE, "value": 0}, "action_cost": 1, "energy_cost": 1, "target_type": TargetType.HERO, "attribute_bonus": Attributes.NONE, "description": "Gain 3 flux.", "range": Vector2i.ZERO, "shape": AbilityShape.SINGLE, "sound": "res://Scenes/Battle/Animations/Animation_Sounds/Innervate.wav", "effects": [
		{"effect_type": EffectType.ATTRIBUTE, "duration": permanent, "target": EffectTarget.SELF, "value": 3, "property": Attributes.FLUX, "dialog": "gained +3 flux", "animation": {"name": "Innervate", "origin": AnimOrigin.OTHER, "duration": 0.8}}]},
		
	"Strenuate": {"name": "Strenuate", "ability_type": AbilityType.EFFECT, "damage": { "type": DamageType.NONE, "value": 0}, "action_cost": 1, "energy_cost": 1, "target_type": TargetType.HERO, "attribute_bonus": Attributes.NONE, "description": "Gain 3 strength.", "range": Vector2i.ZERO, "shape": AbilityShape.SINGLE, "sound": "res://Scenes/Battle/Animations/Animation_Sounds/Strenuate.wav", "effects": [
		{"effect_type": EffectType.ATTRIBUTE, "duration": permanent, "target": EffectTarget.SELF, "value": 3, "property": Attributes.STRENGTH, "dialog": "gained +3 strength", "animation": {"name": "Strenuate", "origin": AnimOrigin.OTHER, "duration": 0.8}}]},
		
	"Accelerate": {"name": "Accelerate", "ability_type": AbilityType.EFFECT, "damage": { "type": DamageType.NONE, "value": 0}, "action_cost": 1, "energy_cost": 1, "target_type": TargetType.HERO, "attribute_bonus": Attributes.NONE, "description": "Gain 3 mobility.", "range": Vector2i.ZERO, "shape": AbilityShape.SINGLE, "sound": "res://Scenes/Battle/Animations/Animation_Sounds/Accelerate.wav", "effects": [
		{"effect_type": EffectType.ATTRIBUTE, "duration": permanent, "target": EffectTarget.SELF, "value": 3, "property": Attributes.MOBILITY, "dialog": "gained +3 mobility", "animation": {"name": "Accelerate", "origin": AnimOrigin.OTHER, "duration": 0.8}}]},
	
	"Trample": {"name": "Trample", "ability_type": AbilityType.ATTACK, "damage": { "type": DamageType.PHYSICAL, "value": 75}, "action_cost": 3, "energy_cost": 0, "target_type": TargetType.ENEMY, "attribute_bonus": Attributes.STRENGTH, "description": "+75 physical damage. If a move action was made, +25 damage.", "range": Vector2i(3,1), "shape": AbilityShape.SINGLE, "sound": "res://Scenes/Battle/Animations/Animation_Sounds/Beam_Slice.wav", "effects": [], "animation": {"name": "Trample", "origin": AnimOrigin.OTHER, "duration": 0.8}},
	
	"Charge Beam": {"name": "Charge Beam", "ability_type": AbilityType.ATTACK, "damage": { "type": DamageType.ENERGY, "value": 75}, "action_cost": 3, "energy_cost": 8, "target_type": TargetType.ENEMY, "attribute_bonus": Attributes.FLUX, "description": "+75 energy damage. If an aim action was made, +25 damage.", "range": Vector2i(7,0), "shape": AbilityShape.SINGLE, "sound": "res://Scenes/Battle/Animations/Animation_Sounds/Beam_Slice.wav", "effects": [], "animation": {"name": "Trample", "origin": AnimOrigin.OTHER, "duration": 0.8}},
	
	"Wave Beam": {"name": "Wave Beam", "ability_type": AbilityType.ATTACK, "damage":{ "type": DamageType.ENERGY, "value": 65}, "action_cost": 3, "energy_cost": 10, "target_type": TargetType.ENEMY, "attribute_bonus": Attributes.FLUX, "description": "65 energy damage dealt to enemy and enemy behind", "range": Vector2i(4,0), "shape": AbilityShape.DOUBLEH, "sound": "res://Scenes/Battle/Animations/Animation_Sounds/Beam_Slice.wav", "effects": [], "animation": {"name": "Wavebeam", "origin": AnimOrigin.OTHER, "duration": 0.8}},
	
	"Burst Rifle": {"name": "Burst Rifle", "ability_type": AbilityType.ATTACK, "damage": { "type": DamageType.PHYSICAL, "value": 95}, "action_cost": 3, "energy_cost": 0, "target_type": TargetType.ENEMY, "attribute_bonus": Attributes.NONE, "description": "95 physical damage. You gain +2 overheated.", "range": Vector2i(7,0), "shape": AbilityShape.SINGLE, "sound": "res://Scenes/Battle/Animations/Animation_Sounds/Burst_Rifle.wav", "effects": [
		{"effect_type": EffectType.AILMENT, "target": EffectTarget.SELF, "value": 2, "property":
			Ailments.OVERHEATED, "dialog": "gained 2 overheated",}], "animation": {"name": "BurstRifle", "origin": AnimOrigin.OTHER, "duration": 0.8, "offset": -40}},
		
	"Self Repair": {"name": "Self Repair", "ability_type": AbilityType.EFFECT, "damage": { "type": DamageType.NONE, "value": 0}, "action_cost": 3, "energy_cost": 14, "target_type": TargetType.HERO, "attribute_bonus": Attributes.NONE, "description": "Restore 100 HP to self.", "range": Vector2i(0,0), "shape": AbilityShape.SINGLE, "sound": "res://Scenes/Battle/Animations/Animation_Sounds/Accelerate.wav", "effects": [
		{"effect_type": EffectType.STATS, "target": EffectTarget.SELF, "value": 100, "property": SpecialStat.HP, "dialog": "restored 100 HP", "animation": {"name": "SelfRepair", "origin": AnimOrigin.OTHER, "duration": 0.8}}]},
	
	"Rallied Surge": {"name": "Rallied Surge", "ability_type": AbilityType.EFFECT, "damage": { "type": DamageType.NONE, "value": 0}, "action_cost": 3, "energy_cost": 24, "target_type": TargetType.HERO, "attribute_bonus": Attributes.NONE, "sound": "res://Scenes/Battle/Animations/Animation_Sounds/Beam_Slice.wav",  "description": "Each adjacent ally gains +3 Shielding", "range": Vector2i.ZERO, "shape": AbilityShape.SQUARE, "effects": [
		{"effect_type": EffectType.ATTRIBUTE, "duration": permanent, "target": EffectTarget.SELF, "value": 2, "property": Attributes.STRENGTH, "dialog": "gained 2 power", "animation": {"name": "RalliedSurge", "origin": AnimOrigin.OTHER, "duration": 0.8}},
		{"effect_type": EffectType.ATTRIBUTE, "duration": permanent, "target": EffectTarget.SELF, "value": 2, "property": Attributes.MEMORY, "dialog": "gained 2 flux", "animation": {"name": "ArmorInversionSelf", "origin": AnimOrigin.OTHER, "duration": 0.8}}]},
		
	"Cluster Rockets": {"name": "Cluster Rockets", "ability_type": AbilityType.ATTACK, "damage":{ "type": DamageType.PHYSICAL, "value": 100}, "action_cost": 3, "energy_cost": 0, "target_type": TargetType.ENEMY, "attribute_bonus": Attributes.NONE, "description": "Two random enemies are dealt 50 physical damage.", "range": Vector2i(4,1), "shape": AbilityShape.SINGLE, "sound": "res://Scenes/Battle/Animations/Animation_Sounds/Cluster_Rocket.wav", "effects": [], "animation": {"name": "ClusterRocket", "origin": AnimOrigin.OTHER, "duration": 0.8}},
		
	"Crush": {"name": "Crush", "ability_type": AbilityType.ATTACK, "damage": {"type": DamageType.PHYSICAL, "value": 70}, "action_cost": 3, "energy_cost": 0, "target_type": TargetType.ENEMY, "attribute_bonus": Attributes.STRENGTH, "description": "70 physical damage and -1 strength", "range": Vector2i(7,0), "shape": AbilityShape.MELEE, "sound": "res://Scenes/Battle/Animations/Animation_Sounds/Crush.wav", "animation": {"name": "Crush", "origin": AnimOrigin.OTHER, "duration": 0.8}, "effects": [
		{"effect_type": EffectType.ATTRIBUTE, "duration": permanent, "target": EffectTarget.OTHER, "value": -1, "property":
			Attributes.STRENGTH, "dialog": "lost 1 strength"}]},
			
	"Beam Slice": {"name": "Beam Slice", "ability_type": AbilityType.ATTACK, "damage": { "type": DamageType.ENERGY, "value": 95}, "action_cost": 3, "energy_cost": 4, "target_type": TargetType.ENEMY, "attribute_bonus": Attributes.STRENGTH, "description": "95 energy damage.", "range": Vector2i(3,1), "shape": AbilityShape.SINGLE, "sound": "res://Scenes/Battle/Animations/Animation_Sounds/Beam_Slice.wav", "effects": [], "animation": {"name": "BeamSlice", "origin": AnimOrigin.OTHER, "duration": 0.8}},
	
	"Septic Injection": {"name": "Septic Injection", "ability_type": AbilityType.EFFECT, "damage": { "type": DamageType.NONE, "value": 0}, "action_cost": 3, "energy_cost": 0, "target_type": TargetType.ENEMY, "attribute_bonus": Attributes.NONE, "description": "Target loses 40 health and gains 3 acidized.", "range": Vector2i(4,1), "shape": AbilityShape.SINGLE, "sound": "res://Scenes/Battle/Animations/Animation_Sounds/Beam_Slice.wav", "effects": [
		#{"effect_type": EffectType.ATTRIBUTE, "duration": permanent, "target": EffectTarget.OTHER, "value": -2, "property": Attributes.ARMOR, "dialog": "lost 2 armor", "animation": {"name": "ArmorInversionOther", "origin": AnimOrigin.OTHER, "duration": 0.8}}, ##Target loses 40 health
		{"effect_type": EffectType.AILMENT, "target": EffectTarget.OTHER, "value": 3, "property": Ailments.ACIDIZED, "dialog": "gained 3 acidized", "animation": {"name": "SepticInjection", "origin": AnimOrigin.OTHER, "duration": 0.8}}]},
	}
	
var passives = {
	"Mage": {"name": "Cascade", "property": Attributes.FLUX, "value": 1, "duration": permanent, "effect_type": EffectType.ATTRIBUTE},
	
	"Runt": {"name": "Thorns", "property": Attributes.ARMOR, "value": 1, "duration": 1, "effect_type": EffectType.ATTRIBUTE},
	
	"Thumper": {"name": "Hop", "property": SpecialStat.MOVE_RANGE, "value": 2, "duration": permanent, "effect_type": EffectType.STATS},
	
	"Pilypile": {"name": "Taunt", "property": SpecialStat.GUARD_RANGE, "value": 1, "duration": permanent, "effect_type": EffectType.STATS},
	
	"Mandrake": {"name": "Meditate", "property": Attributes.BATTERY, "value": 2, "duration": permanent, "effect_type": EffectType.ATTRIBUTE},
	
	"Eyecatcher": {"name": "Hex", "property": Attributes.BATTERY, "value": -2, "duration": permanent, "effect_type": EffectType.ATTRIBUTE}
	}
	
const sounds = {
	"MageDeathA1": "res://Scenes/Battle/Characters/Mage/Sounds/Mage_DeathA1.wav",
	"MageAttackA1": "res://Scenes/Battle/Characters/Mage/Sounds/Mage_AttackA1.wav",
	"MageAttackA2": "res://Scenes/Battle/Characters/Mage/Sounds/Mage_AttackA2.wav",
	"MageStartA1": "res://Scenes/Battle/Characters/Mage/Sounds/Mage_StartA1.wav",
	"MageStartA2": "res://Scenes/Battle/Characters/Mage/Sounds/Mage_StartA2.wav",

	"MandrakeDeathA1": "res://Scenes/Battle/Characters/Mandrake/Sounds/Mandrake_DeathA1.wav",
	"MandrakeAttackA1": "res://Scenes/Battle/Characters/Mandrake/Sounds/Mandrake_AttackA1.wav",
	"MandrakeAttackA2": "res://Scenes/Battle/Characters/Mandrake/Sounds/Mandrake_AttackA2.wav",
	"MandrakeStartA1": "res://Scenes/Battle/Characters/Mandrake/Sounds/Mandrake_StartA1.wav",
	"MandrakeStartA2": "res://Scenes/Battle/Characters/Mandrake/Sounds/Mandrake_StartA2.wav",

	"PilypileDeathA1": "res://Scenes/Battle/Characters/Pilypile/Sounds/Pilypile_DeathA1.wav",
	"PilypileAttackA1": "res://Scenes/Battle/Characters/Pilypile/Sounds/Pilypile_AttackA1.wav",
	"PilypileAttackA2": "res://Scenes/Battle/Characters/Pilypile/Sounds/Pilypile_AttackA2.wav",
	"PilypileStartA1": "res://Scenes/Battle/Characters/Pilypile/Sounds/Pilypile_StartA1.wav",
	"PilypileStartA2": "res://Scenes/Battle/Characters/Pilypile/Sounds/Pilypile_StartA2.wav",

	"GawkingstickDeathA1": "res://Scenes/Battle/Characters/Gawkingstick/Sounds/Gawkingstick_DeathA1.wav",
	"GawkingstickAttackA1": "res://Scenes/Battle/Characters/Gawkingstick/Sounds/Gawkingstick_AttackA1.wav",
	"GawkingstickAttackA2": "res://Scenes/Battle/Characters/Gawkingstick/Sounds/Gawkingstick_AttackA2.wav",
	"GawkingstickStartA1": "res://Scenes/Battle/Characters/Gawkingstick/Sounds/Gawkingstick_StartA1.wav",
	"GawkingstickStartA2": "res://Scenes/Battle/Characters/Gawkingstick/Sounds/Gawkingstick_StartA2.wav",
		
	"RuntDeathA1": "res://Scenes/Battle/Characters/Runt/Sounds/Runt_DeathA1.wav",
	"RuntAttackA1": "res://Scenes/Battle/Characters/Runt/Sounds/Runt_AttackA1.wav",
	"RuntAttackA2": "res://Scenes/Battle/Characters/Runt/Sounds/Runt_AttackA2.wav",
	"RuntStartA1": "res://Scenes/Battle/Characters/Runt/Sounds/Runt_StartA1.wav",
	"RuntStartA2": "res://Scenes/Battle/Characters/Runt/Sounds/Runt_StartA2.wav",

	"ThumperDeathA1": "res://Scenes/Battle/Characters/Thumper/Sounds/Thumper_DeathA1.wav",
	"ThumperAttackA1": "res://Scenes/Battle/Characters/Thumper/Sounds/Thumper_AttackA1.wav",
	"ThumperAttackA2": "res://Scenes/Battle/Characters/Thumper/Sounds/Thumper_AttackA2.wav",
	"ThumperStartA1": "res://Scenes/Battle/Characters/Thumper/Sounds/Thumper_StartA1.wav",
	"ThumperStartA2": "res://Scenes/Battle/Characters/Thumper/Sounds/Thumper_StartA2.wav"}

var characters = {
	"Mage": {"name": "Mage", "attributes": {Data.Attributes.STRENGTH: 1, Data.Attributes.FLUX: 5, Data.Attributes.ARMOR: 2, Data.Attributes.SHIELDING: 4, Data.Attributes.MEMORY: 2, Data.Attributes.BATTERY: 3, Data.Attributes.OPTICS: 3, Data.Attributes.MOBILITY: 2}, "abilities": ["Self Repair", "Heat Ray", "Charge Beam", "Innervate", "Screen Flash", "Charge Beam"], "base energy": 100, "base health": 340, "role": Data.MachineRole.ESNIPER, "path": "res://Scenes/Battle/Characters/Mage/mage.tscn"},
	
	"Runt": {"name": "Runt", "attributes": {Data.Attributes.STRENGTH: 2, Data.Attributes.FLUX: 1, Data.Attributes.ARMOR: 4, Data.Attributes.SHIELDING: 1, Data.Attributes.MEMORY: 1, Data.Attributes.BATTERY: 1, Data.Attributes.OPTICS: 1, Data.Attributes.MOBILITY: 2}, "abilities": ["Ripjaw", "Power Strike", "Reinforce", "Acid Cloud", "Septic Injection", "Strenuate" ], "base energy": 100, "base health": 320, "role": Data.MachineRole.PTANK, "path": "res://Scenes/Battle/Characters/Runt/runt.tscn"},
	
	"Pilypile": {"name": "Pilypile", "attributes": {Data.Attributes.STRENGTH: 2, Data.Attributes.FLUX: 1, Data.Attributes.ARMOR: 3, Data.Attributes.SHIELDING: 2, Data.Attributes.MEMORY: 2, Data.Attributes.BATTERY: 2, Data.Attributes.OPTICS: 1, Data.Attributes.MOBILITY: 1}, "abilities": ["Crush", "Zap", "Bulk Inversion", "Self Repair", "Beam Slice", "Wave Beam"], "base energy": 100, "base health": 340, "role": Data.MachineRole.ETANK, "path": "res://Scenes/Battle/Characters/Pilypile/pilypile.tscn"},
	
	"Gawkingstick": {"name": "Gawkingstick", "attributes": {Data.Attributes.STRENGTH: 1, Data.Attributes.FLUX: 2, Data.Attributes.ARMOR: 2, Data.Attributes.SHIELDING: 2, Data.Attributes.MEMORY: 4, Data.Attributes.BATTERY: 1, Data.Attributes.OPTICS: 2, Data.Attributes.MOBILITY: 1}, "abilities": ["Charge Beam", "Contemplate", "Screen Flash", "Cluster Rockets", "Beam Slice", "Heat Ray"], "base energy": 100, "base health": 320, "role": Data.MachineRole.EOSUPPORT, "path": "res://Scenes/Battle/Characters/Gawkingstick/norman.tscn"},
	#"Charge Beam", "Contemplate", "Screen Flash", "Seeker Rockets", "Beam Slice", "Heat Ray"
	
	"Mandrake": {"name": "Mandrake", "attributes": {Data.Attributes.STRENGTH: 1, Data.Attributes.FLUX: 3, Data.Attributes.ARMOR: 2, Data.Attributes.SHIELDING: 1, Data.Attributes.MEMORY: 3, Data.Attributes.BATTERY: 2, Data.Attributes.OPTICS: 2, Data.Attributes.MOBILITY: 2}, "abilities": ["Sonic Pulse", "Zap", "Burst Rifle", "Wave Beam", "Acid Cloud", "Septic Injection"], "base energy": 100, "base health": 300, "role": Data.MachineRole.ESNIPER, "path": "res://Scenes/Battle/Characters/Mandrake/mandrake.tscn"},
	
	"Thumper": {"name": "Thumper", "attributes": {Data.Attributes.STRENGTH: 2, Data.Attributes.FLUX: 1, Data.Attributes.ARMOR: 1, Data.Attributes.SHIELDING: 1, Data.Attributes.MEMORY: 2, Data.Attributes.BATTERY: 2, Data.Attributes.OPTICS: 2, Data.Attributes.MOBILITY: 4}, "abilities": ["Trample", "Power Strike", "Accelerate", "Burst Rifle", "Cluster Rockets", "Ignite"], "base energy": 100, "base health": 300, "role": Data.MachineRole.PASSAULTER, "path": "res://Scenes/Battle/Characters/Thumper/thumper.tscn"},
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
