extends Node
# El "jefe" del juego. Es un autoload: existe siempre, aunque cambies de escena.
# Se acuerda del checkpoint, de los objetos juntados y maneja pausa, reinicio y volver al menú.

# Señales: avisan a quien quiera escuchar (el HUD, el menú de pausa) cuando algo cambia.
signal collectibles_changed(count: int, total: int)
signal pause_changed(paused: bool)
const MENU_SCENE := "res://Scene/menu.tscn"
var has_checkpoint := false                      # ¿Ya pasó por algún checkpoint?
var checkpoint_position := Vector2.ZERO          # Dónde reaparece el gato si hay checkpoint
const REQUIRED_COLLECTIBLES := 3                 # Cuántos objetos hacen falta para terminar el nivel
var collected: Array[String] = []                # Nombres de los objetos juntados hasta ahora
var collected_at_checkpoint: Array[String] = []  # Foto de lo que tenías al tocar el checkpoint

# Anota un objeto como juntado (si no estaba ya) y avisa al HUD.
func collect(id: String) -> void:
	if id not in collected:
		collected.append(id)
	collectibles_changed.emit(collected.size(), REQUIRED_COLLECTIBLES)

# ¿Ya juntaste todo lo que hace falta?
func has_all_collectibles() -> bool:
	return collected.size() >= REQUIRED_COLLECTIBLES

# Borra todos los objetos juntados (se usa al volver al menú).
func reset_collectibles() -> void:
	collected.clear()
	collectibles_changed.emit(collected.size(), REQUIRED_COLLECTIBLES)

# Guarda el checkpoint: la posición y una copia de los objetos que tenías en ese momento.
func set_checkpoint(pos: Vector2) -> void:
	has_checkpoint = true
	checkpoint_position = pos
	collected_at_checkpoint = collected.duplicate()

# Olvida el checkpoint, así la próxima partida arranca desde el spawn.
func clear_checkpoint() -> void:
	has_checkpoint = false
	collected_at_checkpoint.clear()

# ¿Este objeto ya lo agarraste? Lo usan los coleccionables para no volver a aparecer.
func is_collected(id: String) -> bool:
	return id in collected

func _ready() -> void:
	# ALWAYS = sigue andando aunque el juego esté en pausa (si no, no podrías despausar).
	process_mode = Node.PROCESS_MODE_ALWAYS

# La llama la meta. Si te faltan objetos no pasa nada; si tenés todos, volvés al menú.
func level_completed() -> void:
	if not has_all_collectibles():
		print("Te faltan objetos: ", collected.size(), "/", REQUIRED_COLLECTIBLES)
		return
	go_to_menu()

# Reinicia el nivel (tecla R): volvés a los objetos que tenías en el checkpoint y se recarga la escena.
func restart_level() -> void:
	collected = collected_at_checkpoint.duplicate()
	collectibles_changed.emit(collected.size(), REQUIRED_COLLECTIBLES)
	get_tree().paused = false
	get_tree().reload_current_scene()

# Pausa o despausa (tecla P o botón Continuar) y avisa al menú de pausa.
func toggle_pause() -> void:
	get_tree().paused = not get_tree().paused
	pause_changed.emit(get_tree().paused)

# Atajos de teclado: M = menú, R = reiniciar, P = pausa. Solo funcionan dentro de un nivel.
func _unhandled_input(event: InputEvent) -> void:
	if not is_in_level():
		return

	if event.is_action_pressed("menu"):
		go_to_menu()
	elif event.is_action_pressed("restart"):
		restart_level()
	elif event.is_action_pressed("pause"):
		toggle_pause()


# ¿Estamos jugando un nivel? Se fija si la escena actual está en el grupo "level".
func is_in_level() -> bool:
	var scene := get_tree().current_scene
	return scene != null and scene.is_in_group("level")


# Vuelve al menú principal, limpiando checkpoint y objetos para arrancar de cero la próxima vez.
func go_to_menu() -> void:
	clear_checkpoint()
	reset_collectibles()
	get_tree().paused = false
	# call_deferred: cambia de escena al final del frame, para no borrar cosas en medio de la física.
	get_tree().change_scene_to_file.call_deferred(MENU_SCENE)
