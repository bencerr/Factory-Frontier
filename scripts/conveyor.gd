class_name Conveyor
extends Area2D

@export var item_data: ItemData

var item_holder: ItemHolder
var detector: Detector

func _ready() -> void:
	item_holder = $ItemHolder
	detector = $Detector

func can_recieve_item() -> bool:
	return true

func recieve_item(item: Node2D) -> void:
	item_holder.recieve_item(item)

# Area is the next conveyor/furance/upgrader
# this is emitted from the previous conveyor's detector
func _on_detector_belt_detected(area: Area2D) -> void:
	var item = item_holder.offload_item()
	area.recieve_item(item)

func _on_item_holder_item_held(_ore: Ore) -> void:
	detector.detect()
