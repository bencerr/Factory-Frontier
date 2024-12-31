class_name ItemHolder
extends Node2D

signal item_held

@export var speed: float = 16

var direction: Vector2 = Vector2.from_angle(rotation)
var moving_item: bool = false

func recieve_item(ore: Ore) -> void:
	ore.reparent(self, true)

func offload_item() -> Ore:
	return get_child(0)

func hold_item(ore: Ore) -> void:
	item_held.emit(ore)

func _physics_process(delta: float) -> void:
	for item in get_children():
		if item is Ore:
			item.global_position = item.global_position.move_toward(global_position, speed * delta)
			if item.global_position.distance_to(global_position) < 1.0:
				hold_item(item)