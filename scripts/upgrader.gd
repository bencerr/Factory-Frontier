class_name Upgrader
extends Area2D

signal process_ore(ore: Ore)

@export var item_data: ItemData
@export var multiplier: float
@export_range(0,1) var destroy_chance: float = 0
@export var upgrade_limit: int = 1
@export var status: PackedScene

var status_template: OreStatus
var item_holder: ItemHolder
var detector: Detector
var default_rotation: float
var shake_tween: Tween
var shaking: bool = false

func shake_vfx() -> void:
	if shaking and shake_tween:
		if shake_tween.is_running():
			return
		shake_tween.kill()

	shaking = true
	var shake = 5
	shake_tween = self.create_tween()

	shake_tween.tween_property(self, "rotation", default_rotation - deg_to_rad(shake), .1)
	shake_tween.tween_property(self, "rotation", default_rotation + deg_to_rad(shake), .09)
	shake_tween.tween_property(self, "rotation", default_rotation, .08)
	shake_tween.finished.connect(func():
		shaking = false
	)

func upgrade(ore: Ore) -> void:
	if ore.upgrade_tags.has(item_data.name):
		if ore.upgrade_tags[item_data.name] >= upgrade_limit:
			shake_vfx()
			return
		ore.upgrade_tags[item_data.name] += 1
	else:
		ore.upgrade_tags[item_data.name] = 1

	var ore_has_status = false

	for ore_status in ore.statuses.keys():
		if ore_status == status_template.status_name:
			ore_has_status = true

	if status and not ore_has_status:
		var clone = status.instantiate()
		ore.statuses[clone.status_name] = clone
		ore.add_child(clone)
		clone._init()
		if clone.has_method("do_vfx"):
			clone.do_vfx()

	var ore_value: float = ore.value
	ore.value = (ore_value * multiplier)
	process_ore.emit(ore)

func _ready() -> void:
	item_holder = $ItemHolder
	detector = $Detector
	default_rotation = rotation
	status_template = status.instantiate()

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
