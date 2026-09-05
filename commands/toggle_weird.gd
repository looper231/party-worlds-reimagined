extends Command

const OMINOUS_SFX = preload("res://stages/world_9/music/weird_ominous.wav")

# Only usable when W9 Boss exists
static func register() -> Command:
	return new().set_name("toggle_weird").set_description("[???] The forbidden path began with countless deaths.")

func execute(args:Array) -> Command.ExecuteResult:
	var old_value = ProfileManager.current_profile.data.get("game_journalist", false)
	ProfileManager.current_profile.data["game_journalist"] = !old_value
	
	if !old_value:
		Audio.play_sound(OMINOUS_SFX, Thunder._current_player)
		return Command.ExecuteResult.new("Weird Route enabled.")
	else:
		return Command.ExecuteResult.new("Weird Route disabled.")
