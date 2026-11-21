extends RigidBody2D
# Caja empujable/agarrable. Tiene un Area2D alrededor para saber si el gato está cerca.

var normal_friction := 1.0   # Fricción cuando nadie la agarra
var normal_damp := 3.0       # "Freno" cuando nadie la agarra

func _ready() -> void:
	# Copia el material para que cada caja tenga el suyo
	physics_material_override = physics_material_override.duplicate()
	# Guardamos los valores originales para poder volver a ellos al soltarla
	normal_friction = physics_material_override.friction
	normal_damp = linear_damp

	# Avisos de cuando el gato entra o sale de la zona de agarre
	$Area2D.body_entered.connect(_on_body_entered)
	$Area2D.body_exited.connect(_on_body_exited)

# Agarrada: sin fricción ni freno, así se desliza junto al gato. Suelta: vuelve a lo normal.
func set_grabbed(value: bool) -> void:
	linear_damp = 0.0 if value else normal_damp
	physics_material_override.friction = 0.0 if value else normal_friction

# El gato se acercó: le avisamos que tiene esta caja a mano.
func _on_body_entered(body: Node2D) -> void:
	if body.has_method("set_nearby_box"):
		body.set_nearby_box(self)

# El gato se alejó: le avisamos que ya no la tiene cerca.
func _on_body_exited(body: Node2D) -> void:
	if body.has_method("clear_nearby_box"):
		body.clear_nearby_box(self)
