extends Node

class_name Data

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
	ENERGY,
	AILMENTS, # meaning all ailments
	MOVE_RANGE,
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
	"Clobber": {"name": "Clobber", "ability_type": AbilityType.ATTACK, "damage": { "type": DamageType.PHYSICAL, "value": 80}, "action_cost": 3, "energy_cost": 0, "target_type": TargetType.ENEMY, "attribute_bonus": Attributes.STRENGTH, "description": "80 physical damage.", "range": Vector2i(3,1), "shape": AbilityShape.MELEE, "effects": [], "animation": {"name": "Clobber", "origin": AnimOrigin.OTHER, "duration": 0.8}},
	
	"Heat Ray": {"name": "Heat Ray", "ability_type": AbilityType.ATTACK, "damage": { "type": DamageType.ENERGY, "value": 55}, "action_cost": 3, "energy_cost": 52, "target_type": TargetType.ENEMY, "attribute_bonus": Attributes.FLUX, "description": "50 energy damage and 2 overheated to all enemies in a line.", "range": Vector2i.ZERO, "shape": AbilityShape.LINE, "effects": [
		{"effect_type": EffectType.AILMENT, "target": EffectTarget.OTHER, "value": 2, "property": Ailments.OVERHEATED, "dialog": "gained 2 overheated"}], "animation": {"name": "Laser", "origin": AnimOrigin.SELF, "duration": 0.8, "offset": 340}},
	
	"Ripjaw": {"name": "Ripjaw", "ability_type": AbilityType.ATTACK, "damage": { "type": DamageType.PHYSICAL, "value": 70}, "action_cost": 3, "energy_cost": 0, "target_type": TargetType.ENEMY, "attribute_bonus": Attributes.STRENGTH, "description": "70 physical damage and loses 1 armor.", "range": Vector2i(3,1), "shape": AbilityShape.SINGLE, "effects": [
		{"effect_type": EffectType.ATTRIBUTE, "duration": -1, "target": EffectTarget.OTHER, "value": -1, "property": Attributes.ARMOR, "dialog": "lost 1 armor"}], "animation": {"name": "Bite", "origin": AnimOrigin.OTHER, "duration": 0.8}},
	
	"Reinforce": {"name": "Reinforce", "ability_type": AbilityType.EFFECT, "damage": { "type": DamageType.NONE, "value": 0}, "action_cost": 3, "energy_cost": 4, "target_type": TargetType.HERO, "attribute_bonus": Attributes.NONE, "description": "Increases armor to allies in a line", "range": Vector2i.ZERO, "shape": AbilityShape.LINE, "effects": [
		{"effect_type": EffectType.ATTRIBUTE, "duration": -1, "target": EffectTarget.OTHER, "value": 2, "property": Attributes.ARMOR, "dialog": "gained 1 armor", "animation": {"name": "Reinforce", "origin": AnimOrigin.OTHER, "duration": 0.8}}]},
	
	"Sonic Pulse": {"name": "Sonic Pulse", "ability_type": AbilityType.ATTACK, "damage":{ "type": DamageType.ENERGY, "value": 75}, "action_cost": 3, "energy_cost": 18, "target_type": TargetType.ENEMY, "attribute_bonus": Attributes.FLUX, "description": "A simple energy attack", "range": Vector2i(5,0), "shape": AbilityShape.SINGLE, "effects": [
		{"effect_type": EffectType.AILMENT, "target": EffectTarget.OTHER, "value": 2, "property":
			Ailments.BLANCHED, "dialog": "gained 2 blanched"}]},
	
	"Bulk Inversion": {"name": "Bulk Inversion", "ability_type": AbilityType.EFFECT, "damage": { "type": DamageType.NONE, "value": 0}, "action_cost": 3, "energy_cost": 26, "target_type": TargetType.ENEMY, "attribute_bonus": Attributes.NONE, "description": "Steals 2 armor from a target", "range": Vector2i(4,2), "shape": AbilityShape.SINGLE, "effects": [
		{"effect_type": EffectType.ATTRIBUTE, "duration": -1, "target": EffectTarget.OTHER, "value": -2, "property": Attributes.ARMOR, "dialog": "lost 2 armor", "animation": {"name": "ArmorInversionOther", "origin": AnimOrigin.OTHER, "duration": 0.8}},
		{"effect_type": EffectType.ATTRIBUTE, "duration": -1, "target": EffectTarget.SELF, "value": 2, "property": Attributes.ARMOR, "dialog": "gained 2 armor", "animation": {"name": "ArmorInversionSelf", "origin": AnimOrigin.OTHER, "duration": 0.8}}]},
		
	"Ignite": {"name": "Ignite", "ability_type": AbilityType.EFFECT, "damage": {"type": DamageType.NONE, "value": 0}, "action_cost": 2, "energy_cost": 2, "target_type": TargetType.ENEMY, "attribute_bonus": Attributes.NONE, "description": "Enemy gains +2 overheat", "range": Vector2i(5, 0), "shape": AbilityShape.SINGLE, "effects": [
		{"effect_type": EffectType.AILMENT, "target": EffectTarget.OTHER, "value": 2, "property":
			Ailments.OVERHEATED, "dialog": "gained 2 overheat", "animation": {"name": "Ignite", "duration": 0.8, "origin": AnimOrigin.OTHER}}]},
	
	"Acid Cloud": {"name": "Acid Cloud", "ability_type": AbilityType.EFFECT, "damage": {"type": DamageType.NONE, "value": 0}, "action_cost": 3, "energy_cost": 8, "target_type": TargetType.ENEMY, "attribute_bonus": Attributes.NONE, "description": "Applies 2 acidize to enemies in a circle", "range": Vector2i(7,4), "shape": AbilityShape.DIAMOND, "effects": [
		{"effect_type": EffectType.AILMENT, "target": EffectTarget.OTHER, "value": 2, "property":
			Ailments.ACIDIZED, "dialog": "gained 2 acidized", "animation": {"name": "AcidCloud", "origin": AnimOrigin.OTHER, "duration": 0.8}}]},
			
	"Screen Flash": {"name": "Screen Flash", "ability_type": AbilityType.EFFECT, "damage": {"type": DamageType.NONE, "value": 0}, "action_cost": 3, "energy_cost": 14, "target_type": TargetType.ENEMY, "attribute_bonus": Attributes.NONE, "description": "Applies 2 blanched to all enemies", "range": Vector2i.ZERO, "shape": AbilityShape.ALL, "effects": [
		{"effect_type": EffectType.AILMENT, "target": EffectTarget.OTHER, "value": 2, "property":
			Ailments.BLANCHED, "dialog": "gained 2 blanched", "animation": {"name": "ScreenFlash", "origin": AnimOrigin.SELF, "duration": .9, "offset": 240}}]},
		
	"Zap": {"name": "Zap", "ability_type": AbilityType.ATTACK, "damage":{ "type": DamageType.ENERGY, "value": 40}, "action_cost": 2, "energy_cost": 2, "target_type": TargetType.ENEMY, "attribute_bonus": Attributes.FLUX, "description": "40 energy damage.", "range": Vector2i(4,1), "shape": AbilityShape.SINGLE, "effects": [], "animation": {"name": "Zap", "origin": AnimOrigin.OTHER, "duration": 0.8}},
		
	"Power Strike": {"name": "Power Strike", "ability_type": AbilityType.ATTACK, "damage":{ "type": DamageType.PHYSICAL, "value": 40}, "action_cost": 2, "energy_cost": 0, "target_type": TargetType.ENEMY, "attribute_bonus": Attributes.STRENGTH, "description": "40 physical damage.", "range": Vector2i(4,1), "shape": AbilityShape.SINGLE, "effects": [], "animation": {"name": "PowerStrike", "origin": AnimOrigin.OTHER, "duration": 0.8}},
	
	"Contemplate": {"name": "Contemplate", "ability_type": AbilityType.EFFECT, "damage": { "type": DamageType.NONE, "value": 0}, "action_cost": 0, "energy_cost": 0, "target_type": TargetType.HERO, "attribute_bonus": Attributes.NONE, "description": "Gain +2 action points and +2 memory.", "range": Vector2i.ZERO, "shape": AbilityShape.SINGLE, "effects": [
		{"effect_type": EffectType.RESTORE, "duration": -1, "target": EffectTarget.SELF, "value": 2, "property": SpecialStat.AP, "dialog": "gained +2 action points", "animation": {"name": "Contemplate", "origin": AnimOrigin.OTHER, "duration": 0.8}},
		{"effect_type": EffectType.ATTRIBUTE, "duration": -1, "target": EffectTarget.SELF, "value": 2, "property": Attributes.MEMORY, "dialog": "gained +2 memory", "animation": {"name": "Contemplate", "origin": AnimOrigin.OTHER, "duration": 0.8}}]},
		
	"Process Crunch": {"name": "Process Crunch", "ability_type": AbilityType.EFFECT, "damage": { "type": DamageType.NONE, "value": 0}, "action_cost": 2, "energy_cost": 10, "target_type": TargetType.HERO, "attribute_bonus": Attributes.NONE, "description": "Removes all ailments. Gain +4 memory and +4 flux during your next turn.", "range": Vector2i.ZERO, "shape": AbilityShape.SINGLE, "effects": [
		{"effect_type": EffectType.RESTORE, "duration": 0, "target": EffectTarget.SELF, "value": 0, "property": SpecialStat.AILMENTS, "dialog": "removed all ailments", "animation": {"name": "ArmorInversionOther", "origin": AnimOrigin.SELF, "duration": 0.8}},
		{"effect_type": EffectType.ATTRIBUTE, "duration": 1, "target": EffectTarget.SELF, "value": 4, "property": Attributes.FLUX, "dialog": "gained +4 flux until end of next turn", "animation": {"name": "ArmorInversionOther", "origin": AnimOrigin.OTHER, "duration": 0.8}},
		{"effect_type": EffectType.ATTRIBUTE, "duration": 1, "target": EffectTarget.SELF, "value": 4, "property": Attributes.MEMORY, "dialog": "gained +4 memory end of until next turn", "animation": {"name": "ArmorInversionSelf", "origin": AnimOrigin.OTHER, "duration": 0.8}}]},
		
	"Trample": {"name": "Trample", "ability_type": AbilityType.ATTACK, "damage": { "type": DamageType.PHYSICAL, "value": 70}, "action_cost": 3, "energy_cost": 0, "target_type": TargetType.ENEMY, "attribute_bonus": Attributes.STRENGTH, "description": "+70 physical damage. If a move action was made, increase damage by 20.", "range": Vector2i(3,1), "shape": AbilityShape.SINGLE, "effects": [], "animation": {"name": "Trample", "origin": AnimOrigin.OTHER, "duration": 0.8}},
	
	"Wave Beam": {"name": "Wave Beam", "ability_type": AbilityType.ATTACK, "damage":{ "type": DamageType.ENERGY, "value": 65}, "action_cost": 3, "energy_cost": 10, "target_type": TargetType.ENEMY, "attribute_bonus": Attributes.FLUX, "description": "65 energy damage dealt to enemy and enemy behind", "range": Vector2i(4,0), "shape": AbilityShape.DOUBLEH, "effects": [], "animation": {"name": "Wavebeam", "origin": AnimOrigin.OTHER, "duration": 0.8}},
	
	"Burst Rifle": {"name": "Burst Rifle", "ability_type": AbilityType.ATTACK, "damage": { "type": DamageType.PHYSICAL, "value": 90}, "action_cost": 3, "energy_cost": 5, "target_type": TargetType.ENEMY, "attribute_bonus": Attributes.NONE, "description": "90 physical damage. You gain +2 overheated.", "range": Vector2i(7,1), "shape": AbilityShape.SINGLE, "effects": [
		{"effect_type": EffectType.AILMENT, "target": EffectTarget.SELF, "value": 2, "property":
			Ailments.OVERHEATED, "dialog": "gained 2 overheated",}], "animation": {"name": "BurstRifle", "origin": AnimOrigin.OTHER, "duration": 0.8, "offset": -40}},
		
	"Self Repair": {"name": "Self Repair", "ability_type": AbilityType.EFFECT, "damage":{ "type": DamageType.PHYSICAL, "value": -75}, "action_cost": 3, "energy_cost": 12, "target_type": TargetType.HERO, "attribute_bonus": Attributes.NONE, "description": "Restore 75 health. On your next turn, restore 75 health, then skip the turn.", "range": Vector2i(0,0), "shape": AbilityShape.LINE, "effects": [], "animation": {"name": "Wavebeam", "origin": AnimOrigin.OTHER, "duration": 0.8}},
	
	"Rallied Surge": {"name": "Rallied Surge", "ability_type": AbilityType.EFFECT, "damage": { "type": DamageType.NONE, "value": 0}, "action_cost": 3, "energy_cost": 20, "target_type": TargetType.HERO, "attribute_bonus": Attributes.NONE, "description": "Each adjacent ally gains +2 Strength and +2 Flux", "range": Vector2i.ZERO, "shape": AbilityShape.SQUARE, "effects": [
		{"effect_type": EffectType.ATTRIBUTE, "duration": -1, "target": EffectTarget.SELF, "value": 2, "property": Attributes.STRENGTH, "dialog": "gained 2 power", "animation": {"name": "ArmorInversionOther", "origin": AnimOrigin.OTHER, "duration": 0.8}},
		{"effect_type": EffectType.ATTRIBUTE, "duration": -1, "target": EffectTarget.SELF, "value": 2, "property": Attributes.MEMORY, "dialog": "gained 2 flux", "animation": {"name": "ArmorInversionSelf", "origin": AnimOrigin.OTHER, "duration": 0.8}}]},
		
	"Seeker Rockets": {"name": "Seeker Rockets", "ability_type": AbilityType.ATTACK, "damage":{ "type": DamageType.PHYSICAL, "value": 45}, "action_cost": 3, "energy_cost": 0, "target_type": TargetType.ENEMY, "attribute_bonus": Attributes.NONE, "description": "Two random enemies are dealt 40 physical damage.", "range": Vector2i(4,1), "shape": AbilityShape.SINGLE, "effects": [], "animation": {"name": "Wavebeam", "origin": AnimOrigin.OTHER, "duration": 0.8}},
		
	"Crush": {"name": "Crush", "ability_type": AbilityType.ATTACK, "damage": {"type": DamageType.PHYSICAL, "value": 70}, "action_cost": 3, "energy_cost": 0, "target_type": TargetType.ENEMY, "attribute_bonus": Attributes.STRENGTH, "description": "A melee attack that applies -1 strength", "range": Vector2i(4,0), "shape": AbilityShape.MELEE, "animation": {"name": "Crush", "origin": AnimOrigin.OTHER, "duration": 0.8}, "effects": [
		{"effect_type": EffectType.AILMENT, "target": EffectTarget.OTHER, "value": 1, "property":
			Ailments.CONCUSSED, "dialog": "gained 1 concussed"}]},
			
	"Beam Slice": {"name": "Beam Slice", "ability_type": AbilityType.ATTACK, "damage": { "type": DamageType.ENERGY, "value": 80}, "action_cost": 3, "energy_cost": 0, "target_type": TargetType.ENEMY, "attribute_bonus": Attributes.STRENGTH, "description": "80 energy damage.", "range": Vector2i(3,1), "shape": AbilityShape.SINGLE, "effects": [], "animation": {"name": "BeamSlice", "origin": AnimOrigin.OTHER, "duration": 0.8}},
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
	"Mage": {"name": "Mage", "attributes": {Data.Attributes.STRENGTH: 1, Data.Attributes.FLUX: 5, Data.Attributes.ARMOR: 2, Data.Attributes.SHIELDING: 4, Data.Attributes.MEMORY: 2, Data.Attributes.BATTERY: 3, Data.Attributes.OPTICS: 3, Data.Attributes.MOBILITY: 2}, "abilities": ["Heat Ray", "Ignite", "Zap", "Process Crunch", "Wave Beam", "Screen Flash"], "base energy": 100, "base health": 340, "role": Data.MachineRole.ESNIPER, "path": "res://Scenes/Battle/Characters/Mage/mage.tscn"},
	
	"Runt": {"name": "Runt", "attributes": {Data.Attributes.STRENGTH: 2, Data.Attributes.FLUX: 1, Data.Attributes.ARMOR: 4, Data.Attributes.SHIELDING: 1, Data.Attributes.MEMORY: 1, Data.Attributes.BATTERY: 1, Data.Attributes.OPTICS: 1, Data.Attributes.MOBILITY: 2}, "abilities": ["Ripjaw", "Reinforce", "Acid Cloud", "Power Strike"], "base energy": 100, "base health": 320, "role": Data.MachineRole.PTANK, "path": "res://Scenes/Battle/Characters/Runt/runt.tscn"},
	
	"Pilypile": {"name": "Pilypile", "attributes": {Data.Attributes.STRENGTH: 2, Data.Attributes.FLUX: 1, Data.Attributes.ARMOR: 3, Data.Attributes.SHIELDING: 2, Data.Attributes.MEMORY: 2, Data.Attributes.BATTERY: 2, Data.Attributes.OPTICS: 1, Data.Attributes.MOBILITY: 1}, "abilities": ["Contemplate", "Sonic Pulse", "Bulk Inversion", "Self Repair"], "base energy": 100, "base health": 340, "role": Data.MachineRole.ETANK, "path": "res://Scenes/Battle/Characters/Pilypile/pilypile.tscn"},
	
	"Gawkingstick": {"name": "Gawkingstick", "attributes": {Data.Attributes.STRENGTH: 1, Data.Attributes.FLUX: 2, Data.Attributes.ARMOR: 2, Data.Attributes.SHIELDING: 2, Data.Attributes.MEMORY: 4, Data.Attributes.BATTERY: 1, Data.Attributes.OPTICS: 2, Data.Attributes.MOBILITY: 1}, "abilities": ["Wave Beam", "Screen Flash", "Contemplate", "Zap", "Heat Ray"], "base energy": 100, "base health": 320, "role": Data.MachineRole.EOSUPPORT, "path": "res://Scenes/Battle/Characters/Gawkingstick/norman.tscn"},
	
	"Mandrake": {"name": "Mandrake", "attributes": {Data.Attributes.STRENGTH: 1, Data.Attributes.FLUX: 3, Data.Attributes.ARMOR: 2, Data.Attributes.SHIELDING: 1, Data.Attributes.MEMORY: 3, Data.Attributes.BATTERY: 2, Data.Attributes.OPTICS: 2, Data.Attributes.MOBILITY: 2}, "abilities": ["Zap", "Process Crunch", "Ignite", "Trample"], "base energy": 100, "base health": 300, "role": Data.MachineRole.ESNIPER, "path": "res://Scenes/Battle/Characters/Mandrake/mandrake.tscn"},
	
	"Thumper": {"name": "Thumper", "attributes": {Data.Attributes.STRENGTH: 2, Data.Attributes.FLUX: 1, Data.Attributes.ARMOR: 1, Data.Attributes.SHIELDING: 1, Data.Attributes.MEMORY: 2, Data.Attributes.BATTERY: 2, Data.Attributes.OPTICS: 2, Data.Attributes.MOBILITY: 4}, "abilities": ["Screen Flash", "Zap", "Power Strike", "Contemplate"], "base energy": 100, "base health": 300, "role": Data.MachineRole.PASSAULTER, "path": "res://Scenes/Battle/Characters/Thumper/thumper.tscn"},
	}
	
