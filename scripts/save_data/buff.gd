class_name Buff
extends Resource

@export var name: String = "";
@export var time_left: float = 0.0;
var buff_label_instance: Label

func _init(n: String = "2x", t: float = 0):
	self.name = n
	self.time_left = t