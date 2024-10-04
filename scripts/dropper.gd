extends Node2D
class_name Dropper

@export var sprite: Resource
@export var item_data: ItemData

func _on_timer_timeout() -> void:
	$Detector.detect()

func _on_detector_belt_detected(destination: Area2D) -> void:
	var drop_item: Node2D = sprite.instantiate()
	drop_item.position = $Hold.global_position
	drop_item.get_node("Sprite2D").rotation = randf_range(0.0, PI*2)
	$Hold.add_child(drop_item)
	destination.recieve_item(drop_item)
	$Timer.start()
