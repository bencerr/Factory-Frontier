extends Node2D
class_name InputHandler
enum INPUT_TYPE {
	CAMERA,
	PLACEMENT
}

signal input_type_changed(change: INPUT_TYPE)
@export var cam: Camera2D
var item_placement: ItemPlacement

var current_input_type: INPUT_TYPE = INPUT_TYPE.CAMERA
var mouse_origin_pos: Vector2
var moving_camera: bool

func _on_item_placed(item: ItemData) -> void:
	if item.quantity <= 0:
		Player.ui.switch_tab(Player.ui.UI_TAB.INVENTORY)
		disable_placing()

func enable_placing(inv_index: int) -> void:
	item_placement.inv_index = inv_index
	item_placement.enabled = true
	current_input_type = INPUT_TYPE.PLACEMENT
	input_type_changed.emit(current_input_type)

func disable_placing() -> void:
	$ItemPlacement.enabled = false
	current_input_type = INPUT_TYPE.CAMERA
	input_type_changed.emit(current_input_type)

func _input(event: InputEvent) -> void:
	if event.is_action("move_camera") && current_input_type == INPUT_TYPE.CAMERA:
		if event.is_pressed():
			mouse_origin_pos = get_global_mouse_position()
			moving_camera = true
		else:
			moving_camera = false

func _process(_delta: float) -> void:
	if moving_camera:
		var mouse_delta: Vector2 = get_global_mouse_position() - mouse_origin_pos
		cam.position = cam.position.lerp(cam.position-mouse_delta, 0.16)

func _ready() -> void:
	item_placement = $ItemPlacement
	item_placement.item_placed.connect(_on_item_placed)