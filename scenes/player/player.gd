extends CharacterBody2D

enum STATES{
	IDLE,
	MOVING,
	INTERACTING,
	DEAD
}

@onready var current_state: STATES = STATES.IDLE

@onready var ray_cast: RayCast2D = $RayCast
@onready var label: Label = $Label
@onready var interactive_area: Area2D = $InteractiveArea

@onready var input_vector: Vector2 = Vector2.ZERO

var interactive_item
var moving = false

func _ready() -> void:
	position = position.snapped(Vector2.ONE * GlobalManager.tile_size)
	position += Vector2.ONE * GlobalManager.tile_size / 2

func _process(delta: float) -> void:
	match current_state:
		STATES.IDLE:
			moving = true
			idle()
		STATES.MOVING:
			moving = false
			move()
		STATES.INTERACTING:
			moving = false
			interact()
		STATES.DEAD:
			pass

func move() -> void:
	position += input_vector * GlobalManager.tile_size
	input_vector = Vector2.ZERO
	_change_state(STATES.IDLE)

func idle() -> void:
	if moving:
		if input_vector == Vector2.ZERO:
			if Input.is_action_just_pressed("move_up"):
				if await _update_raycast(Vector2.UP):
					input_vector.y = -1
			elif Input.is_action_just_pressed("move_down"):
				if await _update_raycast(Vector2.DOWN):
					input_vector.y = 1
			elif Input.is_action_just_pressed("move_left"):
				if await _update_raycast(Vector2.LEFT):
					input_vector.x = -1
			elif Input.is_action_just_pressed("move_right"):
				if await _update_raycast(Vector2.RIGHT):
					input_vector.x = 1
			elif Input.is_action_just_pressed("interact"):
				if interactive_item:
					_change_state(STATES.INTERACTING)
		else:
			_change_state(STATES.MOVING)

func _update_raycast(dir: Vector2) -> bool:
	var result: bool = false
	ray_cast.target_position = dir * 16
	interactive_area.position = dir * 16
	await get_tree().create_timer(0.1).timeout
	if !ray_cast.is_colliding():
		result = true
	return result

func _change_state(new_state):
	current_state = new_state


func _on_interactive_area_body_entered(body: Node2D) -> void:
		label.show()
		interactive_item = body


func _on_interactive_area_body_exited(body: Node2D) -> void:
		label.hide()
		interactive_item = null

func interact() -> void:
	if await interactive_item.interact():
		if !GlobalManager.fighting:
			if PlayerStatsManager.stats["hp"] <= 0:
				_change_state(STATES.DEAD)
			else:
				_change_state(STATES.IDLE)
