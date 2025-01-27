class_name WaterStatus
extends OreStatus

func do_effect() -> void:
	if not ore: return
	for st in self.ore.statuses.keys():
		if self.ore.statuses[st] is FireStatus:
			self.ore.statuses[st].remove_status()

func _init() -> void:
	super()
	do_effect()
