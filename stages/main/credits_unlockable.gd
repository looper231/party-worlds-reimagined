extends StaticBody2D

@export var callback_only: bool = false

func _ready() -> void:
	hide()
	if !callback_only && (SecretsManager.has_secret("main clear") || CustomGlobals.unlock_fancy_credits):
		show()
		reset_physics_interpolation()
		return
	
	process_mode = Node.PROCESS_MODE_DISABLED


func activate() -> void:
	show()
	reset_physics_interpolation()
	process_mode = Node.PROCESS_MODE_INHERIT
