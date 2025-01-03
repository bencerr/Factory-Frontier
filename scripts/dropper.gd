class_name Dropper
extends Node2D

@export var ore_scene: PackedScene
@export var item_data: ItemData
var drop_tween: Tween

func drop_vfx() -> void:
	if drop_tween:
		drop_tween.kill()
	drop_tween = create_tween()

	var orginal_scale: Vector2 = self.scale
	drop_tween.tween_property(self, "scale", Vector2(.8, .8), .18)
	drop_tween.tween_property(self, "scale", orginal_scale, .2)

	drop_tween.play()

func _on_timer_timeout() -> void:
	$Detector.detect()

func _on_detector_belt_detected(destination: Area2D) -> void:
	if destination.get_parent() is Dropper: return
	var drop_item: Node2D = ore_scene.instantiate()
	$Hold.add_child(drop_item)
	drop_item.global_position = $Hold.global_position
	drop_item.get_node("Sprite2D").rotation = randf_range(0.0, PI*2)
	destination.recieve_item(drop_item)
	drop_vfx()
	$Timer.start()
