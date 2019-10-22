extends KinematicBody2D

enum States {GO_TO_TARGET, IDLE, ATTACK}

export (float) var move_speed : float = 60.0

var current_state : int = States.GO_TO_TARGET

var _skongk_ref : KinematicBody2D
var _target : Vector2
var _target_y_offset : float = 0.0
var _target_updates : int = 0

func _ready() -> void:
	_get_skongk_reference()
	if !_skongk_ref:
		_target = position
		$TargetUpdater.stop()
	
	randomize()
	_target_y_offset = rand_range(-32.0, 32)

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

func _get_skongk_reference() -> void:
	var skongk_group = get_tree().get_nodes_in_group("skongk")
	if !skongk_group.empty():
		_skongk_ref = skongk_group[0]

func _on_TargetUpdater_timeout():
	_target = _skongk_ref.position + Vector2(32 * _skongk_ref.current_direction, _target_y_offset)
	if _target_updates >= 4:
		_target_y_offset = rand_range(-32.0, 32)
		_target_updates = 0
	else:
		_target_updates += 1