extends CanvasItem

@export var tween_to := 240
@export var speed_sec := 0.8
@export_group("Actions")
@export var action_after_sec := 0.0
@export var fade_on_end := false
@export var change_scene: String
@export var skip_suspended_profile_save: bool = true
@export var save_to_profile_as_current_world: bool = false
@export var circle_transition_center_on_player: bool = false

func activate() -> void:
	var tw = create_tween()
	tw.tween_property(self, "position:y", tween_to, speed_sec).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	
	if !action_after_sec: return
	
	if fade_on_end:
		tw.tween_interval(action_after_sec)
		tw.tween_property(self, "modulate:a", 0.0, 2.0)
	if change_scene:
		await get_tree().create_timer(action_after_sec, false).timeout
		trigger_transition()


func trigger_transition() -> void:
	var _crossfade: bool = SettingsManager.get_tweak("replace_circle_transitions_with_fades", false)
	Data.values.checkpoint = -1
	Data.values.checked_cps = []
	Data.values.onetime_blocks = true
	var goto_scene: String = Scenes.get_scene_path(change_scene)
	if save_to_profile_as_current_world:
		ProfileManager.current_profile.data.current_world = goto_scene
		ProfileManager.save_current_profile()
	else:
		Data.values.skip_progress_continue = skip_suspended_profile_save
	
	if Data.values.get("map_force_selected_marker"):
		Data.values.map_force_go_next = true
	
	if _crossfade:
		TransitionManager.accept_transition(
			load("res://engine/components/transitions/crossfade_transition/crossfade_transition.tscn")
				.instantiate()
				.with_scene(goto_scene)
		)
		return
	
	TransitionManager.accept_transition(
		load("res://engine/components/transitions/circle_transition/circle_transition.tscn")
			.instantiate()
			.with_speeds(0.04, -0.1)
			.with_pause()
			.on_player_after_middle(circle_transition_center_on_player)
	)
	
	await TransitionManager.transition_middle
	Scenes.goto_scene(goto_scene)
		

func warp_split() -> void:
	if Thunder.autosplitter.can_split_on("world_warps"):
		Thunder.autosplitter.split("World Warp (Project)")
