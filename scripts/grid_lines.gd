extends Node2D
class_name GridLines

# Color of the grid lines
@export var grid_color = Color(0.8, 0.8, 0.8, 0.5)

func _draw():
    var viewport_size = get_viewport().size
    var width = viewport_size.x
    var height = viewport_size.y
    
    # Draw vertical lines
    for x in range(0, width, GameData.grid_size):
        draw_line(Vector2(x, 0), Vector2(x, height), grid_color)
    
    # Draw horizontal lines
    for y in range(0, height, GameData.grid_size):
        draw_line(Vector2(0, y), Vector2(width, y), grid_color)
