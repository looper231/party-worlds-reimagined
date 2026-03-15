extends "res://addons/secrets_manager/secret_unlocker.gd"

func _end_world_functions() -> void:
	if Thunder.autosplitter.can_split_on("world_complete"):
		Thunder.autosplitter.split("Last World Completed")
	if !ProfileManager.current_profile.has_completed_world("10"):
		ProfileManager.current_profile.complete_world("10")
		ProfileManager.current_profile.data.star_world = true
		ProfileManager.save_current_profile()
