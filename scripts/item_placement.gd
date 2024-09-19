extends Node2D
class_name ItemPlacement
signal item_placed(item: PlayerItemInfo)

@onready var tilemap: TileMap = get_node("/root/Main/TileMap")

var inv_index: int

func _unhandled_input(event: InputEvent) -> void:
	if Player.input_handler.current_input_type == InputHandler.INPUT_TYPE.CAMERA: return
	if Player.input_handler.current_input_type == InputHandler.INPUT_TYPE.PLACEMENT:
		if event is InputEventMouseButton and event.pressed:
			if event.button_index == MOUSE_BUTTON_LEFT:
				var mouse_pos: Vector2 = get_global_mouse_position()
				var tile_pos: Vector2i = tilemap.local_to_map(tilemap.to_local(mouse_pos))
				var item_info: PlayerItemInfo = Player.data.inventory[inv_index]
				var item: Node2D = GameData.items[inv_index]

				# tile_data for checking if placing inside bounds
				var tile_data: TileData = tilemap.get_cell_tile_data(1, tile_pos)
				
				if item_info && item && item_info.quantity > 0 && Player.check_tile(tile_pos) && tile_data:
					var instance: Node = item.duplicate()
					instance.position = tilemap.map_to_local(tile_pos)
					instance.rotation = Player.item_rotation
					get_node("/root/Main/PlacedItems").add_child(instance)
					item_info.quantity -= 1
					Player.update_inventory_item(inv_index, item_info)

					var pid: PlacedItemData = PlacedItemData.new()
					pid.item_index = item_info.item_id
					pid.rotation = Player.item_rotation
					pid.position = tile_pos
					pid.instance = instance
					Player.data.placed_items.append(pid)
					item_placed.emit(item_info)

	elif Player.input_handler.current_input_type == InputHandler.INPUT_TYPE.DELETE:
		if event is InputEventMouseButton and event.pressed:
			if event.button_index == MOUSE_BUTTON_LEFT:
				var mouse_pos: Vector2 = get_global_mouse_position()
				var tile_pos: Vector2i = tilemap.local_to_map(tilemap.to_local(mouse_pos))
				var id: int = Player.get_placed_item_id(tile_pos)
				
				if id == -1: return

				var placed_item_data: PlacedItemData = Player.data.placed_items[id]
				var item_info: PlayerItemInfo = Player.data.inventory[placed_item_data.item_index]
				item_info.quantity += 1
				Player.update_inventory_item(placed_item_data.item_index, item_info)
				Player.data.placed_items[id].instance.queue_free()
				Player.data.placed_items.remove_at(id)
				