extends Sprite2D

var ore_processed_tween: Tween
var upgrader: Upgrader

func _on_ore_processed(_ore: Ore) -> void:
	if ore_processed_tween:
		if ore_processed_tween.is_running():
			return
		ore_processed_tween.kill()

	ore_processed_tween = create_tween()
	ore_processed_tween.tween_property(self, "scale", Vector2(1.2, 1), .2)
	ore_processed_tween.tween_property(self, "scale", Vector2(1, 1), .1)

	ore_processed_tween.play()

func _ready() -> void:
	upgrader = get_parent()
	upgrader.process_ore.connect(_on_ore_processed)