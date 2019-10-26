extends Resource
class_name ScoreData
"""
This resource will hold an int value, expected to be a score.
This resource will be used to allow many things to give points to the player
without having to get a reference to them.

This is known as a 'Scriptable Object' and is usually better than a Singleton
"""

signal score_changed()

export (int) var score : int = 0 setget set_score

func set_score(value : int) -> void:
	score = value
	emit_signal("score_changed")