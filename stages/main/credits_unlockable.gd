extends StaticBody2D

@export var callback_only: bool = false

func _ready() -> void:
	hide()
	CustomGlobals.load_unlockables_status()
	if !callback_only && check_game_clear_state():
		show()
		reset_physics_interpolation()
		return
	
	process_mode = Node.PROCESS_MODE_DISABLED


func check_game_clear_state() -> bool:
	for key in ProfileManager.profiles:
		if key == "debug": continue
		var chosen_profile = ProfileManager.profiles[key]
		if chosen_profile.has_completed_world("10"): return true
	
	return SecretsManager.has_secret("main clear") or CustomGlobals.unlock_fancy_credits or ProfileManager.current_profile.has_completed_world("10")


func activate() -> void:
	show()
	reset_physics_interpolation()
	process_mode = Node.PROCESS_MODE_INHERIT
