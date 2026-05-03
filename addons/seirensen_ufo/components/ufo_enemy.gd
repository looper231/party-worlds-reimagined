extends Node2D

const UFO_HURT_SOUND: AudioStream = preload("res://engine/objects/bosses/bowser/sounds/bowser_hurt.wav")
const UFO_KILL_SOUND: AudioStream = preload("res://addons/seirensen_ufo/sfx/ufo_enemy_kill.wav")
const UFO_WANDER_SOUND: AudioStream = preload("res://addons/seirensen_ufo/sfx/ufo_enemy_wander.wav")

signal ufo_killed
signal ufo_health_changed(to: int)

@export var max_health: int = 9
@export var lifetime_sec: float = 10.0
@export var invincible_flashing_interval: float = 0.8
@export var invincible_duration: float = 2

var ufo_color: int
var powerup_type: PackedScene
var bonus_threshold: int
var current_coin_count: int = 0
var current_score_count: int = 0
var total_score_count: int = 0
var current_health: int = 0:
	set(to):
		current_health = to
		(func() -> void: ufo_health_changed.emit(current_health)).call_deferred()

var tween_hurt: Tween
var tween_hurt_blinking: Tween

@onready var enemy_attacked = $Body/EnemyAttacked
@onready var sprite: AnimatedSprite2D = $Sprite
@onready var initial_killing_immune: Dictionary = enemy_attacked.killing_immune.duplicate(true)
@onready var player: Player = Thunder._current_player

func _ready() -> void:
	current_health = max_health

func _physics_process(delta: float) -> void:
	_movement()

func hurt(_external_damage_source: bool = false) -> void:
	if tween_hurt: return
	enemy_attacked.killing_immune = {}
	
	if current_health > 0:
		Audio.play_sound(UFO_HURT_SOUND, self)
		current_health -= 1
		Thunder.autosplitter.update_il_counter()
	if current_health <= 0:
		die()
		return
	
	# If this is caused by projectiles, do not apply cooldown.
	if _external_damage_source: return
	
	var stomp_standard: Vector2 = enemy_attacked.stomping_standard
	
	tween_hurt = create_tween()
	tween_hurt.tween_callback(
		func() -> void:
			enemy_attacked.stomping_standard = Vector2.ZERO
	)
	tween_hurt.tween_interval(invincible_duration)
	
	if tween_hurt_blinking:
		tween_hurt_blinking.stop()
	sprite.modulate.a = 1.0
	tween_hurt_blinking = create_tween()
	
	for i in ceili(invincible_duration / invincible_flashing_interval):
		tween_hurt_blinking.tween_property(sprite, "modulate:a", 0.25, invincible_flashing_interval / 2)
		tween_hurt_blinking.tween_property(sprite, "modulate:a", 1.0, invincible_flashing_interval / 2)
	
	tween_hurt.finished.connect(func() -> void:
		tween_hurt.kill()
		tween_hurt = null
		sprite.modulate.a = 1.0
		enemy_attacked.stomping_standard = stomp_standard
		enemy_attacked.killing_immune = initial_killing_immune.duplicate(true)
	, CONNECT_ONE_SHOT)

func hurt_projectile(attacker: StringName) -> void:
	if tween_hurt: return
	
	current_health -= 2
	if attacker == &"beetroot": current_health -= 1
	Thunder.autosplitter.update_il_counter()
	
	if current_health <= 0: die()

func die() -> void:
	ufo_killed.emit()
	
	queue_free()

func _movement() -> void:
	pass
