extends Node2D
class_name ItemPlacement
signal item_placed(item: ItemData)

@onready var tilemap: TileMap = get_node("/root/Main/TileMap")

var inv_index: int
var enabled: bool = false

func _input(event):
	if not enabled: return
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			var mouse_pos: Vector2 = get_global_mouse_position()
			var tile_pos: Vector2i = tilemap.local_to_map(mouse_pos)
			var item: ItemData = Player.data.inventory[inv_index]

			if item && item.quantity > 0:
				var instance: Node = item.scene.instantiate()
				instance.position = tilemap.map_to_local(tile_pos)
				$PlacedItems.add_child(instance)
				item.quantity -= 1
				Player.update_inventory_item(Player.get_item_index(item.item_name), item)
				item_placed.emit(item)

