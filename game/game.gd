extends Node

func _ready():
	randomize()
	
	var player_score = preload("res://scriptable_objects/PlayerScore.tres")
	player_score.score = 0

func _on_Skongk_power_changed(power : int) -> void:
	$GUI/HUD.update_power(power)

func _on_Skongk_score_changed(score : int) -> void:
	$GUI/HUD.update_score(score)
