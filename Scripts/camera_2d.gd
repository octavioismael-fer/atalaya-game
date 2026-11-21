extends Camera2D
# Cámara que sigue al gato. En horizontal lo sigue siempre; en vertical se queda quieta
# en un "nivel normal" y solo se mueve si el gato aterriza en otra altura o se acerca al borde.

# Todo son proporciones de la MITAD de la altura visible de la pantalla
const VERTICAL_BIAS = 0.4            # Dónde se ve el personaje en reposo: 0 = centro, 0.4 = más abajo (ves más hacia arriba)
const EDGE_MARGIN = 0.3              # Espacio mínimo que se deja entre el personaje y el borde de la pantalla
const GROUND_RECENTER_RATIO = 0.6    # Al aterrizar, qué parte del rango permitido tolera antes de recentrar
const CAMERA_SPEED = 5.0             # Qué tan rápido acomoda la altura (más alto = más brusco)

@onready var player: CharacterBody2D = get_parent()

var anchor_y := 0.0   # Nivel "normal" de la cámara
var target_y := 0.0   # Altura a la que la cámara quiere llegar en este momento

func _ready() -> void:
	# Esperamos a que el gato esté listo (y en su spawn/checkpoint) antes de ubicarnos.
	await player.ready
	# top_level: la cámara deja de moverse sola con el gato; la movemos nosotros a mano.
	top_level = true
	global_position = player.global_position
	anchor_y = player.global_position.y
	target_y = anchor_y

# Cada frame de física decidimos a qué altura tiene que ir la cámara.
func _physics_process(delta: float) -> void:
	global_position.x = player.global_position.x

	# Mitad de la altura que se ve en pantalla, en unidades del mundo (depende del zoom).
	var half_height = get_viewport_rect().size.y / zoom.y / 2.0

	# El desplazamiento lo manejamos aquí (negativo = la cámara mira más arriba del personaje)
	offset.y = -VERTICAL_BIAS * half_height

	# Espacio que hay arriba y abajo del personaje en reposo, menos el margen
	var room_up = half_height * (1.0 + VERTICAL_BIAS - EDGE_MARGIN)
	var room_down = half_height * (1.0 - VERTICAL_BIAS - EDGE_MARGIN)

	var y_diff = player.global_position.y - anchor_y   # negativo = el personaje está más arriba

	if player.is_on_floor():
		# Aterrizó lejos del nivel normal: ese pasa a ser el nuevo nivel
		if y_diff < -room_up * GROUND_RECENTER_RATIO or y_diff > room_down * GROUND_RECENTER_RATIO:
			anchor_y = player.global_position.y
		target_y = anchor_y
	else:
		# En el aire, la cámara se queda en el nivel normal...
		target_y = anchor_y
		# ...salvo que el personaje se acerque a un borde de la pantalla
		if y_diff < -room_up:
			target_y = player.global_position.y + room_up
		elif y_diff > room_down:
			target_y = player.global_position.y - room_down

	# lerp: se acerca de a poco a la altura objetivo, así el movimiento es suave.
	global_position.y = lerp(global_position.y, target_y, CAMERA_SPEED * delta)
