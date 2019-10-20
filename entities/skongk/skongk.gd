extends KinematicBody2D
"""
The Skunk Ape. This is who the player controls.

Skongk can do the following:
	- Move in 8 directions
	- Pull a punch. Can't move while this occurs.
	- Attack like a skunk.
"""

onready var SkongkSprite : Sprite = $Sprite
onready var Punch : Area2D = $Punch

export (float) var move_speed : float = 100.0
export (float, 1.0, 5.0) var run_multiplier : float = 1.0

var input_direction : Vector2
var current_direction : int = 1
var is_running : bool = false

func _unhandled_input(event : InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		$AnimationPlayer.play("punch")

func _physics_process(delta : float) -> void:
	is_running = Input.is_action_pressed("ui_select")
	
	input_direction = Vector2.ZERO
	input_direction.x = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	if !is_running:
		input_direction.y = int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))
	input_direction = input_direction.normalized()
	
	if input_direction.x and sign(input_direction.x) != current_direction:
		# 'flip_h' is not used here because it doesn't flip around the offset
		SkongkSprite.scale.x = sign(input_direction.x)
		current_direction = sign(input_direction.x)
	
	var final_move_speed = move_speed * (run_multiplier if is_running else 1.0)
	move_and_slide(input_direction * final_move_speed)

func set_control_state(controllable : bool) -> void:
	set_physics_process(controllable)
	set_process_unhandled_input(controllable)

func start_punch() -> void:
	Punch.get_node("Collision").set_deferred("disabled", false)
	Punch.position.x = abs(Punch.position.x) * current_direction
	print("Punch Started")

func end_punch() -> void:
	Punch.get_node("Collision").set_deferred("disabled", true)
	print("Punch Ended")

