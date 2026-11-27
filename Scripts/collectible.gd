extends Area2D
# Objeto coleccionable. Se identifica por su nombre de nodo (Collectible, Collectible2...),
# así que cada uno en el nivel tiene que tener un nombre distinto.


func _ready() -> void:
	# Si ya lo habías agarrado (por ejemplo, antes de reiniciar desde el checkpoint), desaparece.
	if GameManager.is_collected(name):
		queue_free()
		return
	body_entered.connect(_on_body_entered)


# Si lo toca el gato: se anota en el GameManager y el objeto se borra de la escena.
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		$Sonido_moneda.playing = true #Escrito por Emma momentaneamente
		GameManager.collect(name)
		await get_tree().create_timer(0.2).timeout #perdon! sigo con problemas
		# con Wwise, por eso meto mano aca! 
		queue_free()
