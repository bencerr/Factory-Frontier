extends Area2D
class_name Upgrader
@export var item_holder: ItemHolder
@export var detector: Detector
@export var multiplier: float
@export var item_data: ItemData

func process_item(item: Node2D) -> void:
	var ore_value: float = item.get_meta("value")
	item.set_meta("value", (ore_value * multiplier))
	item.queue_free()

func can_recieve_item() -> bool:
	return item_holder.get_child_count() == 0

func recieve_item(item: Node2D) -> void:
	print_debug("recieved item")
	item_holder.recieve_item(item)

func _on_detector_belt_detected(area: Area2D) -> void:
	var item = item_holder.offload_item()
	area.recieve_item(item)

func _on_item_holder_item_held() -> void:
	detector.detect()
