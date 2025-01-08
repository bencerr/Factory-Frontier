extends AnimatedSprite2D

func _ready() -> void:
	var animation_sync_conveyor: AnimatedSprite2D = get_node("/root/Main/ConveyorAnimationSync")

	set_frame_and_progress(
		animation_sync_conveyor.get_frame(),
		animation_sync_conveyor.get_frame_progress())

	play()
