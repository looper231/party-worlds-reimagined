extends AnimatedSprite2D

@export_group("UFO Spawning Properties")
@export var ufo_packed_scene: PackedScene
@export_enum("Red: 0", "Green: 1", "Blue: 2") var ufo_color: int = 0
@export var is_volatile_color: bool = false

func spawn_ufo() -> void:
	print("UFO should spawn now.")
	hide()
	
	var spawn_position = Vector2(
		global_position.x - position.x,
		global_position.y - position.y
	)
	if !is_instance_valid(ufo_packed_scene): return
	var new_ufo = ufo_packed_scene.instantiate()
	new_ufo.ufo_color = ufo_color
	new_ufo.is_volatile_color = is_volatile_color
	
	# Set speed.
	var player = Thunder._current_player
	if player:
		if player.global_position.x < spawn_position.x:
			new_ufo.speed.x = abs(new_ufo.speed.x)
		else:
			new_ufo.speed.x = abs(new_ufo.speed.x) * -1
		if player.global_position.y < spawn_position.y:
			new_ufo.speed.y = abs(new_ufo.speed.y)
		else:
			new_ufo.speed.y = abs(new_ufo.speed.y) * -1
	
	Scenes.current_scene.add_child(new_ufo)
	new_ufo.global_position = spawn_position
	new_ufo.reset_physics_interpolation()
	
	queue_free()
