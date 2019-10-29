extends Node

onready var Skongk : KinematicBody2D = $Playfield/Entities/Skongk
onready var Spawner : Position2D = $Playfield/EnemySpawner
onready var HUD : ColorRect = $GUI/HUD

func _ready() -> void:
	randomize()
	
	var player_score = preload("res://scriptable_objects/PlayerScore.tres")
	player_score.score = 0
	
	Spawner.spawning = true

func _on_Skongk_awakeness_changed(awakeness : int) -> void:
	HUD.update_awakeness(awakeness)

func _on_Skongk_power_changed(power : int) -> void:
	HUD.update_power(power)
