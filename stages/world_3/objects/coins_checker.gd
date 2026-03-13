extends Node

@export var sound = preload("res://objects/w7_spawn_portal/sounds/correct.wav")

var has_killed_all: bool = false
signal warp_conditions_met

func _physics_process(delta: float) -> void:
	if has_killed_all: return
	
	var has_enemies: bool = false
	for i in get_children():
		if is_instance_valid(i):
			has_enemies = true
	
	if !has_enemies && !has_killed_all:
		has_killed_all = true
		Audio.play_1d_sound(sound)
		warp_conditions_met.emit()
