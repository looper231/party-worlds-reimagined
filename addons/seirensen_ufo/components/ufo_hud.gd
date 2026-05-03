extends Control

const UFO_SPAWN_SOUND = preload("res://addons/seirensen_ufo/sfx/ufo_enemy_spawn.wav")
const MUSHROOM_POWERUP = preload("res://engine/objects/powerups/red_mushroom/red_mushroom.tscn")

const ALERT_APPEAR_TIME = 0.1
const ALERT_VANISH_TIME = 0.45

@export_category("UFO Mechanic Properties")
@export_group("UFO Enemy Properties")
## The Powerup that gets dropped when a Red UFO or Flashing UFO is defeated.
@export var powerup_type: PackedScene = MUSHROOM_POWERUP
## (In points) How much should the UFO have at minimum to qualify for bonus drops.
## Coins are worth 100 points.
@export var bonus_threshold: int = 2000

@onready var display_ufo: Array[AnimatedSprite2D] = [
	$UFO1,
	$UFO2,
	$UFO3
]
@onready var alert_label: Label = $UFOAnnounce

var is_ufo_summoned: bool = false
var ufo_array: Array
var alert_label_tween: Tween

func _ready() -> void:
	alert_label.hide()
	ufo_array = UFOGlobals.ufo_data_get()
	_change_ufo_icon_speed()

func _physics_process(delta: float) -> void:
	# Update displays.
	for i in display_ufo.size():
		var ufo_value: int = -1
		if i < ufo_array.size(): ufo_value = ufo_array[i]
		_update_ufo_icon(i, ufo_value)
	
	# If all 3 slots are filled, spawn an UFO.
	if !is_ufo_summoned and ufo_array.size() >= 3:
		is_ufo_summoned = true
		_change_ufo_icon_speed()
		_summon_ufo_enemy()

func _update_ufo_icon(ufo_index: int = 0, ufo_data = -1) -> void:
	var should_be_playing_anim: String = &"default"
	
	match ufo_data:
		UFOGlobals.UFO_COLOR.Red:
			should_be_playing_anim = &"red"
		UFOGlobals.UFO_COLOR.Green:
			should_be_playing_anim = &"green"
		UFOGlobals.UFO_COLOR.Blue:
			should_be_playing_anim = &"blue"
	
	if display_ufo[ufo_index].animation != should_be_playing_anim:
		display_ufo[ufo_index].play(should_be_playing_anim)

func _change_ufo_icon_speed() -> void:
	for i in display_ufo.size():
		display_ufo[i].speed_scale = 1.0 if is_ufo_summoned else 0.0

func _summon_ufo_enemy() -> void:
	# Play UFO spawn sound.
	Audio.play_1d_sound(UFO_SPAWN_SOUND, false, { "bus": "1D Sound" })
	# Make the alert appear.
	alert_label.scale.y = 0.0
	alert_label.modulate.a = 0.0
	alert_label.show()
	if alert_label_tween:
		alert_label_tween.kill()
	alert_label_tween = get_tree().create_tween()
	alert_label_tween.tween_property(alert_label, "scale:y", 1.0, ALERT_APPEAR_TIME)
	alert_label_tween.parallel().tween_property(alert_label, "modulate:a", 1.0, ALERT_APPEAR_TIME)
	alert_label_tween.tween_interval(0.6)
	alert_label_tween.tween_property(alert_label, "scale", Vector2(3.0, 3.0), ALERT_VANISH_TIME)
	alert_label_tween.parallel().tween_property(alert_label, "modulate:a", 0.0, ALERT_VANISH_TIME / 2)

func _on_ufo_enemy_killed() -> void:
	UFOGlobals.ufo_data_reset()
	is_ufo_summoned = false
	_change_ufo_icon_speed()
