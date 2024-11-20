extends Node2D
class_name InputHandler
enum INPUT_TYPE {
	CAMERA,
	PLACEMENT,
	DELETE
}

signal input_type_changed(change: INPUT_TYPE)
@export var cam: Camera2D
var item_placement: ItemPlacement

var current_input_type: INPUT_TYPE = INPUT_TYPE.CAMERA
var mouse_origin_pos: Vector2
var moving_camera: bool
var positions: Array = [Vector2(), Vector2()]

var min_zoom = 1
var max_zoom = 20
var zoom_sensitivity = 10
var zoom_speed = 0.03

func _on_item_placed(item: PlayerItemInfo) -> void:
	if item.quantity <= 0:
		get_node("/root/Main/CanvasLayer/UI").switch_tab(get_node("/root/Main/CanvasLayer/UI").UI_TAB.INVENTORY)
		disable_placing()

func enable_deleting() -> void:
	current_input_type = INPUT_TYPE.DELETE
	$ItemPlacement/GridLines.visible = true
	$ItemPlacement/GridLines.modulate = Color.RED

func disable_deleting() -> void:
	current_input_type = INPUT_TYPE.CAMERA
	$ItemPlacement/GridLines.visible = false

func enable_placing(inv_index: int) -> void:
	item_placement.inv_index = inv_index
	current_input_type = INPUT_TYPE.PLACEMENT
	input_type_changed.emit(current_input_type)
	$ItemPlacement/GridLines.visible = true
	$ItemPlacement/GridLines.modulate = Color.WHITE

func disable_placing() -> void:
	current_input_type = INPUT_TYPE.CAMERA
	input_type_changed.emit(current_input_type)
	$ItemPlacement/GridLines.visible = false	


var events = {}
var last_drag_distance = 0


# func _process(delta):
# 	if events.size() == 0:
# 		--cam.position = lerp(cam.position, , target_return_rate)

func _unhandled_input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			events[event.index] = event
		else:
			events.erase(event.index)

	if event is InputEventScreenDrag:
		events[event.index] = event
		if events.size() == 1:
			cam.position = lerp(cam.position, cam.position - event.relative, .16)
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
	item_placement = $ItemPlacement
	item_placement.item_placed.connect(_on_item_placed)