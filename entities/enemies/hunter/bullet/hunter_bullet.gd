extends Area2D

export (Vector2) var velocity : Vector2

func _physics_process(delta : float) -> void:
	position += velocity * delta

func set_direction(direction : float) -> void:
	$Sprite.scale.x = direction

func _on_VisibilityNotifier_screen_exited() -> void:
	queue_free()

func _on_HunterBullet_body_entered(body : PhysicsBody2D) -> void:
	print("Bullet kit Skongk")
	queue_free()
