extends KinematicBody2D
"""
The Skunk Ape. This is who the player controls.

Skongk can do the following:
	- Move in 8 directions
	- Pull a punch. Can't move while this occurs.
	- Attack like a skunk.
"""

enum States {IDLE, WALK, RUN, ATTACK}

onready var SkongkSprite : Sprite = $Sprite
onready var Punch : Area2D = $Sprite/PunchHitbox
onready var BackBlast : Area2D = $Sprite/BackBlastHitbox

export (float) var move_speed : float = 100.0
export (float, 1.0, 5.0) var run_multiplier : float = 1.0

var score : int = 0
var skunk_power : int = 16

var current_state : int = States.IDLE setget set_state
var current_direction : int = 1

var _input_direction : Vector2

func _unhandled_input(event : InputEvent) -> void:
	if event.is_action_pressed("skongk_punch"):
		$AnimationPlayer.play("punch")
	elif event.is_action_pressed("skongk_skunk_move"):
		if skunk_power >= 4:
			skunk_power = int(max(0, skunk_power - 4))
			$AnimationPlayer.play("back_blast")

func _physics_process(delta : float) -> void:
	match current_state:
		States.IDLE:
			if Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_right") \
					or Input.is_action_pressed("ui_down") or Input.is_action_pressed("ui_up"):
				current_state = States.WALK
		
		States.WALK, States.RUN:
			current_state = States.RUN if Input.is_action_pressed("skongk_run") else States.WALK
			
			_input_direction = Vector2.ZERO
			_input_direction.x = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
			if current_state == States.WALK:
				_input_direction.y = int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))
			_input_direction = _input_direction.normalized()
			
			if !_input_direction:
				current_state = States.IDLE
			else:
				if _input_direction.x:
					SkongkSprite.scale.x = sign(_input_direction.x)
					current_direction = int(sign(_input_direction.x))
				
				var move_multiply = run_multiplier if current_state == States.RUN else 1.0
				move_and_slide(_input_direction * move_speed * move_multiply)

func set_state(new_state: int) -> void:
	current_state = new_state
	
	var disable_controls = current_state != States.ATTACK
	set_physics_process(disable_controls)
	set_process_unhandled_input(disable_controls)

func _start_punch() -> void:
	Punch.get_node("Collision").set_deferred("disabled", false)
	print("Punch Started")

func _end_punch() -> void:
	Punch.get_node("Collision").set_deferred("disabled", true)
	print("Punch Ended")

func _start_back_blast() -> void:
	BackBlast.get_node("Collision").set_deferred("disabled", false)
	print("Back Blast Started")

func _end_back_blast() -> void:
	BackBlast.get_node("Collision").set_deferred("disabled", true)
	print("Back Blast Ended")

func _on_PunchHitbox_body_entered(body : PhysicsBody2D) -> void:
	print("Punched something")

func _on_BackBlastHitbox_body_entered(body : PhysicsBody2D) -> void:
	print("Something caught in the back blast")
