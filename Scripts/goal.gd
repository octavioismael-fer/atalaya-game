extends Area2D


func _ready() -> void:
		body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	print("Entró: ", body.name, " | grupos: ", body.get_groups())
	if body.is_in_group("player"):
		GameManager.level_completed()
