extends ColorRect

func _ready() -> void:
	pass

func update_score(new_score: int) -> void:
	$Data/Score.text = "SCORE - %06d" % new_score

func update_high_score(new_score: int) -> void:
	$Data/HighScore.text = "TOP - %06d" % new_score

func update_awakeness(new_value : int) -> void:
	var new_text = "SKONGK- "
	for i in range(new_value):
		new_text += "Z"
	$Data/Awake.text = new_text

func update_power(new_value : int) -> void:
	$Data/Power/Text.text = str("POW - ", new_value)