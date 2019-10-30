extends "res://entities/enemies/enemy.gd"
"""
Tries to take a picture of Skongk.
Stuns Skongk, unless they're looking away from the camera.
"""

const VARIANTS := [
	preload("res://entities/enemies/photographer/Photographer.png"),
	preload("res://entities/enemies/photographer/PhotographerAlt.png"),
	preload("res://entities/enemies/photographer/PhotographerAlt2.png")
]

onready var FlashHitbox : CollisionPolygon2D = $Sprite/FlashHitbox/Collision

func _ready() -> void:
	$Sprite.texture = VARIANTS[randi() % 3]

func _can_attack() -> bool:
	if _current_state != States.IDLE:
		return false
	return _attacking_allowed and TargetingSystem.get_target_facing_direction() != EnemySprite.scale.x

func _set_flash_hitbox_disabled(disabled : bool) -> void:
	FlashHitbox.set_deferred("disabled", disabled)

func _exit_state(state : int) -> void:
	match state:
		States.SPAWN_INTRO:
			TargetUpdater.start()
			$AttackTimer.start()
			if $IntroTween.is_active():
				$IntroTween.stop_all()
		
		States.ATTACK:
			_set_flash_hitbox_disabled(true)
			TargetUpdater.start()
			$AttackTimer.start()

func _on_FlashHitbox_body_entered(body : PhysicsBody2D) -> void:
	if TargetingSystem.get_target_facing_direction() != EnemySprite.scale.x:
		body.stun()
