extends Node

const MENU_SCENE := "res://Scene/menu.tscn"


func _ready() -> void:
		process_mode = Node.PROCESS_MODE_ALWAYS
		
func level_completed() -> void:
	# Más adelante: solo terminar si se juntaron los 3 objetos
	go_to_menu()

func restart_level() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()
	
func toggle_pause() -> void:
	get_tree().paused = not get_tree().paused

func _unhandled_input(event: InputEvent) -> void:
		if not is_in_level():
				return

		if event.is_action_pressed("menu"):
				go_to_menu()
		elif event.is_action_pressed("restart"):
				restart_level()
		elif event.is_action_pressed("pause"):
				toggle_pause()


func is_in_level() -> bool:
		var scene := get_tree().current_scene
		return scene != null and scene.is_in_group("level")


func go_to_menu() -> void:
		get_tree().paused = false
		get_tree().change_scene_to_file(MENU_SCENE)
