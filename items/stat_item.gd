extends Node2D

@onready var price_label:Label = $PriceLabel

@export var price: int
@export var stat: String
@export var reward: int
@export var mult: float

@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D

func _ready():
	price_label.text = str(price)

func interact() -> bool:
	if GlobalManager.current_gold >= price:
		audio_player.play()
		GlobalManager.current_gold -= price
		price *= mult
		price_label.text = str(price)
		reward += (GlobalManager.mimic_lvl * GlobalManager.mimic_chain)
		PlayerStatsManager.stats[stat] += reward
		GlobalManager.update_ui()
	return true
