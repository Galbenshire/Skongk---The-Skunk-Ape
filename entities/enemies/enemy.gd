extends KinematicBody2D
"""
This represents a character trying to get the Skunk Ape.
This is a base class; it is expected to use scenes that inherit this,
as opposed to using this scene itself.

Enemies will try to move to a location relative to Skongk,
updating this location every interval.
Every now and again, they will perfrom an attack.
"""

enum States {SPAWN_INTRO, GO_TO_TARGET, IDLE, ATTACK, KNOCKBACK}

const SCORE_VALUE := 100

onready var EnemySprite : Sprite = $Sprite
onready var AnimPlayer : AnimationPlayer = $AnimationPlayer

export (float) var move_speed : float = 60.0

export (Vector2) var base_target_offset : Vector2
export (Vector2) var offset_variance : Vector2
export (bool) var face_target : bool = true
export (int, 1, 16) var target_update_cap : int = 8

var _skongk_ref : KinematicBody2D = null
var _current_state : int = States.SPAWN_INTRO
var _velocity : Vector2
var _target : Vector2
var _target_offset : Vector2
var _target_updates : int = 0

func _ready() -> void:
	_get_reference_to_skongk()
	_update_target_offset()
	_update_target()
	_enter_state(_current_state)

func _draw() -> void:
	draw_circle(to_local(_target), 5, Color.blueviolet)

func _process(delta):
	update()

func _physics_process(delta : float) -> void:
	match _current_state:
		States.IDLE:
			EnemySprite.scale.x = _get_direction_towards_skongk()
			
			if position.distance_to(_target) > 32.0:
				_change_state(States.GO_TO_TARGET)
		
		States.GO_TO_TARGET:
			EnemySprite.scale.x = _get_direction_towards_skongk()
			
			if position.distance_to(_target) < 5.0:
				_change_state(States.IDLE)
			else:
				var target_angle = Vector2.RIGHT.rotated(get_angle_to(_target))
				_velocity = target_angle * move_speed
				move_and_slide(_velocity)

func _get_reference_to_skongk() -> void:
	var skongk_group = get_tree().get_nodes_in_group("skongk")
	if !skongk_group.empty():
		_skongk_ref = skongk_group[0] #This should be fine. There can only ever be one 'skongk'.

func _get_direction_towards_skongk() -> int:
	if !_skongk_ref:
		return int(EnemySprite.scale.x)
		
	var distance_difference = int(sign(_skongk_ref.position.x - position.x))
	return distance_difference if distance_difference != 0 else int(EnemySprite.scale.x)

func _update_target() -> void:
	_target = position if !_skongk_ref else _skongk_ref.position
	var offset_direction = 1 if !face_target else _skongk_ref.get_facing_direction()
	_target += _target_offset * offset_direction

func _update_target_offset() -> void:
	_target_offset = base_target_offset
	_target_offset.x += rand_range(-offset_variance.x, offset_variance.x)
	_target_offset.y += rand_range(-offset_variance.y, offset_variance.y)

func _change_state(new_state : int) -> void:
	_exit_state(_current_state)
	_current_state = new_state
	_enter_state(_current_state)

func _enter_state(state : int) -> void:
	match state:
		States.SPAWN_INTRO:
			var direction = _get_direction_towards_skongk()
			$IntroTween.interpolate_property(self, "position:x", position.x, position.x + 40 * direction,
					1.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			$IntroTween.start()
			EnemySprite.scale.x = direction
		
		States.ATTACK:
			$TargetUpdater.stop()
			$AnimationPlayer.play("attack")
			print(name, ": Should attack")

func _exit_state(state : int) -> void:
	match state:
		States.SPAWN_INTRO, States.ATTACK:
			$TargetUpdater.start()
			$AttackTimer.start()

func _on_IntroTween_tween_all_completed() -> void:
	_change_state(States.GO_TO_TARGET)

func _on_TargetUpdater_timeout() -> void:
	_update_target()
	if _target_updates >= target_update_cap:
		_update_target_offset()
		_target_updates = 0
	else:
		_target_updates += 1

func _on_AttackTimer_timeout() -> void:
	_change_state(States.ATTACK)

func _on_AnimationPlayer_animation_finished(anim_name : String):
	_change_state(States.GO_TO_TARGET)
