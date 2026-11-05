extends RigidBody2D

var normal_friction := 1.0
var normal_damp := 3.0

func _ready() -> void:
	# Copia el material para que cada caja tenga el suyo
	physics_material_override = physics_material_override.duplicate()
	normal_friction = physics_material_override.friction
	normal_damp = linear_damp
	
	$Area2D.body_entered.connect(_on_body_entered)
	$Area2D.body_exited.connect(_on_body_exited)

func set_grabbed(value: bool) -> void:
	linear_damp = 0.0 if value else normal_damp
	physics_material_override.friction = 0.0 if value else normal_friction

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("set_nearby_box"):
		body.set_nearby_box(self)

func _on_body_exited(body: Node2D) -> void:
	if body.has_method("clear_nearby_box"):
		body.clear_nearby_box(self)
