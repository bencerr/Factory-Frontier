extends Node2D
class_name ItemHolder

signal item_held
var direction: Vector2 = Vector2.from_angle(rotation)
@export var speed: float = 16
var moving_item: bool = false

func recieve_item(ore: Ore) -> void:
	ore.reparent(self, true)
	moving_item = true

func offload_item() -> Ore:
	return get_child(0)

func hold_item(ore: Ore) -> void:
	item_held.emit(ore)
	moving_item = false

func _physics_process(delta: float) -> void:
	if not moving_item or get_child_count() == 0:
		return

	for item in get_children():
		if item is Ore:
			item.position = item.global_position.move_toward(global_position, speed * delta)
			if item.global_position.distance_to(global_position) < 1.0:
				hold_item(item)