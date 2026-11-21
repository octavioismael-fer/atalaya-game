extends Area2D


func _ready() -> void:
	if GameManager.is_collected(name):
		queue_free()
		return
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
		if body.is_in_group("player"):
				GameManager.collect(name)
				queue_free()
