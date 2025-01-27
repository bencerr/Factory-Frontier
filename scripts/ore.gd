class_name Ore
extends Node2D

signal value_changed(change: float)
@export var value: float = 1:
	get:
		return value
	set(val):
		value = val
		value_changed.emit(val)

var upgrade_tags: Dictionary = {} # {tag_name: tag_count}
var statuses: Dictionary = {} # {status_name: StatusObject}
