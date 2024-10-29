extends Area2D
class_name Detector

signal belt_detected
var detecting: bool = false

func detect() -> void:
	detecting = true

func _physics_process(_delta: float) -> void:
	if not detecting:
		return
	var areas = get_overlapping_areas()

	areas = areas.filter(func(area: Area2D): 
		return area != get_parent()
	)

	if len(areas) == 1:
		var area: Area2D = areas[0]
		belt_detected.emit(area)
		detecting = false
