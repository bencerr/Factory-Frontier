extends Area2D
class_name Upgrader
var item_holder: ItemHolder
var detector: Detector
@export var item_data: ItemData
@export var multiplier: float

func upgrade(ore: Ore) -> void:
	var ore_value: float = ore.value
	ore.value = (ore_value * multiplier)

func _ready() -> void:
	item_holder = $ItemHolder
	detector = $Detector
	$AnimatedSprite2D.play()
	var current_frame = get_node("/root/Main/ConveyorAnimationSync").get_frame()
	var current_progress = get_node("/root/Main/ConveyorAnimationSync").get_frame_progress()
	$AnimatedSprite2D.set_frame_and_progress(current_frame, current_progress)

func can_recieve_item() -> bool:
	return item_holder.get_child_count() == 0

func recieve_item(ore: Ore) -> void:
	item_holder.recieve_item(ore)

func _on_detector_belt_detected(area: Area2D) -> void:
	var ore = item_holder.offload_item()
	upgrade(ore)
	area.recieve_item(ore)

func _on_item_holder_item_held(_ore: Ore) -> void:
	detector.detect()
