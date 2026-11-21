extends CanvasLayer
# Menú de pausa: cartel "PAUSA" con los botones Continuar y Menú.
# En la escena tiene Process Mode = When Paused, o sea que solo funciona mientras el juego está pausado.

@onready var continue_button: Button = $CenterContainer/VBoxContainer/ContinueButton
@onready var back_to_menu_button: Button = $CenterContainer/VBoxContainer/BackToMenuButton

func _ready() -> void:
	hide()  # Arranca escondido
	# Cuando el GameManager pausa o despausa, mostramos u ocultamos el menú.
	GameManager.pause_changed.connect(_on_pause_changed)
	# Los botones van directo a las funciones del GameManager, sin intermediarios.
	continue_button.pressed.connect(GameManager.toggle_pause)
	back_to_menu_button.pressed.connect(GameManager.go_to_menu)

# Si está pausado se ve; si no, se esconde.
func _on_pause_changed(paused: bool) -> void:
	visible = paused
