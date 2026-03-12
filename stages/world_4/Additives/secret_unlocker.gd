extends Node

var no_lui_finish: bool = true
var player_suit_lui: PlayerSuit = CharacterManager.get_suit("green_lui")

func _invalidate_lui_finish() -> void:
	no_lui_finish = false

func _level_complete_lui_check() -> void:
	if player_suit_lui == Thunder._current_player_state:
		no_lui_finish = false
	if no_lui_finish:
		SecretsManager.set_secret("4-1 no lui", true, true, true, "world 4-1 completed without green lui")
