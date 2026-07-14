extends GravityBody2D

@export_category("Bullet")
@export_enum("Nothing: 0", "Hurt: 1", "Death: 2") var type: int = 1
@export var ignore_starman: bool = true

const ERASE_EFF = preload("res://objects/boss_touhou/common/components/bullet_erase_effect.tscn")
const ERASE_SFX = preload("res://objects/boss_touhou/common/sounds/se_etbreak.wav")

@export_group("Bullet Details")
@export var bullet_erase_color: Color = Color.RED
@export var bullet_erase_sound: AudioStream = ERASE_SFX
@export var bullet_erase_scale: float = 1.0
@export var ignore_modulate_alpha_for_collision: bool = false
@export var appear_animation_time: float = 0.5
@export var deletable_bullet: bool = true
@export var spin_speed: float = 10.0
@export_group("Bounce Details")
@export var yinyang_jump_speed: float = 500.0
@export var screen_edge_bounce_times: int = 1
var anchor_for_bounce: Vector2 = Vector2.ZERO
var bounce_range_min: Vector2
var bounce_range_max: Vector2

var veloc: Vector2 = Vector2(300.0, 0.0)
var allow_movement: bool = false
var force_disable_collision: bool = false
var has_left_screen: bool = false

enum MovementDisableType {
	SLOWED_DOWN,
	INSTANT
}

@onready var bullet_sprite = $Sprite
@onready var hurt_area = $HurtArea

func _ready() -> void:
	super()
	bounce_range_min = Vector2(anchor_for_bounce.x - 320.0, anchor_for_bounce.y - 240.0)
	bounce_range_max = Vector2(anchor_for_bounce.x + 320.0, anchor_for_bounce.y + 240.0)
	enable_movement()

func _physics_process(delta: float) -> void:
	motion_process(delta, false)
	
	if speed.x >= 0: bullet_sprite.rotate(deg_to_rad(spin_speed))
	else: bullet_sprite.rotate(-deg_to_rad(spin_speed))
	
	if screen_edge_bounce_times > 0:
		if global_position.x <= bounce_range_min.x:
			turn_x()
			_bounce_triggered()
		if global_position.x >= bounce_range_max.x:
			turn_x()
			_bounce_triggered()
	
	var player: Player = Thunder._current_player
	if !player: return
	if player.is_starman() && ignore_starman: return
	if (bullet_sprite.self_modulate.a >= 1.0 or ignore_modulate_alpha_for_collision) and !force_disable_collision:
		if hurt_area.overlaps_body(player):
			match type:
				1 when !player.is_invincible(): player.hurt()
				2: player.die()
			if deletable_bullet: delete_self()


func motion_process(delta: float, slide: bool = false) -> void:
	if has_left_screen and screen_edge_bounce_times <= 0: delete_self(true, true)
	if !allow_movement: return
	super(delta, slide)


func enable_movement() -> void:
	speed = veloc
	allow_movement = true


func _on_collided_floor() -> void:
	jump(yinyang_jump_speed)


func _bounce_triggered() -> void:
	if has_left_screen: return
	screen_edge_bounce_times -= 1


func delete_self(autodelete: bool = false, offscreen: bool = false) -> void:
	if !offscreen:
		var erase_effect = ERASE_EFF.instantiate()
		Scenes.current_scene.add_child(erase_effect)
		erase_effect.modulate = bullet_erase_color
		erase_effect.global_position = global_position
		erase_effect.scale = Vector2(bullet_erase_scale, bullet_erase_scale)
		erase_effect.reset_physics_interpolation()
	if bullet_erase_sound and !autodelete:
		Audio.play_sound(bullet_erase_sound, self)
	queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	has_left_screen = true

func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	has_left_screen = false


func appear_animation() -> void:
	pass


func _on_collided_wall() -> void:
	turn_x()
