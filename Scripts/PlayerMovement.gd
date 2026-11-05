extends CharacterBody2D

const SPEED = 250.0
const JUMP_VELOCITY = -300.0
const MAX_JUMPS = 2

const GRAB_SPEED = 100.0

var nearby_box: RigidBody2D = null
var grabbed_box: RigidBody2D = null

@onready var animationPlayer = $AnimationPlayer
@onready var sprite2D = $Sprite2D

var jump_count = 0 
var is_double_jumping = false

func set_nearby_box(box: RigidBody2D) -> void:
	nearby_box = box

func clear_nearby_box(box: RigidBody2D) -> void:
	if nearby_box == box:
		nearby_box = null
		
func grab(box: RigidBody2D) -> void:
	grabbed_box = box
	box.set_grabbed(true)

func release() -> void:
	if grabbed_box:
		grabbed_box.set_grabbed(false)
		grabbed_box = null

func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("interact"):
		if not grabbed_box and nearby_box and is_on_floor():
			grab(nearby_box)
	else:
		release()
	
	# Seguridad: si la caja queda muy lejos, se suelta
	if grabbed_box and global_position.distance_to(grabbed_box.global_position) > 120:
		release()	
	
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		jump_count = 0
		is_double_jumping = false

	if Input.is_action_just_pressed("ui_accept") and jump_count < MAX_JUMPS and not grabbed_box:
		velocity.y = JUMP_VELOCITY
		jump_count += 1
		
		if jump_count == 2:
			is_double_jumping = true
			animationPlayer.play("Double Jump")

	var direction := Input.get_axis("ui_left", "ui_right")
	var current_speed = GRAB_SPEED if grabbed_box else SPEED
	if direction:
		velocity.x = direction * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)

	var intended_x = velocity.x
	move_and_slide()
	
	if grabbed_box:
		grabbed_box.linear_velocity.x = intended_x
	
	animations(direction)
	
	if not grabbed_box:
		if direction == 1:
			sprite2D.flip_h = false
		elif direction == -1:
			sprite2D.flip_h = true

func animations(direction):
	if is_on_floor():
		if direction == 0:
			animationPlayer.play("Idle")
		else:
			animationPlayer.play("Run")
	else:
		if is_double_jumping:
			if not animationPlayer.is_playing() or animationPlayer.current_animation != "Double Jump":
				is_double_jumping = false
		elif velocity.y < 0:
			animationPlayer.play("Jump")
		elif velocity.y > 0:
			animationPlayer.play("Fall")
