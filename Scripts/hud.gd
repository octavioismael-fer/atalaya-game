extends CanvasLayer
# HUD: el contador de objetos "X/3" que se ve arriba a la izquierda, fijo en pantalla.

@onready var label: Label = $CollectiblesLabel

func _ready() -> void:
	# Nos suscribimos al aviso del GameManager: cada vez que cambian los objetos, se actualiza el texto.
	GameManager.collectibles_changed.connect(_on_collectibles_changed)
	# Al arrancar leemos el valor actual a mano, porque el aviso pudo llegar antes de que existiera el HUD.
	_on_collectibles_changed(GameManager.collected.size(), GameManager.REQUIRED_COLLECTIBLES)

# Escribe el contador en el Label, por ejemplo "2/3".
func _on_collectibles_changed(count: int, total: int) -> void:
	label.text = "%d/%d" % [count, total]
