class_name ValueDisplayer
extends Area2D

@export var item_data: ItemData
@export var value_display_ui: PackedScene

var item_holder: ItemHolder
var detector: Detector

func display_ore_data(ore: Ore) -> void:
	var lbl: Label = value_display_ui.instantiate()
	lbl.position.y -= 10
	lbl.text = GameData.float_to_prefix(ore.value)
	ore.value_changed.connect(_update_ore_value_display.bind(lbl))
	ore.add_child(lbl)

func _update_ore_value_display(value: float, lbl: Label) -> void:
	lbl.text = GameData.float_to_prefix(value)

func _ready() -> void:
	item_holder = $ItemHolder
	detector = $Detector

func can_recieve_item() -> bool:
	return item_holder.get_child_count() == 0

func recieve_item(ore: Ore) -> void:
	item_holder.recieve_item(ore)

func _on_detector_belt_detected(area: Area2D) -> void:
	var ore = item_holder.offload_item()
	display_ore_data(ore)
	area.recieve_item(ore)

func _on_item_holder_item_held(_ore: Ore) -> void:
	detector.detect()
