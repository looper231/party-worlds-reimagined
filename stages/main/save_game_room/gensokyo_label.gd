extends Label

func _ready() -> void:
	text = "SOMETHING FANTASTICAL WILL SURELY APPEAR HERE IN DUE TIME...\nRETURN WHEN THE FINAL WORLD HAS BEEN COMPLETED."
	if SecretsManager.has_secret("main clear") and !SecretsManager.has_secret("9-3 nohit"):
		text = "SOMETHING FANTASTICAL WILL SURELY APPEAR HERE SOON...\nRETURN AFTER SURVIVING ONE OF THE JOURNALISTS UNSCATHED."
	if SecretsManager.has_secret("main clear") and SecretsManager.has_secret("9-3 nohit") and is_instance_valid(get_parent()): get_parent().queue_free()
