extends Control
# Menú principal. Cada función está conectada a un botón desde el editor (pestaña Nodo → Señales).


# Botón Jugar: arranca el nivel 1.
func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://Scene/nivel_1.tscn")


# Botón Opciones: va a la pantalla de opciones.
func _on_options_pressed() -> void:
	get_tree().change_scene_to_file("res://Scene/options.tscn")


# Botón Salir: cierra el juego.
func _on_quit_pressed() -> void:
	get_tree().quit()
