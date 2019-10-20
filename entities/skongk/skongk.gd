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

func _unhandled_input(event : InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		$AnimationPlayer.play("punch")

func _physics_process(delta : float) -> void:
	var input_direction := Vector2()
	input_direction.x = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	input_direction.y = int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))
	input_direction = input_direction.normalized()
	
	if input_direction.x:
		# 'flip_h' is not used here because it doesn't flip around the offset
		SkongkSprite.scale.x = sign(input_direction.x)
		Punch.position.x = abs(Punch.position.x) * sign(input_direction.x)
	
	move_and_slide(input_direction * move_speed)

func set_control_state(controllable : bool) -> void:
	set_physics_process(controllable)
	set_process_unhandled_input(controllable)

func start_punch() -> void:
	print("Punch Started")

func end_punch() -> void:
	set_control_state(true)
	print("Punch Ended")

