extends Control
# Pantalla de opciones. Por ahora solo tiene el botón para volver.


# Botón Atrás: vuelve al menú principal.
func _on_atras_pressed() -> void:
	get_tree().change_scene_to_file("res://Scene/menu.tscn")
