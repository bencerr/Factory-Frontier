class_name Ore
extends Node2D

signal value_changed(change: float)
@export var value: float = 1:
	get:
		return value
	set(val):
		value = val
		value_changed.emit(val)

@export var upgrade_tags: Array[String] = []