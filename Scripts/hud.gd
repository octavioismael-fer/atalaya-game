extends CanvasLayer

@onready var label: Label = $CollectiblesLabel

func _ready() -> void:
		GameManager.collectibles_changed.connect(_on_collectibles_changed)
		_on_collectibles_changed(GameManager.collected.size(), GameManager.REQUIRED_COLLECTIBLES)

func _on_collectibles_changed(count: int, total: int) -> void:
		label.text = "%d/%d" % [count, total]
