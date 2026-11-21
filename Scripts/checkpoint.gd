extends Area2D
# Checkpoint: cuando el gato lo toca, se guarda esta posición para reaparecer acá al reiniciar.


func _ready() -> void:
	# Cuando algo entra al área, se llama a _on_body_entered.
	body_entered.connect(_on_body_entered)


# Si el que entró es el gato, le pasamos nuestra posición al GameManager.
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		GameManager.set_checkpoint(global_position)
