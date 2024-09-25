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
	for area in areas:
		if area.can_recieve_item():
			#print(self.get_parent().name + " -> " + area.name)
			belt_detected.emit(area)
			detecting = false
			break
