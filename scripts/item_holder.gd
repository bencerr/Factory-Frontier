extends Node2D
class_name ItemHolder

signal item_held
var direction: Vector2 = Vector2.from_angle(rotation)
var speed: float = 16
var moving_item: bool = false

func recieve_item(item: Node2D) -> void:
	item.reparent(self, true)
	moving_item = true

func offload_item() -> Node2D:
	var item = get_child(0)
	return item

func hold_item() -> void:
	item_held.emit()
	moving_item = false

func _physics_process(delta: float) -> void:
	if not moving_item or get_child_count() == 0:
		return

	var item = get_child(0)
	
	if item is Node2D:
		item.global_position = item.global_position.move_toward(global_position, speed * delta)
		if item.global_position.distance_to(global_position) < 1.0:
			hold_item()