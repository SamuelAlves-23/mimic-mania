extends Node

enum DAMAGE_TYPES{
	RAW,
	FIRE,
	ICE,
	THUNDER,
	WATER,
	TRUE
}

@onready var tile_size: int = 16
@onready var good_chests: int = 0
@onready var mimic_lvl: int = 1
@onready var total_gold: int = 0
@onready var current_gold: int = 0
@onready var mimic_chain:int = 0


func get_reward_chances() -> Dictionary:
	return {
		"gold" : 41 - (2 * good_chests) + (4 * mimic_chain),
		"stat": 39,
		"mimic": 20 + (2 * good_chests) - (4 * mimic_chain)
	}

func get_damage_type(index: int) -> DAMAGE_TYPES:
	match index:
		0:
			return DAMAGE_TYPES.RAW
		1:
			return DAMAGE_TYPES.FIRE
		2:
			return DAMAGE_TYPES.ICE
		3:
			return DAMAGE_TYPES.THUNDER
		4:
			return DAMAGE_TYPES.WATER
		5:
			return DAMAGE_TYPES.TRUE
	return DAMAGE_TYPES.RAW
