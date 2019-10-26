extends KinematicBody2D
"""
This represents a character trying to get the Skunk Ape.
This is a base class; it is expected to use scenes that inherit this,
as opposed to using this scene itself.

Enemies will try to move to a location relative to Skongk,
updating this location every interval.
Every now and again, they will perfrom an attack.
"""

enum States {SPAWN_INTRO, RETARGET, IDLE, ATTACK, KNOCKOUT, ENEMY_REBOUND}

const PLAYER_SCORE_DATA : ScoreData = preload("res://scriptable_objects/PlayerScore.tres")
const SCORE_VALUE := 100

onready var TargetingSystem : Node2D = $TargetingSystem
onready var EnemySprite : Sprite = $Sprite
onready var AnimPlayer : AnimationPlayer = $AnimationPlayer
onready var TargetUpdater : Timer = $TargetUpdater

export (float) var move_speed : float = 60.0

var _current_state : int = States.SPAWN_INTRO
var _velocity : Vector2
var _target_position : Vector2

func _ready() -> void:
	_enter_state(_current_state)

func _physics_process(delta : float) -> void:
	_process_state(delta)

func knockout() -> void:
	_change_state(States.KNOCKOUT)

func rebound() -> void:
	_change_state(States.ENEMY_REBOUND)

func _process_state(delta : float) -> void:
	match _current_state:
		States.IDLE:
			EnemySprite.scale.x = TargetingSystem.get_direction_to_target()
			
			if TargetingSystem.get_distance_to_target() < 16.0 or TargetingSystem.get_distance_to_target() > 80.0:
				_change_state(States.RETARGET)
		
		States.RETARGET:
			EnemySprite.scale.x = TargetingSystem.get_direction_to_target()
			
			if TargetingSystem.get_distance_to_target() < 5.0:
				_change_state(States.IDLE)
			else:
				var target_angle = global_position.direction_to(TargetingSystem.get_target_position())
				_velocity = target_angle * move_speed
				move_and_slide(_velocity)
		
		States.KNOCKOUT:
			var collision = move_and_collide(_velocity * delta)
			if collision:
				_change_state(States.ENEMY_REBOUND)
				collision.collider.rebound()
				PLAYER_SCORE_DATA.score += SCORE_VALUE * 2
		
		States.ENEMY_REBOUND:
			_velocity.y += 900 * delta
			move_and_collide(_velocity * delta)

func _change_state(new_state : int) -> void:
	_exit_state(_current_state)
	_current_state = new_state
	_enter_state(_current_state)

func _enter_state(state : int) -> void:
	match state:
		States.SPAWN_INTRO:
			var direction = TargetingSystem.get_direction_to_target()
			$IntroTween.interpolate_property(self, "position:x", position.x, position.x + 40 * direction,
					1.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			$IntroTween.start()
			EnemySprite.scale.x = direction
		
		States.IDLE:
			TargetingSystem.x_offset = 0.0
			TargetingSystem.offset_variance = Vector2.ZERO
		
		States.RETARGET:
			TargetingSystem.x_offset = 32.0
			TargetingSystem.offset_variance = Vector2(8.0, 16.0)
		
		States.ATTACK:
			TargetUpdater.stop()
			$AnimationPlayer.play("attack")
			print(name, ": Should attack")
		
		States.KNOCKOUT:
			_velocity.x = 700 * -TargetingSystem.get_direction_to_target()
			_velocity.y = 0
			TargetUpdater.stop()
			$AttackTimer.stop()
			set_collision_mask_bit(0, false)
			set_collision_mask_bit(2, true)
		
		States.ENEMY_REBOUND:
			_velocity = Vector2(220 * -sign(_velocity.x), -420)
			TargetUpdater.stop()
			$AttackTimer.stop()
			$Collision.set_deferred("disabled", true)

func _exit_state(state : int) -> void:
	match state:
		States.SPAWN_INTRO, States.ATTACK:
			TargetUpdater.start()
			$AttackTimer.start()

func _on_IntroTween_tween_all_completed() -> void:
	_change_state(States.IDLE)

func _on_TargetUpdater_timeout() -> void:
	_target_position = TargetingSystem.get_target_position()

func _on_AttackTimer_timeout() -> void:
	_change_state(States.ATTACK)

func _on_AnimationPlayer_animation_finished(anim_name : String) -> void:
	_change_state(States.IDLE)

func _on_VisibilityNotifier_screen_exited() -> void:
	if _current_state == States.KNOCKOUT or _current_state == States.ENEMY_REBOUND:
		queue_free()
