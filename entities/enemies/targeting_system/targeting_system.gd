extends Node2D
"""
A component for the Enemy scene that handles getting the position of Skongk.

Offloading this from the Enemy scene itself allows it to just focus on its states.
It just has to get the target position.
"""

export (float) var x_offset : float
export (Vector2) var offset_variance : Vector2 setget set_offset_variance
export (int, "Don't Face", "Face", "Face Backwards") var face_target : int = 1

var _target : Node2D
var _current_offset_variance : Vector2

func _ready() -> void:
	_initialize()
	_on_VarianceUpdater_timeout()

func set_offset_variance(value : Vector2) -> void:
	offset_variance = value
	_on_VarianceUpdater_timeout()

func get_target_position() -> Vector2:
	if !_target:
		return Vector2.ZERO
	
	return _target.global_position + _get_offset_direction() + _current_offset_variance

func get_distance_to_target() -> float:
	return global_position.distance_to(get_target_position())

func get_target_facing_direction() -> int:
	return _target.get_facing_direction()

func get_direction_to_target() -> int:
	return 1 if global_position.direction_to(get_target_position()).x > 0.0 else -1

func _initialize() -> void:
	var skongk_group = get_tree().get_nodes_in_group("skongk")
	if !skongk_group.empty():
		_target = skongk_group[0] #This should be fine. There can only ever be one 'skongk'.

func _get_offset_direction() -> Vector2:
	var calculated_offset = Vector2(x_offset, 0)
	
	match face_target:
		1: #"Face"
			calculated_offset.x *= get_target_facing_direction()
		2: #"Face Backwards"
			calculated_offset.x *= -get_target_facing_direction()
	
	return calculated_offset

func _on_VarianceUpdater_timeout():
	_current_offset_variance.x = rand_range(-offset_variance.x, offset_variance.x)
	_current_offset_variance.y = rand_range(-offset_variance.y, offset_variance.y)
