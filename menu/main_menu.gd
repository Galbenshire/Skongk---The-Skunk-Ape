extends Control

func _input(event : InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		var anim_player = $AnimationPlayer
		anim_player.playback_speed = 5.0
		yield(get_tree().create_timer(3.0), "timeout")
		get_tree().change_scene("res://game/Game.tscn")