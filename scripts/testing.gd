extends Node2D

@export var cam: Camera2D

var current_pos: Vector2 = Vector2.ZERO

var item_placement: ItemPlacement
var mouse_origin_pos: Vector2
var moving_camera: bool
var positions: Array = [Vector2(), Vector2()]
var min_zoom = 4
var max_zoom = 16
var zoom_sensitivity = 10
var zoom_speed = 0.03
var events = {}
var last_drag_distance = 0

func _unhandled_input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			events[event.index] = event
		else:
			events.erase(event.index)

	elif event is InputEventScreenDrag:
		events[event.index] = event
		if events.size() == 1:
			var cam_move_speed: float = (max_zoom - cam.zoom.x + 1)/max_zoom * .25
			cam.position = lerp(cam.position, cam.position - event.relative, cam_move_speed)
		elif events.size() == 2:
			var drag_distance = events[0].position.distance_to(events[1].position)
			if abs(drag_distance - last_drag_distance) > zoom_sensitivity:
				var new_zoom = 1 + zoom_speed

				if drag_distance < last_drag_distance:
					new_zoom = (1 - zoom_speed)

				new_zoom = clamp(cam.zoom.x * new_zoom, min_zoom, max_zoom)
				cam.zoom = Vector2.ONE * new_zoom

				last_drag_distance = drag_distance

func _ready() -> void:
	for item in GameData.items.values():
		var item_instance: Node2D = item
		item_instance = GameData.strip_item_node(item_instance)
		add_child(item_instance)
		item_instance.position = current_pos
		current_pos += Vector2(0, 32)  # Adjust the Y position for the next item
		if current_pos.y > 240:  # Reset position if it exceeds a certain height
			current_pos.y = 0
			current_pos.x += 32  # Adjust the X position for the next column