var dialog = {
"newsboy": {
	"name": "newsboy",
	"variants": [{
		"type": "options_variant",
		"flag": "egg_charger_greeted",
		"branch": "newspaper2",
		"options": [
			{"name": "Egg Charger", "next": "eggcharger"},
			{"name": "Tram", "next": "tram"},
			{"name": "Leave", "next": null}]
				}, {
		"type": "next_variant",
		"flag": "newsboy_leave_attempted",
		"option_name": "Leave",
		"next": null}],
	"default": {
		"text": "(The Newsboy rests against a waste receptacle as he waves a scroll of printed paper. His walkers have been broken into a pile of twigs. There was an attempt to mend the hobbled legs back together but it looks as though he gave up halfway through.)",
		"options": [
			{"name": "Proceed", "next": "greeting"},
			{"name": "Leave", "next": "leave01"}]
			},
	"greeting": {
		"text": "Extra! Extra! Read all about it! Top Church hikes tithes! Dean of Denominations descends from Stovetop for tax collections!",
		"options": [
			{"name": "Proceed", "next": "stovetop"},
			{"name": "Leave", "next": "leave01"}]
			},
	"stovetop": {
		"text": "(The name 'Stovetop' exists in your dictionary. No definition or contextual data available.)",
		"options": [
			{"name": "From where?", "next": "stovetop2"},
			{"name": "Leave", "next": "leave01"}]
			},
	"stovetop2": {
		"text": "What's the matter, mista? Don't'cha read the paper?",
		"options": [
			{"name": "Take the paper", "next": "newspaper"},
			{"name": "Leave", "next": "leave01"}]
			},
	"newspaper": {
		"text": "(The headline of the paper reads 'Stovetop Officials Grace the Lowland Districts' and the subject reads 'Historic First! Top Dean Comes to Strengthen the Faith'.)",
		"options": [
			{"name": "Proceed", "next": "newspaper2"},
			{"name": "Leave", "next": "leave01"}]
			},
	"newspaper2": {
		"text": "Hey! That costs a two-cell, pal!",
		"options": [
			{"name": "Tram", "next": "tram"},
			{"name": "Leave", "next": null}]
			},
	"eggcharger": {
		"text": "The Egg Charger over there? No idea, pal. Are you gonna buy a paper or not?",
		"options": [
			{"name": "Tram", "next": "tram"},
			{"name": "Leave", "next": "leave01"}]
			},
	"tram": {
		"text": "That? Couldn't help ya, pal. Hasn't budged in years. Figured it was one of Top's pointless architectural displays. The whole city's taken by round shapes.",
		"options": [
			{"name": "Tram", "next": "tram"},
			{"name": "Leave", "next": "leave01"}]
			},
	"leave01": {
		"text": "You'd take care not to head east, pal. The airfield's been run amok by a mad-wired bull!",
		"options": [
			{"name": "Broken Legs", "next": "leave02"},
			{"name": "Leave", "next": null}]
			},
	"leave02": {
		"text": "It was them miserable pilgrims that did me in like this. Said somethin’ about how buying my own batteries is blasphemy. I tell ya, everything’s blasphemy with those bolt-heads. A bot’s got a right to live, don’t he?",
		"options": [
			{"name": "Leave", "next": null}]
			},
		},
"eggcharger":
	{
	"name": "eggcharger",
	"variants": [],
	"default": {
		"text": "(A broken egg charger machine. Though the shell is cracked open, its battery vault remains securely locked in place.)",
		"options": [
			{"name": "Investigate", "next": "investigate"},
			{"name": "Leave", "next": null}]
			},
	"investigate": {
		"text": "This egg is crazy.",
		"options": [
			{"name": "Take egg", "next": "take egg"},
			{"name": "Investigate", "next": "investigate2"},
			{"name": "Interrogate", "next": "interrogate"},
			{"name": "Leave", "next": null}]	
			},
	"investigate2": {
		"text": "It's not that crazy actually.",
		"options": [
			{"name": "Take egg", "next": "take egg"},
			{"name": "Interrogate", "next": "interrogate"},
			{"name": "Leave", "next": null}]
			},
	"interrogate": {
		"text": "The egg is silent.",
		"options": [
			{"name": "Investigate", "next": "investigate"},
			{"name": "Interrogate", "next": "interrogate2"},
			{"name": "Leave", "next": null}]
			},
	"interrogate2": {
		"text": "The egg remains stoic.",
		"options": [
			{"name": "Take egg", "next": "take egg"},
			{"name": "Leave", "next": null}]
			},
	"take egg": {
		"text": "You took the egg.",
		"options": [
			{"name": "Leave", "next": null}]
			},
	},
"tram": {
	"name": "tram",
	"variants": [],
	"default": {
		"text": "This tram is trammin.",
		"options": [
			{"name": "Leave", "next": null}]
			},
	},
"accumulator": {
	"name": "accumulator",
	"variants": [],
	"default": {
		"text": "It seems to be accumulating.",
		"options": [
			{"name": "Leave", "next": null}]
			},
	},
"tram_console": {
	"name": "tram_console",
	"variants": [{
		"type": "options_variant",
		"flag": "tram_console_button_pressed",
		"branch": "default",
		"options": [
			{"name": "Call Button", "next": "trambutton02"},
			{"name": "Open Panel", "next": "panel01"},
			{"name": "Leave", "next": null}]}
		],
	"default": {
		"text": "(The screen on the tram console is off. Below the screen is a call button. Along the base of the console, its panel is ajar.)",
		"options": [
			{"name": "Call Button", "next": "trambutton01"},
			{"name": "Open Panel", "next": "panel01"},
			{"name": "Leave", "next": null}]
			},
	"trambutton01": {
		"text": "(No reaction. The railway station is unpowered.)",
		"options": [
			{"name": "Open Panel", "next": "panel01"},
			{"name": "Leave", "next": null}]
			},
	"trambutton02": {
		"text": "(The button clicks. Nothing happens. The railway station remains unpowered.)",
		"options": [
			{"name": "Open Panel", "next": "panel01"},
			{"name": "Leave", "next": null}]
			},
	"panel01": {
		"text": "(Inside is the housing for a battery stack but it's empty.)",
		"options": [
			{"name": "Insert Battery[500]", "next": "panel02"},
			{"name": "Leave", "next": null}]
			},
	"panel02": {
		"text": "You win!",
		"options": [
			{"name": "Insert Battery[500]", "next": "panel02"},
			{"name": "Leave", "next": null}]
			},
		},
"repository": {
	"name": "repository",
	"variants": [],
	"default": {
		"text": "(There is a slot where battery cells can be inserted. The call button will send your deposit through a tube that leads to the reactor.)",
		"options": [
			{"name": "Insert Batteries[10]", "next": "repository01"},
			{"name": "Leave", "next": null}]
			},
	"repository01": {
		"text": "(The machine prints out a ticket.)[p][center]Thank you for your contribution.",
		"options": [
			{"name": "Leave", "next": null}]
			},
		},
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
