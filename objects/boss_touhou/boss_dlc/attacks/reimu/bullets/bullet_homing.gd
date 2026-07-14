extends BulletBase

const SFX_KIRA = preload("res://objects/boss_touhou/common/sounds/se_kira00.wav")

## How many times should the amulet re-homes itself.
@export var homing_times: int = 1
## How much time should pass before the amulet readjusts its angle.
@export var homing_interval: float = 2.0
## Speed at which the amulet moves when it readjusts its angle.
@export var homing_speed: float = 50.0

@onready var player = Thunder._current_player
@onready var homing_timer: Timer = $HomingTimer
var last_player_angle: float = PI/2
var boss_handler

func _ready() -> void:
	homing_timer.timeout.connect(func() -> void:
		has_left_screen = false
		homing_times -= 1
		var new_angle: float = _aim_at_player()
		if homing_times <= 0:
			homing_speed *= 2.0
		var new_velocity = Vector2(homing_speed * cos(new_angle), homing_speed * sin(new_angle))
		actual_vel = new_velocity
		rotation = new_angle
		if is_instance_valid(boss_handler):
			boss_handler._play_sound_interruptable(SFX_KIRA)
		)
	
	appear_animation()
	super()

func _aim_at_player() -> float:
	if is_instance_valid(player):
		last_player_angle = global_position.angle_to_point(player.global_position)
	return last_player_angle

func _movement_process(delta: float) -> void:
	if homing_timer.is_stopped() and homing_times > 0:
		homing_timer.start(homing_interval)
		var velocity_tween = get_tree().create_tween()
		velocity_tween.tween_property(self, "actual_vel", Vector2.ZERO, clampf(homing_interval - 0.2, 0.01, homing_interval))
	if has_left_screen and homing_times <= 0: delete_self(true, true)
	if !allow_movement: return
	global_position += actual_vel * delta
