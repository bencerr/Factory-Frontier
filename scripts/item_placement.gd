extends Node2D
class_name ItemPlacement
# PackedScene to instance
@export var scene_to_place : PackedScene
@onready var tilemap: TileMap = get_node("/root/Main/TileMap")
var enabled: bool = false

func _input(event):
	if not enabled: return
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			var mouse_pos: Vector2 = get_global_mouse_position()
			var tile_pos: Vector2i = tilemap.local_to_map(mouse_pos)

			if scene_to_place:
				var instance: Node = scene_to_place.instantiate()
				instance.position = tilemap.map_to_local(tile_pos)
				$PlacedItems.add_child(instance)
