extends ColorRect

const PLAYER_SCORE_DATA : ScoreData = preload("res://scriptable_objects/PlayerScore.tres")
const HIGHSCORE_DATA_PATH := "user://HighScore.tres"

onready var Awakeness : Control = $Awakeness
onready var Power : Control = $Power
onready var PlayerScore : Label = $PlayerScore
onready var HighScore : Label = $HighScore

var _highscore_data : ScoreData

func _ready() -> void:
	PLAYER_SCORE_DATA.connect("score_changed", self, "update_score")
	
	load_highscore()

func update_awakeness(new_value : int) -> void:
	Awakeness.current_value = Awakeness.max_value - new_value

func update_power(new_value : int) -> void:
	Power.current_value = new_value

func update_score() -> void:
	PlayerScore.text = "%06d" % PLAYER_SCORE_DATA.score
	
	if PLAYER_SCORE_DATA.score > _highscore_data.score:
		_highscore_data.score = PLAYER_SCORE_DATA.score
		update_highscore()

func update_highscore() -> void:
	HighScore.text = "%06d" % _highscore_data.score

func load_highscore() -> void:
	if ResourceLoader.exists(HIGHSCORE_DATA_PATH):
		_highscore_data = load(HIGHSCORE_DATA_PATH)
	else:
		_highscore_data = ScoreData.new()
		_highscore_data.score = 4000
		ResourceSaver.save(HIGHSCORE_DATA_PATH, _highscore_data)
	update_highscore()

func save_highscore() -> void:
	ResourceSaver.save(HIGHSCORE_DATA_PATH, _highscore_data)