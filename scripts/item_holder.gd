class_name ItemHolder
extends Node2D

signal item_held

const HOLD_THRESHOLD: float = 0.05
@export var speed: float = 32

var direction: Vector2 = Vector2.from_angle(rotation)
var moving_item: bool = false
var items_held = []

func recieve_item(ore: Ore) -> void:
	ore.reparent(self, true)

func offload_items() -> Array:
	var ores: Array = items_held.duplicate()
	items_held.clear()
	return ores

func hold_item(ore: Ore) -> void:
	items_held.append(ore)
	item_held.emit(ore)

func _exit_tree() -> void:
	GameData.ore_count -= get_child_count()

func _physics_process(delta: float) -> void:
	for item in get_children():
		if item is Ore and not items_held.has(item):
			item.global_position = item.global_position.move_toward(global_position, speed * delta)
			if item.global_position.distance_to(global_position) <= HOLD_THRESHOLD:
				hold_item(item)