@icon("res://engine/objects/warps/icons/pipe_save.svg")
@warning_ignore("missing_tool")
extends "res://engine/objects/warps/pipe_in.gd"

const SCORING = preload("res://engine/components/hud/sounds/scoring.wav")

@export
var profile_name: String
@export
var level_count: Dictionary = {
	1: 4,
	2: 3,
	3: 4,
	4: 5,
	5: 1,
	6: 5,
	7: 3,
	8: 3,
	9: 3,
	10: 4
}
@export
var map_scene_template: String = "res://stages/world_{0}/map_{0}.tscn"
@export
var map_scene_template_2: String = "res://stages/world_{0}/map{0}.tscn"
@export
var level_scene_template: String = "res://stages/world_{0}/level_{0}-{1}.tscn"
@export_node_path("Node2D") var reset_node_path: NodePath = ^"../CanvasLayer/Reset"
@export var force_disable_level_save: bool = false
@export var set_data_to_profile: String
@export var allow_selecting_worlds: bool = false
@export var allow_selecting_completed_levels: bool = false
@export var no_applicable_text: bool = false

var deletion_progress: float
var is_empty: bool
var _tweak: bool

var _star_world: bool
var _star_sel_world: int
var _star_sel_level: int

@onready var label: Label = $Label
@onready var reset_node: Node2D = get_node_or_null(reset_node_path)
var faster_deletion_tw: bool

signal save_deleted

func _ready() -> void:
	super()
	if Engine.is_editor_hint(): return
	player_exit.connect(func(): deletion_progress = 0)
	_tweak = SettingsManager.get_tweak("load_save_from_world_start", false)
	faster_deletion_tw = SettingsManager.get_tweak("faster_save_deletion", false)
	
	_update_save()
	
	if reset_node:
		player_enter.connect(_update_reset_labels)
	else:
		print("[SavePipe] Set up the reset node path in inspector.")


func _physics_process(delta: float) -> void:
	if player != null:
		if Input.is_action_pressed(&"a_delete"):
			var mod_delta: float = delta / 3
			if faster_deletion_tw:
				mod_delta = delta / 0.6
			deletion_progress = clampf(deletion_progress + mod_delta, 0, 1)
			if deletion_progress == 1:
				delete_save()
				deletion_progress = 0.0
		else:
			deletion_progress = clampf(deletion_progress - delta, 0, 1)
		
		if (_star_world || allow_selecting_worlds) && Input.is_action_just_pressed("a_tab"):
			var _sfx = CharacterManager.get_sound_replace(SCORING, SCORING, "menu_select_short", false)
			if player.up_down == 0 && len(level_count) > 1:
				Audio.play_1d_sound(_sfx)
				_star_sel_world = _star_sel_world + 1 if _star_sel_world < len(level_count) else level_count.keys()[0]
				_star_sel_level = mini(_star_sel_level, level_count[_star_sel_world])
				label.set_world_numbers("%d-%d" % [_star_sel_world, _star_sel_level])
			elif player.up_down < -0.5:
				Audio.play_1d_sound(_sfx)
				_star_sel_level = wrapi(_star_sel_level + 1, 1, level_count[_star_sel_world] + 1)
				label.set_world_numbers("%d-%d" % [_star_sel_world, _star_sel_level])
	
	if !player: return
	var console_enabled: bool = SecretsManager.is_console_enabled()
	var prof = ProfileManager.profiles.get(profile_name)
	var save_is_cheated: bool = prof && prof.data.get("executed")
	
	_warp_initiator()
	if !_on_warp: return
	_warping_process(delta)


func _input(event: InputEvent) -> void:
	if player == null: return
	if !(event is InputEventKey && event.is_pressed() && !event.is_echo()):
		return
	if _tweak || !_star_world: return
	if event.keycode > 48 && event.keycode <= 57:
		if event.keycode - 48 == _star_sel_level:
			return
		if event.keycode - 48 <= level_count[_star_sel_world]:
			var _sfx = CharacterManager.get_sound_replace(SCORING, SCORING, "menu_select_short", false)
			Audio.play_1d_sound(_sfx)
			_star_sel_level = event.keycode - 48
			label.set_world_numbers("%d-%d" % [_star_sel_world, _star_sel_level])
	

