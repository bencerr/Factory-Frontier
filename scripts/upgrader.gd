class_name Upgrader
extends Area2D

signal process_ore(ore: Ore)

@export var item_data: ItemData
@export var multiplier: float
@export_range(0,1) var destroy_chance: float = 0
@export var upgrade_limit: int = 1

var item_holder: ItemHolder
var detector: Detector
var default_rotation: float

var shake_tween: Tween
func shake_vfx() -> void:
	if shake_tween:
		if shake_tween.is_running(): shake_tween.stop()
		shake_tween.kill()
	shake_tween = self.create_tween()
	var shake = 5
	var shake_duration = 0.1

	shake_tween.tween_property(self, "rotation", -deg_to_rad(shake), shake_duration)
	shake_tween.tween_property(self, "rotation", deg_to_rad(shake), shake_duration)
	shake_tween.tween_property(self, "rotation", default_rotation, shake_duration)

func upgrade(ore: Ore) -> void:
	if ore.upgrade_tags.has(item_data.name):
		if ore.upgrade_tags[item_data.name] >= upgrade_limit:
			shake_vfx()
			return
		ore.upgrade_tags[item_data.name] += 1
	else:
		ore.upgrade_tags[item_data.name] = 1
	var ore_value: float = ore.value
	ore.value = (ore_value * multiplier)
	process_ore.emit(ore)

func _ready() -> void:
	item_holder = $ItemHolder
	detector = $Detector
	default_rotation = rotation

func can_recieve_item() -> bool:
	return item_holder.get_child_count() == 0

func recieve_item(ore: Ore) -> void:
	item_holder.recieve_item(ore)

func _on_detector_belt_detected(area: Area2D) -> void:
	var ore = item_holder.offload_item()
	upgrade(ore)
	if randf() < destroy_chance:
		GameData.ore_count -= 1
		ore.free()
		return
	area.recieve_item(ore)

func _on_item_holder_item_held(_ore: Ore) -> void:
	detector.detect()
