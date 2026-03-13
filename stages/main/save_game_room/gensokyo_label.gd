extends Label

func _ready() -> void:
	text = "SOMETHING FANTASTICAL WILL SURELY APPEAR HERE IN DUE TIME...\nRETURN WHEN THE PARTY IS OVER."
	if SecretsManager.has_secret("main clear") and !SecretsManager.has_secret("9-3 nohit"):
		text = "SOMETHING FANTASTICAL WILL SURELY APPEAR HERE SOON...\nRETURN AFTER SURVIVING ONE OF THE JOURNALISTS UNSCATHED."
