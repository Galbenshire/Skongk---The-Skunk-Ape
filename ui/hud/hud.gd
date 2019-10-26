extends ColorRect

var _highscore_ref : int = 1000

func _ready() -> void:
	update_highscore(200)

func update_score(score : int) -> void:
	$PlayerScore.text = "%06d" % score
	
	if score > _highscore_ref:
		update_highscore(score)

func update_highscore(score : int) -> void:
	$HighScore.text = "%06d" % score
	_highscore_ref = score