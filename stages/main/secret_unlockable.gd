extends Node2D

@export var secrets_conditionals: Array[String]
@export var achievements_to_unlock: Array[String]
@export var any_secret_can_unlock: bool = false
@export var callback_only: bool

signal unlock_achievement
signal node_hidden

func _ready() -> void:
	if len(secrets_conditionals) <= 0:
		unlock_achievements()
		return
	var should_show_extra: bool = true
	if any_secret_can_unlock: should_show_extra = false
	
	hide()
	if !callback_only:
		for secret_name in secrets_conditionals:
			if any_secret_can_unlock:
				if special_get_secret(secret_name): should_show_extra = true
			elif !special_get_secret(secret_name): should_show_extra = false
		
		if should_show_extra:
			show()
			reset_physics_interpolation()
			unlock_achievements()
			return
	
	process_mode = Node.PROCESS_MODE_DISABLED
	node_hidden.emit()


func special_get_secret(secret_name: String) -> bool:
	if secret_name == "main clear" || secret_name == "staff roll":
		return SecretsManager.has_secret("main clear") or SecretsManager.has_secret("staff roll")
	else: return SecretsManager.has_secret(secret_name)


func activate() -> void:
	show()
	reset_physics_interpolation()
	process_mode = Node.PROCESS_MODE_INHERIT
	unlock_achievements()


func unlock_achievements() -> void:
	if len(achievements_to_unlock) <= 0:
		return
	for achievement_name in achievements_to_unlock:
		unlock_achievement.emit(achievement_name)
