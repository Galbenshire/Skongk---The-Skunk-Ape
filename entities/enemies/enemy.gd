extends KinematicBody2D
"""
This represents a character trying to encounter the Skunk Ape.
Their behaviour might vary, but generally they'll try to move to a location around Skongk,
attempting an attack every interval.
"""

enum States {GO_TO_TARGET, IDLE, ATTACK}

export (float) var move_speed : float = 60.0
export (Vector2) var base_target_offset : Vector2
export (Vector2) var offset_variance : Vector2
export (bool) var face_target : bool = true

var current_state : int = States.GO_TO_TARGET

var _skongk_ref : KinematicBody2D
var _target : Vector2
var _target_offset : Vector2
var _target_updates : int = 0

func _ready() -> void:
	_get_skongk_reference()
	if !_skongk_ref:
		_target = position
		$TargetUpdater.stop()
	else:
		_update_target_offset()
	$AttackTimer.start()

func _draw() -> void:
	draw_circle(to_local(_target), 5, Color.yellow)

func _process(delta: float) -> void:
	update()

func _physics_process(delta : float) -> void:
	match current_state:
		States.GO_TO_TARGET:
			if position.distance_to(_target) < 5.0:
				current_state = States.IDLE
			else:
				var target_angle = Vector2.RIGHT.rotated(get_angle_to(_target))
				move_and_slide(target_angle * move_speed)
		
		States.IDLE:
			if position.distance_to(_target) > 32.0:
				current_state = States.GO_TO_TARGET

func _update_target() -> void:
	var new_offset = _target_offset
	if face_target:
		new_offset.x *= _skongk_ref.current_direction
	
	_target = _skongk_ref.position + new_offset

func _update_target_offset() -> void:
	_target_offset = base_target_offset
	_target_offset.x += rand_range(-offset_variance.x, offset_variance.x)
	_target_offset.y += rand_range(-offset_variance.y, offset_variance.y)

func _get_skongk_reference() -> void:
	var skongk_group = get_tree().get_nodes_in_group("skongk")
	if !skongk_group.empty():
		_skongk_ref = skongk_group[0]

func _on_TargetUpdater_timeout():
	_update_target()
	if _target_updates >= 4:
		_update_target_offset()
		_target_updates = 0
	else:
		_target_updates += 1

func _on_AttackTimer_timeout():
	current_state = States.ATTACK
	$TargetUpdater.stop()
	$AnimationPlayer.play("attack")
	print("Enemy is attacking")

func _on_AnimationPlayer_animation_finished(anim_name : String) -> void:
	if anim_name == "attack":
		current_state = States.IDLE
		$TargetUpdater.start()
		$AttackTimer.start()
