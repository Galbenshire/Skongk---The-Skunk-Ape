extends Node2D

export (int) var value : int

func _ready():
	$Label.text = str(value)
	$Tween.interpolate_property(self, "position:y", position.y, position.y - 32,
			1.0, Tween.TRANS_QUART, Tween.EASE_OUT)
	$Tween.interpolate_callback(self, 1.25, "queue_free")
	$Tween.start()

