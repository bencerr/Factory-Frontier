class_name GridLines
extends Node2D

# Color of the grid lines
@export var grid_color = Color(0.8, 0.8, 0.8, 0.5)

func _draw():
	var w: int = 1600
	var h: int = 1600

	# Draw vertical lines
	for x in range(-h, h, GameData.GRID_SIZE):
		draw_line(Vector2(x, -h), Vector2(x, h), grid_color)

	# Draw horizontal lines
	for y in range(-w, w, GameData.GRID_SIZE):
		draw_line(Vector2(-w, y), Vector2(w, y), grid_color)
