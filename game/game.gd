extends Node

func _ready():
	randomize()

func _on_Skongk_power_changed(power : int) -> void:
	$GUI/HUD.update_power(power)

func _on_Skongk_score_changed(score : int) -> void:
	$GUI/HUD.update_score(score)
