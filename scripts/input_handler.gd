class_name InputHandler
extends Node2D

signal input_type_changed(change: INPUTTYPE)

enum INPUTTYPE {
	CAMERA,
	PLACEMENT,
	DELETE
}

@export var cam: Camera2D
@export var enabled: bool = true

var item_placement: ItemPlacement
var current_input_type: INPUTTYPE = INPUTTYPE.CAMERA
var mouse_origin_pos: Vector2
var moving_camera: bool
var positions: Array = [Vector2(), Vector2()]
var min_zoom = 4
var max_zoom = 16
var zoom_sensitivity = 10
var zoom_speed = 0.03
var events = {}
var last_drag_distance = 0

func _on_item_placed(item: PlayerItemInfo) -> void:
	if item.quantity <= 0:
		get_node("/root/Main/CanvasLayer/UI").switch_tab(
			MainInterface.UITAB.INVENTORY
		)
		disable_placing()

func enable_deleting() -> void:
	current_input_type = INPUTTYPE.DELETE
	$ItemPlacement/GridLines.visible = true
	$ItemPlacement/GridLines.modulate = Color.RED

func disable_deleting() -> void:
	current_input_type = INPUTTYPE.CAMERA
	$ItemPlacement/GridLines.visible = false

func enable_placing(inv_index: int) -> void:
	item_placement.inv_index = inv_index
	current_input_type = INPUTTYPE.PLACEMENT
	input_type_changed.emit(current_input_type)
	$ItemPlacement/GridLines.visible = true
	$ItemPlacement/GridLines.modulate = Color.WHITE

func disable_placing() -> void:
	current_input_type = INPUTTYPE.CAMERA
	input_type_changed.emit(current_input_type)
	$ItemPlacement/GridLines.visible = false

func _unhandled_input(event):
	if not enabled: return
	if event is InputEventScreenTouch:
		if event.pressed:
			events[event.index] = event
		else:
			events.erase(event.index)

	if event is InputEventScreenDrag:
		events[event.index] = event
		if events.size() == 1:
			var cam_move_speed: float = (max_zoom - cam.zoom.x + 1)/max_zoom * .25
			cam.position = lerp(cam.position, cam.position - event.relative, cam_move_speed).clamp(
			Vector2(-GameData.cam_max_size, -GameData.cam_max_size),
			Vector2(GameData.cam_max_size, GameData.cam_max_size))
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