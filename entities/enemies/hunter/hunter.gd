extends "res://entities/enemies/enemy.gd"

const BULLET_SCENE := preload("res://entities/enemies/hunter/bullet/HunterBullet.tscn")

onready var BulletOrigin : Position2D = $Sprite/BulletOrigin

func shoot() -> void:
	var bullet = BULLET_SCENE.instance()
	get_parent().add_child(bullet)
	bullet.global_position = BulletOrigin.global_position
	bullet.velocity = 150 * bullet.global_position.direction_to(TargetingSystem.get_target_position())
	bullet.set_direction(EnemySprite.scale.x)

func _enter_state(state : int) -> void:
	match state:
		States.SPAWN_INTRO:
			var direction = TargetingSystem.get_direction_to_target()
			var intro_tween = $IntroTween
			intro_tween.interpolate_property(self, "position:x", position.x, position.x + 40 * direction,
					1.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			intro_tween.interpolate_callback(self, 1.5, "_change_state", States.IDLE)
			intro_tween.start()
			EnemySprite.scale.x = direction
		
		States.IDLE:
			TargetUpdater.start()
			TargetingSystem.x_offset = 0.0
			TargetingSystem.offset_variance = Vector2.ZERO
		
		States.RETARGET:
			TargetUpdater.stop()
			TargetingSystem.x_offset = 128.0 * TargetingSystem.get_direction_to_target()
			TargetingSystem.offset_variance = Vector2(32.0, 32.0)
		
		States.ATTACK:
			_attacking_allowed = false
			TargetingSystem.x_offset = 0.0
			TargetingSystem.offset_variance = Vector2.ZERO
			EnemySprite.scale.x = TargetingSystem.get_direction_to_target()
			TargetUpdater.stop()
			$AnimationPlayer.play(attack_animation)
			print(name, ": Should attack")
		
		States.KNOCKOUT:
			TargetingSystem.x_offset = 0.0
			TargetingSystem.offset_variance = Vector2.ZERO
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
		States.SPAWN_INTRO:
			TargetUpdater.start()
			$AttackTimer.start()
			if $IntroTween.is_active():
				$IntroTween.stop_all()
		
		States.ATTACK:
			TargetUpdater.start()
			$AttackTimer.start()