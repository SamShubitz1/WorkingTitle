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
	MOVEMENT
}

enum MenuType {
	MainMenuType,
	BattleMenuType
}

enum AttackShape {
	SINGLE,
	LINE,
	SQUARE,
	DIAMOND
}

enum DamageType {
	PHYSICAL,
	ENERGY,
	NONE
}

enum TargetType {
	HERO,
	ENEMY,
	SELF
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

enum EffectType {
	STATUS,
	ATTRIBUTE,
	AILMENT
}

enum EffectTarget {
	OTHER,
	SELF
}

# abilties deals damage, heal, affects attributes + or -, changes status

# name: string
# attribute_bonus: Enum Attributes
# damage_type: PHYSICAL, ENERGY
# damage: int
# description: string
# target: ENEMY, HERO, SELF
# shape: SINGLE, DIAMOND, LINE, SQUARE
# effect: {"type": ATTRIBUTES, "value": -2, "effected_property": Attributes.ARMOR}

var abilities: Dictionary = {
	"Clobber": {"name": "Clobber", "damage": { "damage_type": DamageType.PHYSICAL, "damage_value": 80}, "action_cost": 3, "target_type": TargetType.ENEMY, "attribute_bonus": Attributes.STRENGTH, "description": "A simple melee attack", "range": Vector2i(3,1), "shape": AttackShape.SINGLE, "effects": [], "animation": {"name": "Clobber", "duration": 0.8}},
	
	"Laser": {"name": "Laser", "damage": { "damage_type": DamageType.ENERGY, "damage_value": 60}, "action_cost": 3, "target_type": TargetType.ENEMY, "attribute_bonus": Attributes.FLUX, "description": "Deals damage to all enemies in a line", "range": Vector2i.ZERO, "shape": AttackShape.LINE, "effects": [], "animation": {"name": "Laser", "duration": 0.8}},
	
	"Bite": {"name": "Bite", "damage": { "damage_type": DamageType.PHYSICAL, "damage_value": 70}, "action_cost": 3, "target_type": TargetType.ENEMY, "attribute_bonus": Attributes.STRENGTH, "description": "A melee attack that reduces armor by 1", "range": Vector2i(3,1), "shape": AttackShape.SINGLE, "effects": [{"effect_type": EffectType.ATTRIBUTE, "effect_target": EffectTarget.OTHER, "effect_value": -1, "affected_property": Attributes.ARMOR, "effect_description": "lost 1 armor"}], "animation": {"name": "Bite", "duration": 0.8}},
	
	"Reinforce": {"name": "Reinforce", "damage": { "damage_type": DamageType.NONE, "damage_value": 0}, "action_cost": 3, "target_type": TargetType.HERO, "attribute_bonus": Attributes.NONE, "description": "Increases armor to allies in a line", "range": Vector2i.ZERO, "shape": AttackShape.LINE, "effects": [
		{"effect_type": EffectType.ATTRIBUTE, "effect_target": EffectTarget.OTHER, "effect_value": 1, "affected_property": Attributes.ARMOR, "effect_description": "gained 1 armor", "effect_animation": {"name": "Reinforce", "duration": 0.8}}]},
	
	"Wave Beam": {"name": "Wave Beam", "damage":{ "damage_type": DamageType.ENERGY, "damage_value": 75}, "action_cost": 3, "target_type": TargetType.ENEMY, "attribute_bonus": Attributes.FLUX, "description": "A simple energy attack", "range": Vector2i(2,0), "shape": AttackShape.SINGLE, "effects": [], "animation": {"name": "Wavebeam", "duration": 0.8}},
	
	"Armor Inversion": {"name": "Armor Inversion", "damage": { "damage_type": DamageType.NONE, "damage_value": 0}, "action_cost": 3, "target_type": TargetType.ENEMY, "attribute_bonus": Attributes.NONE, "description": "Steals 2 armor from a target", "range": Vector2i(4,2), "shape": AttackShape.SINGLE, "effects": [
		{"effect_type": EffectType.ATTRIBUTE, "effect_target": EffectTarget.OTHER, "effect_value": -2, "affected_property": Attributes.ARMOR, "effect_description": "lost 2 armor", "effect_animation": {"name": "ArmorInversionOther", "duration": 0.9}},
		{"effect_type": EffectType.ATTRIBUTE, "effect_target": EffectTarget.SELF, "effect_value": +2, "affected_property": Attributes.ARMOR, "effect_description": "gained 2 armor", "effect_animation": {"name": "ArmorInversionSelf", "duration": 0.9}}]
		}}
	
var items: Dictionary = {
	"Extra Rock": {"name": "Extra Rock", "effect_type": "Rock", "effect_description": "Rock attack went up!", "menu_description": "Adds damage to rock attacks", "multiplier": .3},
	
	"Sharpener":{"name": "Sharpener", "effect_type": "Scissors", "effect_description": "Scissors attack went up!", "menu_description": "Adds damage to scissors attacks", "multiplier": .3},
	
	"Extra Paper":{"name": "Extra Paper", "effect_type": "Paper", "effect_description": "Paper attack went up!", "menu_description": "Adds damage to paper attacks", "multiplier": .3}}
	
var animations = {
"ArmorInversionTarget": "res://Scenes/Battle/Animations/Abi_Armorinversion_Enemy.png",
"ArmorInversionSelf": "res://Scenes/Battle/Animations/Abi_Armorinversion_Enemy.png",
"Bite": "res://Scenes/Battle/Animations/Abi_Bite.png",
"Clobber": "res://Scenes/Battle/Animations/Abi_Clobber.png",
"Laser": "res://Scenes/Battle/Animations/Abi_Laser.png",
"Reinforce": "res://Scenes/Battle/Animations/Abi_Reinforce.png",
"Wavebeam": "res://Scenes/Battle/Animations/Abi_Wavebeam.png"
}

var pokedex = {
	"Bulbasaur": {"name": "Bulbasaur", "type": ["Grass", "Poison"], "description": "A small, squat Pokémon with a plant bulb on its back, which grows into a large plant as it evolves."},
	"Ivysaur": {"name": "Ivysaur", "type": ["Grass", "Poison"], "description": "The evolved form of Bulbasaur, with a larger plant on its back that blooms into a flower."},
	"Venusaur": {"name": "Venusaur", "type": ["Grass", "Poison"], "description": "The final form of Bulbasaur, with a massive flower blooming from its back."},
	"Charmander": {"name": "Charmander", "type": ["Fire"], "description": "A small dinosaur-like Pokémon with a flame at the tip of its tail."},
	"Charmeleon": {"name": "Charmeleon", "type": ["Fire"], "description": "The evolved form of Charmander, with a more aggressive attitude and stronger flame."},
	"Charizard": {"name": "Charizard", "type": ["Fire", "Flying"], "description": "A dragon-like Pokémon that can breathe intense flames and fly at high speeds."},
	"Squirtle": {"name": "Squirtle", "type": ["Water"], "description": "A small turtle Pokémon that is quick and can shoot water from its mouth."},
	"Wartortle": {"name": "Wartortle", "type": ["Water"], "description": "The evolved form of Squirtle, with a more powerful shell and greater aquatic abilities."},
	"Blastoise": {"name": "Blastoise", "type": ["Water"], "description": "The final evolution of Squirtle, with massive cannons on its back for powerful water blasts."},
	"Caterpie": {"name": "Caterpie", "type": ["Bug"], "description": "A small, green worm-like Pokémon that evolves into Metapod."},
	"Metapod": {"name": "Metapod", "type": ["Bug"], "description": "The cocoon stage of Caterpie, preparing for its final evolution into Butterfree."},
	"Butterfree": {"name": "Butterfree", "type": ["Bug", "Flying"], "description": "The fully evolved form of Caterpie, now a butterfly with strong wings and a dust-like powder."},
	"Weedle": {"name": "Weedle", "type": ["Bug", "Poison"], "description": "A small, poisonous bug Pokémon with a stinger on its tail."},
	"Kakuna": {"name": "Kakuna", "type": ["Bug", "Poison"], "description": "The cocoon stage of Weedle, which will soon evolve into Beedrill."},
	"Beedrill": {"name": "Beedrill", "type": ["Bug", "Poison"], "description": "The fully evolved form of Weedle, a dangerous insect with stingers on its arms."},
	"Pidgey": {"name": "Pidgey", "type": ["Normal", "Flying"], "description": "A small bird Pokémon commonly found in forests and fields."},
	"Pidgeotto": {"name": "Pidgeotto", "type": ["Normal", "Flying"], "description": "The evolved form of Pidgey, a larger and faster bird."},
	"Pidgeot": {"name": "Pidgeot", "type": ["Normal", "Flying"], "description": "The final form of Pidgey, with majestic wings and extreme flying speed."},
	"Rattata": {"name": "Rattata", "type": ["Normal"], "description": "A small, fast rodent Pokémon known for its quick movements."},
	"Raticate": {"name": "Raticate", "type": ["Normal"], "description": "The evolved form of Rattata, with sharp teeth and a powerful bite."},
	"Spearow": {"name": "Spearow", "type": ["Normal", "Flying"], "description": "A small, aggressive bird Pokémon known for its sharp beak."},
	"Fearow": {"name": "Fearow", "type": ["Normal", "Flying"], "description": "The evolved form of Spearow, a powerful bird with a long, sharp beak."},
	"Ekans": {"name": "Ekans", "type": ["Poison"], "description": "A snake-like Pokémon that can coil up and use poison in battle."},
	"Arbok": {"name": "Arbok", "type": ["Poison"], "description": "The evolved form of Ekans, with a large, intimidating cobra-like appearance."},
	"Pikachu": {"name": "Pikachu", "type": ["Electric"], "description": "A small, electric-type Pokémon known for its lightning bolt-shaped tail and ability to generate electricity."},
	"Raichu": {"name": "Raichu", "type": ["Electric"], "description": "The evolved form of Pikachu, a stronger and faster electric-type."},
	"Sandshrew": {"name": "Sandshrew", "type": ["Ground"], "description": "A small, armadillo-like Pokémon that burrows underground."},
	"Sandslash": {"name": "Sandslash", "type": ["Ground"], "description": "The evolved form of Sandshrew, with tougher spines and the ability to roll into a ball."},
	"Nidoran♀": {"name": "Nidoran♀", "type": ["Poison"], "description": "A small, rabbit-like Pokémon with a strong poison in its horn."},
	"Nidorina": {"name": "Nidorina", "type": ["Poison"], "description": "The evolved form of Nidoran♀, stronger and with more developed features."},
	"Nidoqueen": {"name": "Nidoqueen", "type": ["Poison", "Ground"], "description": "The final form of Nidoran♀, a large and powerful Pokémon with a horn on its head."},
	"Nidoran♂": {"name": "Nidoran♂", "type": ["Poison"], "description": "A male counterpart to Nidoran♀, with a smaller horn but a stronger build."},
	"Nidorino": {"name": "Nidorino", "type": ["Poison"], "description": "The evolved form of Nidoran♂, a more aggressive Pokémon with sharper horns."},
	"Nidoking": {"name": "Nidoking", "type": ["Poison", "Ground"], "description": "The final form of Nidoran♂, a massive creature with brute strength and powerful attacks."},
	"Clefairy": {"name": "Clefairy", "type": ["Fairy"], "description": "A cute, small fairy-like Pokémon that comes out at night."},
	"Clefable": {"name": "Clefable", "type": ["Fairy"], "description": "The evolved form of Clefairy, a large and more magical creature."},
	"Vulpix": {"name": "Vulpix", "type": ["Fire"], "description": "A small, fox-like Pokémon with six fiery tails."},
	"Ninetales": {"name": "Ninetales", "type": ["Fire"], "description": "The evolved form of Vulpix, with nine tails that have magical properties."},
	"Jigglypuff": {"name": "Jigglypuff", "type": ["Normal", "Fairy"], "description": "A round, pink Pokémon known for singing lullabies that put others to sleep."},
	"Wigglytuff": {"name": "Wigglytuff", "type": ["Normal", "Fairy"], "description": "The evolved form of Jigglypuff, with a softer body and stronger singing abilities."},
	"Zubat": {"name": "Zubat", "type": ["Poison", "Flying"], "description": "A bat-like Pokémon that uses echolocation to navigate in the dark."},
	"Golbat": {"name": "Golbat", "type": ["Poison", "Flying"], "description": "The evolved form of Zubat, now with a larger mouth and sharper fangs."},
	"Oddish": {"name": "Oddish", "type": ["Grass", "Poison"], "description": "A small, plant-like Pokémon that grows in shady areas and releases pollen."},
	"Gloom": {"name": "Gloom", "type": ["Grass", "Poison"], "description": "The evolved form of Oddish, with a large, smelly flower that can emit toxic spores."},
	"Vileplume": {"name": "Vileplume", "type": ["Grass", "Poison"], "description": "The final evolution of Oddish, with a massive, toxic flower on its back."},
	"Paras": {"name": "Paras", "type": ["Bug", "Grass"], "description": "A small mushroom Pokémon that is often seen in damp, wooded areas."},
	"Parasect": {"name": "Parasect", "type": ["Bug", "Grass"], "description": "The evolved form of Paras, with a large mushroom growing on its back."},
	"Venonat": {"name": "Venonat", "type": ["Bug", "Poison"], "description": "A small, insect-like Pokémon with big eyes that can detect predators."},
	"Venomoth": {"name": "Venomoth", "type": ["Bug", "Poison"], "description": "The evolved form of Venonat, with moth-like wings and a poisonous powder."},
	"Diglett": {"name": "Diglett", "type": ["Ground"], "description": "A small, mole-like Pokémon that burrows underground."},
	"Dugtrio": {"name": "Dugtrio", "type": ["Ground"], "description": "The evolved form of Diglett, with three Digletts emerging from the ground."},
	"Meowth": {"name": "Meowth", "type": ["Normal"], "description": "A cat-like Pokémon that loves shiny objects and can walk on two legs."},
	"Persian": {"name": "Persian", "type": ["Normal"], "description": "The evolved form of Meowth, with a sleek and elegant appearance."},
	"Psyduck": {"name": "Psyduck", "type": ["Water"], "description": "A headache-prone duck Pokémon with psychic powers when it gets a severe headache."},
	"Golduck": {"name": "Golduck", "type": ["Water"], "description": "The evolved form of Psyduck, with greater control over its psychic abilities."},
	"Mankey": {"name": "Mankey", "type": ["Fighting"], "description": "A small, aggressive monkey-like Pokémon that is quick to anger."},
	"Primeape": {"name": "Primeape", "type": ["Fighting"], "description": "The evolved form of Mankey, known for its intense anger and fierce fighting style."},
	"Growlithe": {"name": "Growlithe", "type": ["Fire"], "description": "A small, dog-like Pokémon with a playful and loyal nature."},
	"Arcanine": {"name": "Arcanine", "type": ["Fire"], "description": "The evolved form of Growlithe, a majestic and powerful fire Pokémon."},
	"Poliwag": {"name": "Poliwag", "type": ["Water"], "description": "A tadpole-like Pokémon that uses its tail to swim swiftly."},
	"Poliwhirl": {"name": "Poliwhirl", "type": ["Water"], "description": "The evolved form of Poliwag, with a strong, spiraling body and greater swimming ability."},
	"Politoed": {"name": "Politoed", "type": ["Water"], "description": "The final evolution of Poliwag, now with a more frog-like appearance and a croak."},
	"Abra": {"name": "Abra", "type": ["Psychic"], "description": "A psychic Pokémon that teleports away whenever it feels threatened."},
	"Kadabra": {"name": "Kadabra", "type": ["Psychic"], "description": "The evolved form of Abra, with a spoon it uses to focus its psychic powers."},
	"Alakazam": {"name": "Alakazam", "type": ["Psychic"], "description": "The final form of Abra, a highly intelligent and powerful psychic Pokémon."},
	"Machop": {"name": "Machop", "type": ["Fighting"], "description": "A small, muscular Pokémon that trains its body for battle."},
	"Machoke": {"name": "Machoke", "type": ["Fighting"], "description": "The evolved form of Machop, with immense strength and endurance."},
	"Machamp": {"name": "Machamp", "type": ["Fighting"], "description": "The final form of Machop, known for its four powerful arms and immense strength."},
	"Bellsprout": {"name": "Bellsprout", "type": ["Grass", "Poison"], "description": "A plant-like Pokémon that can shoot toxic spores and whip enemies with its vine."},
	"Weepinbell": {"name": "Weepinbell", "type": ["Grass", "Poison"], "description": "The evolved form of Bellsprout, with a bell-shaped flower that can swallow prey."},
	"Victreebel": {"name": "Victreebel", "type": ["Grass", "Poison"], "description": "The final evolution of Bellsprout, a large and dangerous plant capable of trapping prey."},
	"Tentacool": {"name": "Tentacool", "type": ["Water", "Poison"], "description": "A jellyfish-like Pokémon that uses tentacles to trap its prey."},
	"Tentacruel": {"name": "Tentacruel", "type": ["Water", "Poison"], "description": "The evolved form of Tentacool, with larger, more dangerous tentacles."},
	"Geodude": {"name": "Geodude", "type": ["Rock", "Ground"], "description": "A rock-like Pokémon that can roll and move quickly despite its size."},
	"Graveler": {"name": "Graveler", "type": ["Rock", "Ground"], "description": "The evolved form of Geodude, with a sturdier body and greater strength."},
	"Golem": {"name": "Golem", "type": ["Rock", "Ground"], "description": "The final evolution of Geodude, an enormous and powerful Pokémon with a rocky body."},
	"Ponyta": {"name": "Ponyta", "type": ["Fire"], "description": "A small, horse-like Pokémon with fiery mane and tail."},
	"Rapidash": {"name": "Rapidash", "type": ["Fire"], "description": "The evolved form of Ponyta, with a graceful and swift body that can run at high speeds."},
	"Magnemite": {"name": "Magnemite", "type": ["Electric", "Steel"], "description": "A small, magnetic Pokémon that floats using its electromagnetic abilities."},
	"Magneton": {"name": "Magneton", "type": ["Electric", "Steel"], "description": "The evolved form of Magnemite, consisting of three connected Magnemites."},
	"Farfetch'd": {"name": "Farfetch'd", "type": ["Normal", "Flying"], "description": "A duck-like Pokémon carrying a leek, known for its clumsy nature."},
	"Doduo": {"name": "Doduo", "type": ["Normal", "Flying"], "description": "A two-headed bird Pokémon that runs quickly."},
	"Dodrio": {"name": "Dodrio", "type": ["Normal", "Flying"], "description": "The evolved form of Doduo, now with three heads and even greater speed."},
	"Seel": {"name": "Seel", "type": ["Water"], "description": "A seal-like Pokémon that enjoys playing in the water."},
	"Dewgong": {"name": "Dewgong", "type": ["Water", "Ice"], "description": "The evolved form of Seel, an aquatic mammal with icy abilities."},
	"Grimer": {"name": "Grimer", "type": ["Poison"], "description": "A toxic, sludge-like Pokémon that thrives in polluted environments."},
	"Muk": {"name": "Muk", "type": ["Poison"], "description": "The evolved form of Grimer, a giant, amorphous creature made of toxic sludge."},
	"Shellder": {"name": "Shellder", "type": ["Water"], "description": "A clam-like Pokémon with a strong shell that it can close rapidly."},
	"Cloyster": {"name": "Cloyster", "type": ["Water", "Ice"], "description": "The evolved form of Shellder, a tough and defensive Pokémon with sharp shells."},
	"Gastly": {"name": "Gastly", "type": ["Ghost", "Poison"], "description": "A floating, gaseous Pokémon that can turn invisible and pass through walls."},
	"Haunter": {"name": "Haunter", "type": ["Ghost", "Poison"], "description": "The evolved form of Gastly, a mischievous and haunting Pokémon."},
	"Gengar": {"name": "Gengar", "type": ["Ghost", "Poison"], "description": "The final evolution of Gastly, a shadowy, mischievous Pokémon with the ability to cause fear."},
	"Onix": {"name": "Onix", "type": ["Rock", "Ground"], "description": "A massive, snake-like Pokémon made entirely of rocks."},
	"Drowzee": {"name": "Drowzee", "type": ["Psychic"], "description": "A sleep-inducing Pokémon with hypnotic abilities."},
	"Hypno": {"name": "Hypno", "type": ["Psychic"], "description": "The evolved form of Drowzee, known for its powerful hypnosis skills."},
	"Krabby": {"name": "Krabby", "type": ["Water"], "description": "A small, crab-like Pokémon that lives in shallow coastal waters."},
	"Kingler": {"name": "Kingler", "type": ["Water"], "description": "The evolved form of Krabby, now with massive claws capable of crushing opponents."},
	"Exeggcute": {"name": "Exeggcute", "type": ["Grass", "Psychic"], "description": "A group of six egg-like Pokémon that work together as one."},
	"Exeggutor": {"name": "Exeggutor", "type": ["Grass", "Psychic"], "description": "The evolved form of Exeggcute, a tall tree-like Pokémon with multiple heads."},
	"Cubone": {"name": "Cubone", "type": ["Ground"], "description": "A small, lonely Pokémon wearing the skull of its deceased mother."},
	"Marowak": {"name": "Marowak", "type": ["Ground"], "description": "The evolved form of Cubone, now wielding a bone club as a weapon."},
	"Kangaskhan": {"name": "Kangaskhan", "type": ["Normal"], "description": "A powerful, kangaroo-like Pokémon with a baby in its pouch."},
	"Horsea": {"name": "Horsea", "type": ["Water"], "description": "A small, seahorse-like Pokémon that can shoot water jets."},
	"Seadra": {"name": "Seadra", "type": ["Water"], "description": "The evolved form of Horsea, now with more powerful water abilities."},
	"Goldeen": {"name": "Goldeen", "type": ["Water"], "description": "A graceful, fish-like Pokémon that loves swimming in clean water."},
	"Seaking": {"name": "Seaking", "type": ["Water"], "description": "The evolved form of Goldeen, a beautiful fish known for its speed."},
	"Staryu": {"name": "Staryu", "type": ["Water"], "description": "A star-shaped Pokémon that can regenerate limbs and has a jewel in its center."},
	"Starmie": {"name": "Starmie", "type": ["Water", "Psychic"], "description": "The evolved form of Staryu, with powerful psychic abilities."},
	"Mr. Mime": {"name": "Mr. Mime", "type": ["Psychic", "Fairy"], "description": "A clown-like Pokémon that can create invisible walls and perform psychic tricks."},
	"Scyther": {"name": "Scyther", "type": ["Bug", "Flying"], "description": "A sleek, green insect-like Pokémon with sharp scythes for arms."},
	"Jynx": {"name": "Jynx", "type": ["Ice", "Psychic"], "description": "A humanoid, ice-type Pokémon known for its hypnotic and chilly powers."},
	"Electabuzz": {"name": "Electabuzz", "type": ["Electric"], "description": "A powerful, electric-type Pokémon known for its speed and electric strikes."},
	"Magmar": {"name": "Magmar", "type": ["Fire"], "description": "A fiery, bird-like Pokémon that generates heat from its body."},
	"Pinsir": {"name": "Pinsir", "type": ["Bug"], "description": "A large, beetle-like Pokémon with strong pincers."},
	"Tauros": {"name": "Tauros", "type": ["Normal"], "description": "A wild bull Pokémon known for its ferocity and aggression."},
	"Magikarp": {"name": "Magikarp", "type": ["Water"], "description": "A weak, flopping fish Pokémon known for being useless in battle."},
	"Gyarados": {"name": "Gyarados", "type": ["Water", "Flying"], "description": "The evolved form of Magikarp, a terrifying sea serpent capable of destroying anything in its path."},
	"Lapras": {"name": "Lapras", "type": ["Water", "Ice"], "description": "A gentle, prehistoric Pokémon known for its ability to ferry people across the sea."},
	"Ditto": {"name": "Ditto", "type": ["Normal"], "description": "A shapeshifting Pokémon that can mimic any form it sees."},
	"Eevee": {"name": "Eevee", "type": ["Normal"], "description": "A small, fox-like Pokémon with the potential to evolve into various forms."},
	"Vaporeon": {"name": "Vaporeon", "type": ["Water"], "description": "The evolved form of Eevee, a sleek and powerful water-type."},
	"Jolteon": {"name": "Jolteon", "type": ["Electric"], "description": "The evolved form of Eevee, capable of generating powerful electric shocks."},
	"Flareon": {"name": "Flareon", "type": ["Fire"], "description": "The evolved form of Eevee, with flames enveloping its body."},
	"Porygon": {"name": "Porygon", "type": ["Normal"], "description": "A virtual Pokémon made entirely of computer data."},
	"Omanyte": {"name": "Omanyte", "type": ["Rock", "Water"], "description": "A small, ancient, shelled Pokémon that evolved from a prehistoric species."},
	"Omastar": {"name": "Omastar", "type": ["Rock", "Water"], "description": "The evolved form of Omanyte, now with larger tentacles and a sharper shell."},
	"Kabuto": {"name": "Kabuto", "type": ["Rock", "Water"], "description": "A small, ancient, horseshoe crab-like Pokémon."},
	"Kabutops": {"name": "Kabutops", "type": ["Rock", "Water"], "description": "The evolved form of Kabuto, now with sharp blades and a faster body."},
	"Aerodactyl": {"name": "Aerodactyl", "type": ["Rock", "Flying"], "description": "An ancient, pterodactyl-like Pokémon with sharp claws and wings."},
	"Mewtwo": {"name": "Mewtwo", "type": ["Psychic"], "description": "A genetically engineered Pokémon created from Mew, with incredible psychic power."},
	"Mew": {"name": "Mew", "type": ["Psychic"], "description": "A mythical Pokémon said to possess the ability to learn any move."}
}

var pokedex_entries = ["Bulbasaur", "Ivysaur", "Venusaur", "Charmander", "Charmeleon", "Charizard", "Squirtle", "Wartortle", "Blastoise", "Caterpie", "Metapod", "Butterfree", "Weedle", "Kakuna", "Beedrill", "Pidgey", "Pidgeotto", "Pidgeot", "Rattata", "Raticate", "Spearow", "Fearow", "Ekans", "Arbok", "Pikachu", "Raichu", "Sandshrew", "Sandslash", "Nidoran♀", "Nidorina", "Nidoqueen", "Nidoran♂", "Nidorino", "Nidoking", "Clefairy", "Clefable", "Vulpix", "Ninetales", "Jigglypuff", "Wigglytuff", "Zubat", "Golbat", "Oddish", "Gloom", "Vileplume", "Paras", "Parasect", "Venonat", "Venomoth", "Diglett", "Dugtrio", "Meowth", "Persian", "Psyduck", "Golduck", "Mankey", "Primeape", "Growlithe", "Arcanine", "Poliwag", "Poliwhirl", "Politoed", "Abra", "Kadabra", "Alakazam", "Machop", "Machoke", "Machamp", "Bellsprout", "Weepinbell", "Victreebel", "Tentacool", "Tentacruel", "Geodude", "Graveler", "Golem", "Ponyta", "Rapidash", "Magnemite", "Magneton", "Farfetch'd", "Doduo", "Dodrio", "Seel", "Dewgong", "Grimer", "Muk", "Shellder", "Cloyster", "Gastly", "Haunter", "Gengar", "Onix", "Drowzee", "Hypno", "Krabby", "Kingler", "Exeggcute", "Exeggutor", "Cubone", "Marowak", "Kangaskhan", "Horsea", "Seadra", "Goldeen", "Seaking", "Staryu", "Starmie", "Mr. Mime", "Scyther", "Jynx", "Electabuzz", "Magmar", "Pinsir", "Tauros", "Magikarp", "Gyarados", "Lapras", "Ditto", "Eevee", "Vaporeon", "Jolteon", "Flareon", "Porygon", "Omanyte", "Omastar", "Kabuto", "Kabutops", "Aerodactyl", "Mewtwo", "Mew"]
