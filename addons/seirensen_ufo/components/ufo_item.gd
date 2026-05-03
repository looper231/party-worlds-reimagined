extends GeneralMovementBody2D
class_name UFOItem

const UFO_SPAWN_SOUND = preload("res://addons/seirensen_ufo/sfx/ufo_item_spawn.wav")
const UFO_COLLECT_SOUND = preload("res://addons/seirensen_ufo/sfx/ufo_item_collect.wav")
const UFO_SWAP_SOUND = preload("res://addons/seirensen_ufo/sfx/ufo_item_change.wav")

@export_group("UFO")
@export_subgroup("Main Properties")
@export var score: int = 0
@export var is_volatile_color: bool = false
@export var player_proximity_distance: float = 80.0
@export var player_collect_delay_sec: float = 0.4
@export_enum("Red: 0", "Green: 1", "Blue: 2") var ufo_color: int = 0
@export_enum("Up: -1", "Down: 1") var force_y_direction: int = 1
@export_subgroup("Sounds")
@export var item_spawning_sound: AudioStream = UFO_SPAWN_SOUND
@export var item_collect_sound: AudioStream = UFO_COLLECT_SOUND
@export var item_color_swap_sound: AudioStream = UFO_SWAP_SOUND

@onready var swap_timer: Timer = $Timer
@onready var body = $Body
@onready var nearest_player = Thunder._current_player
var swap_tween: Tween
var time_counter: int = 0
var is_near_player: bool = false
var can_collect: bool = false
var can_despawn: bool = false

var camera_limit_left: int = -10000
var camera_limit_right: int = 10000
var camera_limit_top: int = -10000
var camera_limit_bottom: int = 10000
var camera_limit_rect: Rect2i

func _ready() -> void:
	# Change color of the UFO upon spawning.
	set_ufo_color()
	
	# Play the spawn sound.
	Audio.play_sound(item_spawning_sound, self)
	
	# If the color is volatile, start the timer.
	if is_volatile_color: swap_timer.start()
	swap_timer.timeout.connect(func() -> void:
		swap_ufo_color()
		swap_timer.start()
	)
	
	super()
	
	# Wait some seconds before UFO can be collected.
	# This is to avoid situations where the player collects an UFO against their will.
	await get_tree().create_timer(player_collect_delay_sec, false, false).timeout
	can_collect = true
	
	var current_camera = Thunder._current_camera
	if current_camera:
		camera_limit_left = current_camera.limit_left + 16
		camera_limit_right = current_camera.limit_right - 16
		camera_limit_top = current_camera.limit_top + 16
		camera_limit_bottom = current_camera.limit_bottom - 16
		camera_limit_rect = Rect2i()
		camera_limit_rect.position = Vector2i(
			camera_limit_left - 32, camera_limit_top - 32
		)
		camera_limit_rect.end = Vector2i(
			camera_limit_right + 32, camera_limit_bottom + 32
		)

func _physics_process(delta: float) -> void:
	ufo_bounds_check()
	
	# Tilt the UFO.
	time_counter += 7
	# Check proximity to the nearest player.
	if nearest_player:
		var dist_to_player = global_position.distance_to(nearest_player.global_position)
		if !is_near_player and dist_to_player <= player_proximity_distance:
			is_near_player = true
			set_ufo_color()
			swap_timer.paused = true
		elif is_near_player and dist_to_player > player_proximity_distance:
			is_near_player = false
			set_ufo_color()
			swap_timer.paused = false
	# If it's close enough, start tilting faster.
	if is_near_player: time_counter += 7
	
	if sprite_node:
		sprite_node.rotation_degrees = sin(deg_to_rad(time_counter)) * 10.0
	
	# If the UFO's color is volatile, check whether to speed up the animation speed.
	if is_volatile_color and is_instance_valid(swap_timer) and is_instance_valid(sprite_node):
		if swap_timer.time_left <= 1.0:
			sprite_node.speed_scale = 2.0
	
	super(delta)
	
	# Collision detection to player.
	if !nearest_player or !can_collect: return
	var overlaps: bool = body.overlaps_body(nearest_player)
	if overlaps: collect()

func ufo_bounds_check() -> void:
	if !camera_limit_rect: return
	# Check when lifetime is still valid first.
	if !can_despawn:
		if global_position.x <= camera_limit_left:
			print("UFO about to leave bounds. Rebouncing...")
			vel_set_x(absf(speed.x))
		if global_position.x >= camera_limit_right:
			print("UFO about to leave bounds. Rebouncing...")
			vel_set_x(absf(speed.x) * -1)
		if global_position.y <= camera_limit_top:
			print("UFO about to leave bounds. Rebouncing...")
			vel_set_y(absf(speed.y))
		if global_position.y >= camera_limit_bottom:
			print("UFO about to leave bounds. Rebouncing...")
			vel_set_y(absf(speed.y) * -1)
	# Now check when lifetime is out.
	elif !camera_limit_rect.has_point(global_position):
		queue_free()

func collect() -> void:
	# Play the collect sound.
	Audio.play_sound(item_collect_sound, self)
	
	# Add to score if not done already.
	if score > 0:
		ScoreText.new(str(score), self)
		Data.add_score(score)
	
	# Add to the UFO counter.
	UFOGlobals.ufo_data_add(ufo_color)
	
	# Delete the item.
	queue_free()

func set_ufo_color() -> void:
	if is_instance_valid(sprite_node):
		var sprite_anim_name: String = "blue"
		
		match ufo_color:
			UFOGlobals.UFO_COLOR.Red:
				sprite_anim_name = "red"
			UFOGlobals.UFO_COLOR.Green:
				sprite_anim_name = "green"
			_:
				sprite_anim_name = "blue"
		if is_volatile_color and !is_near_player:
			sprite_anim_name = sprite_anim_name + "_glow"
		
		sprite_node.play(sprite_anim_name)

# This gets called whenever it's time to swap to a different color.
# Plays a sound, briefly shrinks and re-expands the sprite, reset animation speed.
# And reset the timer until it's time to swap again.
func swap_ufo_color() -> void:
	# Resize
	if swap_tween:
		swap_tween.kill()
	if sprite_node:
		sprite_node.scale = Vector2(0.1, 0.1)
		sprite_node.speed_scale = 1.0
		swap_tween = get_tree().create_tween()
		swap_tween.tween_property(sprite_node, "scale", Vector2.ONE, 0.1)
	
	# Swap color
	ufo_color = wrapi(ufo_color - 1, 0, 3)
	set_ufo_color()
	
	# Play sound
	Audio.play_sound(item_color_swap_sound, self)

# Despawn the UFO if it reached the end of its lifetime.
func _life_time_ended() -> void:
	can_despawn = true
	print("[UFO Item] Lifetime reached. UFO can now leave the playfield.")