func _update_save() -> void:
	_star_world = false
	label.remove_theme_color_override(&"font_color")
	
	var prof = ProfileManager.profiles.get(profile_name)
	if prof && prof.data.get("star_world"):
		_star_world = prof.data.star_world
		label.add_theme_color_override(&"font_color", Color.LIGHT_GREEN)
		var wnumbers: Array
		if prof.data.get("star_numbers"):
			wnumbers = prof.data.star_numbers.split("-")
		else:
			wnumbers = prof.get_world_numbers().split("-")
		_star_sel_world = int(wnumbers[0])
		_star_sel_level = int(wnumbers[1])
		label.set_world_numbers("-".join(wnumbers))
	elif force_disable_level_save && prof:
		var world_numbers: String = prof.get_world_numbers().get_slice("-", 0)
		if !world_numbers.is_empty():
			label._tweak = true
			label.set_world_numbers(world_numbers)


func delete_save() -> void:
	ProfileManager.delete_profile(profile_name)
	if ProfileManager.profiles.has("suspended") && ProfileManager.profiles.suspended.data.get("saved_profile") == profile_name:
		ProfileManager.delete_profile("suspended")
	save_deleted.emit()
	print(&"Save " + profile_name + &" deleted!")
	Audio.play_1d_sound(preload("res://engine/objects/bumping_blocks/_sounds/break.wav"))
	_star_world = false
	label.remove_theme_color_override(&"font_color")
	_update_reset_labels()


func pass_warp() -> void:
	print("--PASSING WARP--")
	ProfileManager.set_current_profile(profile_name)
	print("Entering profile: %s" % profile_name)
	if SecretsManager.is_console_enabled():
		ProfileManager.current_profile.data.executed = true
	
	if _tweak || (force_disable_level_save && !_star_world):
		ProfileManager.current_profile.data.completed_levels = []
		_star_sel_level = 1
		print("Forcibly started from Level 1. Either tweak enabled or no star level selector.")
	target = null
	if _star_world || allow_selecting_worlds:
		if _star_sel_level && _star_sel_world:
			ProfileManager.current_profile.data.star_numbers = &"%d-%d" % [_star_sel_world, _star_sel_level]
			ProfileManager.save_current_profile()
		if _star_sel_level > 1 || _star_sel_world > 1:
			print("Profile Started from world/level %d/%d, added bit to data." % [_star_sel_world, _star_sel_level])
			ProfileManager.current_profile.data.started_from_middle = true
		if _star_sel_world:
			ProfileManager.current_profile.data.current_world = map_scene_template.format([str(_star_sel_world)])
			if _star_sel_world >= 6:
				ProfileManager.current_profile.data.current_world = map_scene_template_2.format([str(_star_sel_world)])
		if _star_sel_level:
			Data.values.map_force_selected_marker = level_scene_template.format([str(_star_sel_world), str(_star_sel_level - 1)])
			Data.values.map_force_go_next = true
	
	if &"current_world" in ProfileManager.current_profile.data && ProfileManager.current_profile.data.current_world:
		warp_to_scene = ProfileManager.current_profile.data.current_world
		print("Starting from: %s" % set_data_to_profile)
	Data.values.skip_progress_continue = true
	if set_data_to_profile:
		ProfileManager.current_profile.data[set_data_to_profile] = true
		print("Profile Data: %s" % set_data_to_profile)
	await get_tree().physics_frame
	print("--END OF WARP INFO--")
	super()


func _update_reset_labels() -> void:
	if reset_node.unlock:
		reset_node.unlock.visible = (_star_world || allow_selecting_worlds) && len(level_count) > 1
	reset_node.unlock2.visible = _star_world
	reset_node.secrets.visible = false
	
	if profile_name in ProfileManager.profiles:
		var _prof = ProfileManager.profiles[profile_name].data
		
		if _star_world:
			return
		if no_applicable_text: return
		
		var _arr: PackedStringArray = ["warpless"]
		if "warped" in _prof:
			_arr.remove_at(0)
		if _arr.is_empty():
			return
		reset_node.secrets.text = tr("applicable for %s") % ", ".join(_arr)
		reset_node.secrets.visible = true
