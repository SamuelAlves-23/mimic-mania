extends Node


@export var stats: Dictionary = {
	"hp" : 100,
	"attack" : 10,
	"defense" : 5,
	#"damage_type" : GlobalManager.DAMAGE_TYPES.RAW
}

func reset_manager() -> void:
	stats = {
		"hp" : 100,
		"attack" : 10,
		"defense" : 5,
	}
