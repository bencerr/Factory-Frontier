class_name Detector
extends Area2D

signal belt_detected
var detecting: bool = false

func detect() -> void:
	detecting = true

func _physics_process(_delta: float) -> void:
	if not detecting:
		return

	var areas = get_overlapping_areas()

	areas = areas.filter(func(area: Area2D):
		return area != get_parent() and not area.get_parent() is Dropper
	)

	for area: Area2D in areas:
		belt_detected.emit(area)
		detecting = false
