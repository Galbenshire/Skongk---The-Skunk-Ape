extends Node

onready var Skongk : KinematicBody2D = $Playfield/Entities/Skongk
onready var Spawner : Position2D = $Playfield/EnemySpawner
onready var HUD : ColorRect = $GUI/HUD

func _ready() -> void:
	randomize()
	
	var player_score = preload("res://scriptable_objects/PlayerScore.tres")
	player_score.score = 0
	
	Skongk.set_control_state(false)
	_set_up_ready_tween()

func _start_game() -> void:
	Spawner.spawning = true

func _set_up_ready_tween() -> void:
	var gui_tween = $GUI/GUITween
	var ready_label = $GUI/Ready
	
	ready_label.rect_position.x -= 184
	gui_tween.interpolate_property(ready_label, "rect_position:x", ready_label.rect_position.x,
			ready_label.rect_position.x + 184, 1.0, Tween.TRANS_QUAD, Tween.EASE_OUT, 0.25)
	gui_tween.interpolate_property(ready_label, "rect_position:x", ready_label.rect_position.x + 184,
			ready_label.rect_position.x + 368, 1.0, Tween.TRANS_QUAD, Tween.EASE_IN, 3.25)
	gui_tween.interpolate_callback(self, 4.25, "_start_game")
	gui_tween.interpolate_callback(Skongk, 4.25, "set_control_state", true)
	gui_tween.start()

func _end_game() -> void:
	HUD.save_highscore()
	get_tree().change_scene("res://menu/MainMenu.tscn")

func _on_Skongk_awakeness_changed(awakeness : int) -> void:
	HUD.update_awakeness(awakeness)

func _on_Skongk_power_changed(power : int) -> void:
	HUD.update_power(power)

func _on_Skongk_asleep():
	var gui_tween = $GUI/GUITween
	var game_over_label = $GUI/GameOver
	var music = $Music
	
	gui_tween.interpolate_property(game_over_label, "rect_position:x", game_over_label.rect_position.x,
			game_over_label.rect_position.x - 180, 1.0, Tween.TRANS_QUAD, Tween.EASE_OUT)
	gui_tween.interpolate_property(music, "volume_db", -8.0, -50.0, 2.0, Tween.TRANS_SINE, Tween.EASE_IN)
	gui_tween.interpolate_callback(music, 2.05, "stop")
	gui_tween.interpolate_callback(self, 4.0, "_end_game")
	gui_tween.start()
