extends Node2D
class_name Chest


@onready var animator: AnimationPlayer = $AnimationPlayer

@onready var open: bool = false

@onready var random_value

#@onready var battle_scene : PackedScene = preload("res://scenes/battle_scene.tscn")

func interact() -> bool:
	if !open:
		open = true
		print("El cofre se ha abierto.")
		var reward: String = _calculate_reward()
		match reward:
			"gold":
				animator.play("open")
				var gold_reward = random_value * GlobalManager.mimic_lvl
				print("Has ganado oro: " + str(gold_reward))
				GlobalManager.current_gold += gold_reward
				GlobalManager.total_gold += gold_reward
				GlobalManager.good_chests += 1
				GlobalManager.mimic_chain = 0
			"stat":
				var random_key = PlayerStatsManager.stats.keys().pick_random()
				var stat_reward = ceil((random_value / 10) * (1 + (GlobalManager.mimic_lvl * 0.1)) + (2 * GlobalManager.mimic_chain))
				PlayerStatsManager.stats[random_key] += stat_reward
				print(PlayerStatsManager.stats)
				GlobalManager.good_chests += 1
				GlobalManager.mimic_chain = 0
				animator.play("open")
			"mimic":
				GlobalManager.mimic_chain += 1
				print("Oh no, un mímico!")
				GlobalManager.show_mimic()
				animator.play("mimic")
				var win = await GlobalManager.combat()
				#await GlobalManager.combat_finished
				if !win:
					print("Has perdido")
				else:
					print("Has ganado")
					GlobalManager.hide_mimic()
					animator.play("open")
				GlobalManager.mimic_lvl += 1
	GlobalManager.update_ui()
	return true

func _calculate_reward() -> String:
	var total_weight = 100
	random_value = randi() % total_weight
	#random_value = 99 # LINEA DE HARDCODEO
	var current_weight = 0
	var reward_chances: Dictionary = GlobalManager.get_reward_chances()
	for weight in reward_chances.values():
		current_weight += weight
		if random_value < current_weight:
			return reward_chances.find_key(weight)
	return "ERROR"
