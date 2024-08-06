extends Node2D
@export var cam: Camera2D

var moving_camera: bool = false
var mouse_origin_pos: Vector2

func _input(event: InputEvent) -> void:
	if event.is_action("move_camera"):
		if event.is_pressed():
			mouse_origin_pos = get_global_mouse_position()
			moving_camera = true
		else:
			moving_camera = false
		

func _process(_delta: float) -> void:
	if moving_camera:
		var mouse_delta: Vector2 = get_global_mouse_position() - mouse_origin_pos
		cam.position = cam.position.lerp(cam.position-mouse_delta, 0.16)
