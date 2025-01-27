class_name OreStatus
extends Node

@export var status_name: String;
var ore: Ore;
var vfx: Array;

func remove_status() -> void:
	for effect in vfx:
		effect.free()
	ore.statuses.erase(self)
	self.queue_free()

func _init() -> void:
	self.ore = get_parent()
	self.vfx = []
