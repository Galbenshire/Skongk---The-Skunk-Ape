extends KinematicBody2D
"""
The Skunk Ape. This is who the player controls.

Skongk can do the following:
	- Move in 8 directions
	- Pull a punch. Can't move while this occurs.
	- Attack like a skunk. Also can't move during this.
"""

signal score_changed(score)
signal power_changed(power)
signal awakeness_changed(awakeness)

enum States {IDLE, MOVE, ATTACK, ASLEEP}
enum Attacks {PUNCH, BACK_BLAST}

onready var SkongkSprite : Sprite = $Sprite
onready var PunchHitbox = $Sprite/PunchHitbox/Collision
onready var BackBlastHitbox = $Sprite/BackBlastHitbox/Collision
onready var MoveAnimations = $MoveAnimations

export (float) var move_speed : float = 90.0
export (float, 1.0, 5.0) var run_multiplier : float = 2.5

var score : int = 0 setget set_score
var awakeness : int = 6 setget set_awakeness
var skunk_power : int = 16

var _current_state : int = States.IDLE
var _last_attack_used : int = Attacks.PUNCH
var _input_direction : Vector2
var _combo_hits : int = 0

func _unhandled_input(event : InputEvent) -> void:
	if event.is_action_pressed("skongk_punch"):
		_last_attack_used = Attacks.PUNCH
		_change_state(States.ATTACK)
	elif event.is_action_pressed("skongk_skunk_move"):
		if skunk_power >= 4:
			skunk_power -= 4
			_last_attack_used = Attacks.BACK_BLAST
			_change_state(States.ATTACK)

func _physics_process(delta : float) -> void:
	_get_input_direction()
	
	match _current_state:
		States.IDLE:
			if _input_direction:
				_change_state(States.MOVE)
		
		States.MOVE:
			if !_input_direction:
				_change_state(States.IDLE)
			else:
				var is_running := Input.is_action_pressed("skongk_run")
				var move_direction := _input_direction
				move_direction.y = 0.0 if is_running else move_direction.y
				move_direction = move_direction.normalized()
				var multiplier = run_multiplier if is_running else 1.0
				
				if _input_direction.x:
					SkongkSprite.scale.x = _input_direction.x
				
				move_and_slide(move_direction * move_speed * multiplier)

func set_score(value : int) -> void:
	score = value
	emit_signal("score_changed", score)

func set_awakeness(value : int) -> void:
	awakeness = value
	emit_signal("awakeness_changed", awakeness)

func set_skunk_power(value : int) -> void:
	skunk_power = value
	emit_signal("power_changed", skunk_power)

func get_facing_direction() -> int:
	return int(SkongkSprite.scale.x)

func _get_input_direction() -> void:
	_input_direction = Vector2.ZERO
	_input_direction.x = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	_input_direction.y = int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))

func _do_attack() -> void:
	var attack_animation = "attack_"
	attack_animation += "punch" if _last_attack_used == Attacks.PUNCH else "back_blast"
	
	MoveAnimations.play(attack_animation)

func _set_punch_hitbox_disabled(disabled : bool) -> void:
	PunchHitbox.set_deferred("disabled", disabled)

func _set_back_blast_hitbox_disabled(disabled : bool) -> void:
	BackBlastHitbox.set_deferred("disabled", disabled)

func _change_state(new_state : int) -> void:
	_exit_state(_current_state)
	_current_state = new_state
	_enter_state(_current_state)

func _enter_state(state : int) -> void:
	match state:
		States.IDLE:
			print(name, ": Should play idle animation")
		
		States.MOVE:
			print(name, ": Should play move animation")
		
		States.ATTACK:
			set_physics_process(false)
			set_process_unhandled_input(false)
			_do_attack()

func _exit_state(state : int) -> void:
	match state:
		States.ATTACK:
			set_physics_process(true)
			set_process_unhandled_input(true)
			_combo_hits = 0

func _on_AttackHitbox_body_entered(body : PhysicsBody2D) -> void:
	_combo_hits += 1
	set_score(score + body.SCORE_VALUE * _combo_hits)
	print("Combo: ", _combo_hits, " | Score Gained: ", body.SCORE_VALUE * _combo_hits)
	body.knockout()

func _on_MoveAnimations_animation_finished(anim_name : String) -> void:
	if anim_name.begins_with("attack"):
		_change_state(States.IDLE)
