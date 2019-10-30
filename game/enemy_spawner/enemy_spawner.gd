extends Position2D
"""
This scene handles the spawning of enemies.
Just tell it which node to spawn these enemies on.
(I.E. which node will become the parent of these newly spawned enemies)

More of these variables should probably be 'export' variables,
but there is only going to be just one instance of this scene.
"""

const ENEMIES := {
	"hunter" : preload("res://entities/enemies/hunter/Hunter.tscn"),
	"photographer" : preload("res://entities/enemies/photographer/Photographer.tscn")
}

onready var SpawnRate : Timer = $SpawnRate

export (NodePath) var spawn_node_path : NodePath
export (int, 1, 10) var max_enemies_on_field : int = 2

var spawning : bool = false setget set_spawning

var _spawn_node : Node
var _x_offset : float = 160.0
var _y_range : float = 48.0

var _enemies_on_field : int = 0
var _enemies_spawned : int = 0

func _ready() -> void:
	_spawn_node = get_parent() if spawn_node_path.is_empty() else get_node(spawn_node_path)

func set_spawning(value : bool) -> void:
	spawning = value
	
	if spawning:
		SpawnRate.start()
	else:
		SpawnRate.stop()

func _spawn_enemy() -> void:
	print("Spawn an enemy at ", global_position + _calculate_spawn_location())
	
	var enemy = _determine_enemy_type()
	enemy.global_position = global_position + _calculate_spawn_location()
	_spawn_node.add_child(enemy)
	enemy.connect("tree_exiting", self, "_on_Enemy_removed")
	
	_enemies_on_field += 1
	_enemies_spawned += 1
	_handle_game_progression()

func _handle_game_progression() -> void:
	if _enemies_spawned % 10 == 0:
		max_enemies_on_field += 1
		max_enemies_on_field = int(clamp(max_enemies_on_field, 1, 10))

func _determine_enemy_type() -> Node:
	var chosen = "hunter" if randf() < 0.5 else "photographer"
	return ENEMIES[chosen].instance()

func _calculate_spawn_location() -> Vector2:
	var x_direction = 1 if randf() < 0.5 else -1
	return Vector2(_x_offset * x_direction, rand_range(-_y_range, _y_range))

func _on_SpawnRate_timeout() -> void:
	if _enemies_on_field < max_enemies_on_field:
		_spawn_enemy()

func _on_Enemy_removed() -> void:
	print("Enemy gone")
	_enemies_on_field -= 1