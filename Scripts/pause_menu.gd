extends CanvasLayer

@onready var continue_button: Button = $CenterContainer/VBoxContainer/ContinueButton
@onready var back_to_menu_button: Button = $CenterContainer/VBoxContainer/BackToMenuButton

func _ready() -> void:
	hide()
	GameManager.pause_changed.connect(_on_pause_changed)
	continue_button.pressed.connect(GameManager.toggle_pause)
	back_to_menu_button.pressed.connect(GameManager.go_to_menu)

func _on_pause_changed(paused: bool) -> void:
	visible = paused
