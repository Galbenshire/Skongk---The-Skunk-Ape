extends Node

onready var Duration : Timer = $Duration
onready var Screen : Sprite = $Screen

func flash() -> void:
	Screen.show()
	Duration.start()

func stop_flash() -> void:
	Screen.hide()
	Duration.stop()

func _on_Duration_timeout() -> void:
	stop_flash()
