extends Node

signal collectibles_changed(count: int, total: int)
signal pause_changed(paused: bool)
const MENU_SCENE := "res://Scene/menu.tscn"
var has_checkpoint := false
var checkpoint_position := Vector2.ZERO
const REQUIRED_COLLECTIBLES := 3
var collected: Array[String] = []
var collected_at_checkpoint: Array[String] = []

func collect(id: String) -> void:
	if id not in collected:
		collected.append(id)
	collectibles_changed.emit(collected.size(), REQUIRED_COLLECTIBLES)

func has_all_collectibles() -> bool:
	return collected.size() >= REQUIRED_COLLECTIBLES

func reset_collectibles() -> void:
	collected.clear()
	collectibles_changed.emit(collected.size(), REQUIRED_COLLECTIBLES)
		
func set_checkpoint(pos: Vector2) -> void:
	has_checkpoint = true
	checkpoint_position = pos
	collected_at_checkpoint = collected.duplicate()

func clear_checkpoint() -> void:
	has_checkpoint = false
	collected_at_checkpoint.clear()
	
func is_collected(id: String) -> bool:
	return id in collected

func _ready() -> void:
		process_mode = Node.PROCESS_MODE_ALWAYS
		
func level_completed() -> void:
	if not has_all_collectibles():
		print("Te faltan objetos: ", collected.size(), "/", REQUIRED_COLLECTIBLES)
		return
	go_to_menu()

func restart_level() -> void:
	collected = collected_at_checkpoint.duplicate()
	collectibles_changed.emit(collected.size(), REQUIRED_COLLECTIBLES)
	get_tree().paused = false
	get_tree().reload_current_scene()
	
func toggle_pause() -> void:
	get_tree().paused = not get_tree().paused
	pause_changed.emit(get_tree().paused)

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
	clear_checkpoint()
	reset_collectibles()
	get_tree().paused = false
	get_tree().change_scene_to_file(MENU_SCENE)
