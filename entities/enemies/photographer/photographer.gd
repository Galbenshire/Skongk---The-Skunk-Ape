extends "res://entities/enemies/enemy.gd"

onready var FlashHitbox : CollisionPolygon2D = $Sprite/FlashHitbox/Collision

func _can_attack() -> bool:
	if _current_state != States.IDLE:
		return false
	return _attacking_allowed and TargetingSystem.get_target_facing_direction() != EnemySprite.scale.x

func _set_flash_hitbox_disabled(disabled : bool) -> void:
	FlashHitbox.set_deferred("disabled", disabled)

func _on_FlashHitbox_body_entered(body : PhysicsBody2D) -> void:
	if TargetingSystem.get_target_facing_direction() != EnemySprite.scale.x:
		body.stun()
