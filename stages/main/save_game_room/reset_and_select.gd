extends "res://engine/scenes/save_game_room/scripts/reset.gd"

@export var count_world_start_tweak: bool = true
@export var can_delete_save: bool = true

@onready var _tweak: bool = SettingsManager.get_tweak("load_save_from_world_start", false)
@onready var unlock: Label = get_node_or_null(^"VBoxContainer/Unlock")
@onready var unlock2: Label = get_node_or_null(^"VBoxContainer/Unlock2")
@onready var secrets: Label = get_node_or_null(^"VBoxContainer/Secrets")

func _ready() -> void:
	super()
	move_down_by_px += 16
	if _tweak && count_world_start_tweak:
		unlock2.text = 'to select a level, disable the "always load first level" tweak'


func _physics_process(delta: float) -> void:
	if !is_inside: return
	if !can_delete_save: return
	super(delta)


func _on_pipe_save_player_enter() -> void:
	position.x = 0
	super()


func _player_enter_centered(x_position: float = 1840) -> void:
	_on_pipe_save_player_enter()
	position.x = x_position
