extends KinematicBody2D

export (float) var move_speed : float = 60.0

var _skongk_ref : KinematicBody2D
var _target : Vector2
var target_angle

func _ready() -> void:
	var skongk_group = get_tree().get_nodes_in_group("skongk")
	if !skongk_group.empty():
		_skongk_ref = skongk_group[0]

func _physics_process(delta : float) -> void:
	_target = _skongk_ref.position
	_target.x -= 64
	
	target_angle = Vector2.RIGHT.rotated(get_angle_to(_target))
	move_and_slide(target_angle * move_speed)