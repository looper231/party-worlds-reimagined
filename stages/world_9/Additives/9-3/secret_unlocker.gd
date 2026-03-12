extends "res://addons/secrets_manager/secret_unlocker.gd"

func _ready() -> void:
	if CustomGlobals.check_for_hatate_boss():
		progress_by_id = "hatate"
	else:
		progress_by_id = "aya"
	super()
