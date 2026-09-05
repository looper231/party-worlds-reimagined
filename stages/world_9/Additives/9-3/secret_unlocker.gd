extends "res://addons/secrets_manager/secret_unlocker.gd"

func _ready() -> void:
	if CustomGlobals.check_for_hatate_boss():
		progress_by_id = "hatate"
	else:
		progress_by_id = "aya"
	super()

func enable_easy_mode() -> void:
	add_shit_to_profile("game_journalist", true)
	print("[Secrets] Easy Mode enabled.")
