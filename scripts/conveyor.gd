extends Area2D
class_name Conveyor
var item_holder: ItemHolder
var detector: Detector

func _ready() -> void:
	item_holder = $ItemHolder
	detector = $Detector
	$AnimatedSprite2D.play()

func can_recieve_item() -> bool:
	return item_holder.get_child_count() == 0

func recieve_item(item: Node2D) -> void:
	item_holder.recieve_item(item)

func _on_detector_belt_detected(area: Area2D) -> void:
	var item = item_holder.offload_item()
	area.recieve_item(item)

func _on_item_holder_item_held() -> void:
	detector.detect()