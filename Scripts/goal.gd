extends Area2D
# La meta (punto B). Cuando el gato la toca, le avisa al GameManager para ver si terminó el nivel.


func _ready() -> void:
	# Cuando algo entra al área, se llama a _on_body_entered.
	body_entered.connect(_on_body_entered)


# Si el que entró es el gato, intentamos terminar el nivel (el GameManager chequea los objetos).
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		GameManager.level_completed()
