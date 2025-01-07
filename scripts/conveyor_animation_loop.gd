extends AnimatedSprite2D

func _ready() -> void:
	play()

	var animation_sync_conveyor = get_node("/root/Main/ConveyorAnimationSync")
	var current_frame = animation_sync_conveyor.get_frame()
	var current_progress = animation_sync_conveyor.get_frame_progress()

	set_frame_and_progress(current_frame, current_progress)