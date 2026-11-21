extends CharacterBody2D
# El gato: movimiento, salto doble, agarrar cajas y animaciones.

const SPEED = 150.0          # Velocidad caminando
const JUMP_VELOCITY = -300.0 # Fuerza del salto (negativo = hacia arriba)
const MAX_JUMPS = 2          # 2 = salto doble

const GRAB_SPEED = 100.0     # Velocidad cuando arrastra una caja (más lento)

var nearby_box: RigidBody2D = null   # Caja que tiene cerca (la avisa la propia caja)
var grabbed_box: RigidBody2D = null  # Caja que tiene agarrada ahora

@onready var animationPlayer = $AnimationPlayer
@onready var sprite2D = $Sprite2D

var jump_count = 0
var is_double_jumping = false

# Al aparecer: si hay checkpoint arranca ahí; si no, en el Spawnpoint del nivel.
func _ready() -> void:
	if GameManager.has_checkpoint:
		global_position = GameManager.checkpoint_position
	else:
		var spawn := get_tree().get_first_node_in_group("spawn")
		if spawn:
			global_position = spawn.global_position

# La llama la caja cuando el gato entra en su zona.
func set_nearby_box(box: RigidBody2D) -> void:
	nearby_box = box

# La llama la caja cuando el gato sale de su zona (solo si era esa misma caja).
func clear_nearby_box(box: RigidBody2D) -> void:
	if nearby_box == box:
		nearby_box = null

# Agarra la caja.
func grab(box: RigidBody2D) -> void:
	grabbed_box = box
	box.set_grabbed(true)

# Suelta la caja, si tenía una.
func release() -> void:
	if grabbed_box:
		grabbed_box.set_grabbed(false)
		grabbed_box = null

# El corazón del gato: se ejecuta cada frame de física.
func _physics_process(delta: float) -> void:
	# Mientras mantenés "interact" agarra la caja cercana (solo si está en el piso); al soltar, la suelta.
	if Input.is_action_pressed("interact"):
		if not grabbed_box and nearby_box and is_on_floor():
			grab(nearby_box)
	else:
		release()

	# Seguridad: si la caja queda muy lejos, se suelta
	if grabbed_box and global_position.distance_to(grabbed_box.global_position) > 120:
		release()

	# Gravedad en el aire; en el piso se resetean los saltos.
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		jump_count = 0
		is_double_jumping = false

	# Salto (y salto doble). Con una caja agarrada no se puede saltar.
	if Input.is_action_just_pressed("ui_accept") and jump_count < MAX_JUMPS and not grabbed_box:
		velocity.y = JUMP_VELOCITY
		jump_count += 1

		if jump_count == 2:
			is_double_jumping = true
			animationPlayer.play("Double Jump")

	# Movimiento horizontal: -1 izquierda, 1 derecha, 0 quieto. Si no tocás nada, frena.
	var direction := Input.get_axis("ui_left", "ui_right")
	var current_speed = GRAB_SPEED if grabbed_box else SPEED
	if direction:
		velocity.x = direction * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)

	# Guardamos la velocidad antes de moverse, porque move_and_slide la cambia al chocar (por ej. con la caja).
	var intended_x = velocity.x
	move_and_slide()

	# La caja agarrada se mueve a la misma velocidad que el gato.
	if grabbed_box:
		grabbed_box.linear_velocity.x = intended_x

	animations(direction)

	# Da vuelta el sprite según hacia dónde camina (con caja agarrada no se da vuelta).
	if not grabbed_box:
		if direction == 1:
			sprite2D.flip_h = false
		elif direction == -1:
			sprite2D.flip_h = true

# Elige qué animación reproducir según si está en el piso, caminando, saltando o cayendo.
func animations(direction):
	if is_on_floor():
		if direction == 0:
			animationPlayer.play("Idle")
		else:
			animationPlayer.play("Run")
	else:
		# Durante el salto doble dejamos terminar esa animación antes de pasar a otra.
		if is_double_jumping:
			if not animationPlayer.is_playing() or animationPlayer.current_animation != "Double Jump":
				is_double_jumping = false
		elif velocity.y < 0:
			animationPlayer.play("Jump")
		elif velocity.y > 0:
			animationPlayer.play("Fall")

#Esto lo escribio Emma, eliminar luego de integrar Wwise
# Las llama el AnimationPlayer en momentos puntuales de las animaciones para sonar pasos y salto.
func Sonido_pasos ():
	$Pasos.play()
func Sonido_salto ():
	$Salto.play()
