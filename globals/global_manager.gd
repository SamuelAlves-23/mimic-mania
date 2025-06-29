extends Node

signal combat_finished

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

@onready var hp_label: Label = $CanvasLayer/VBoxContainer/HPLabel
@onready var attack_label: Label = $CanvasLayer/VBoxContainer/AttackLabel
@onready var defense_label: Label = $CanvasLayer/VBoxContainer/DefenseLAbel
@onready var mimic_chance_label: Label = $CanvasLayer/VBoxContainer/MimicChanceLabel
@onready var gold_label: Label = $CanvasLayer/VBoxContainer/GoldLabel

@onready var mimic_stats_container: VBoxContainer = $CanvasLayer/MimicStatsContainer
@onready var mimic_hp_label: Label = $CanvasLayer/MimicStatsContainer/MimicHPLabel
@onready var mimic_attack_label: Label = $CanvasLayer/MimicStatsContainer/MimicAttackLabel
@onready var mimic_defense_label: Label = $CanvasLayer/MimicStatsContainer/MimiCDefenseLAbel

@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var end_container: VBoxContainer = $CanvasLayer/EndContainer
@onready var chests_label: Label = $CanvasLayer/ChestsLabel

var current_mimic
var fighting = false

func _ready() -> void:
	update_ui()


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

func get_mimic_stats() -> Dictionary:
	return{
		#"hp" : 100 * (1+ (mimic_lvl /5)),
		#"current_hp" : 100 * (1+ (mimic_lvl / 5)),
		#"attack" :  10 * (1+ (mimic_lvl / 5)),
		#"defense" : 10 * (1+ (mimic_lvl / 5)),
		"hp" : 100 * (mimic_lvl * 0.3),
		"attack" :  10 * (mimic_lvl * 0.5),
		"defense" : 10 * (mimic_lvl * 0.3),
		#"damage_type" : DAMAGE_TYPES.RAW
	}

func combat() -> bool:
	var win = false
	current_mimic = get_mimic_stats()
	fighting = true
	audio_player.play()
	while fighting:
		## TURNO DEL JUGADOR
		var total_damage = PlayerStatsManager.stats["attack"] - (current_mimic ["defense"] / 2)
		current_mimic["hp"] -= total_damage
		print("Has hecho daño: " + str(total_damage))
		update_ui()
		if current_mimic ["hp"] <= 0:
			fighting = false
			win = true
		await get_tree().create_timer(0.5).timeout
		
		## TURNO DEL MÍMICO
		if current_mimic["hp"] >0:
			total_damage = current_mimic ["attack"] - (PlayerStatsManager.stats["defense"] / 2)
			PlayerStatsManager.stats["hp"] -= total_damage
			print("Has recibido daño: " + str(total_damage))
			update_ui()
			if PlayerStatsManager.stats["hp"] <= 0:
				end_container.show()
				fighting = false
	audio_player.stop()
	combat_finished.emit()
	return win

func update_ui() -> void:
	## ESTADÍSTICAS DEL JUGADOR
	var player_data = PlayerStatsManager.stats
	hp_label.text = "HP: " + str(player_data["hp"])
	attack_label.text = "Attack: " + str(player_data["attack"])
	defense_label.text = "Defense: " + str(player_data["defense"])
	
	# ESTADÍSTICAS DE MÍMICO
	if current_mimic:
		mimic_hp_label.text = "HP: " + str(current_mimic ["hp"])
		mimic_attack_label.text = "Attack: " + str(current_mimic ["attack"])
		mimic_defense_label.text = "Defense: " + str(current_mimic ["defense"])
	
	# OTRAS ESTADÍSTICAS
	var chances = get_reward_chances()
	chests_label.text = "Cofres abiertos: " + str(good_chests + (mimic_lvl - 1))
	gold_label.text = "Gold: " + str(current_gold)
	mimic_chance_label.text = "Mimic chance: " + str(chances["mimic"]) + "%"

func show_mimic() -> void:
	mimic_stats_container.show()
	
func hide_mimic() -> void:
	mimic_stats_container.hide()


func _on_retry_button_pressed() -> void:
	end_container.hide()
	mimic_stats_container.hide()
	reset_manager()
	PlayerStatsManager.reset_manager()
	get_tree().reload_current_scene()

func reset_manager() -> void:
	good_chests = 0
	mimic_lvl = 1
	total_gold = 0
	current_gold = 0
	mimic_chain = 0
