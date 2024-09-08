extends Node2D
class_name ItemPlacement
signal item_placed(item: ItemData)

@onready var tilemap: TileMap = get_node("/root/Main/TileMap")

var inv_index: int

func _unhandled_input(event: InputEvent) -> void:
	if Player.input_handler.current_input_type == InputHandler.INPUT_TYPE.CAMERA: return
	if Player.input_handler.current_input_type == InputHandler.INPUT_TYPE.PLACEMENT:
		if event is InputEventMouseButton and event.pressed:
			if event.button_index == MOUSE_BUTTON_LEFT:
				var mouse_pos: Vector2 = get_global_mouse_position()
				var tile_pos: Vector2i = tilemap.local_to_map(tilemap.to_local(mouse_pos))
				var item: ItemData = Player.data.inventory[inv_index]

				if item && item.quantity > 0 && Player.check_tile(tile_pos):
					var instance: Node = item.scene.instantiate()
					instance.position = tilemap.map_to_local(tile_pos)
					instance.rotation = Player.item_rotation
					get_node("/root/Main/PlacedItems").add_child(instance)
					item.quantity -= 1
					Player.update_inventory_item(Player.get_item_index(item.item_name), item)

					var pid: PlacedItemData = PlacedItemData.new()
					pid.item_index = item.id
					pid.rotation = Player.item_rotation
					pid.position = tile_pos
					pid.instance = instance
					Player.data.placed_items.append(pid)
					item_placed.emit(item)

	elif Player.input_handler.current_input_type == InputHandler.INPUT_TYPE.DELETE:
		if event is InputEventMouseButton and event.pressed:
			if event.button_index == MOUSE_BUTTON_LEFT:
				var mouse_pos: Vector2 = get_global_mouse_position()
				var tile_pos: Vector2i = tilemap.local_to_map(tilemap.to_local(mouse_pos))
				var id: int = Player.get_placed_item_id(tile_pos)

				if id == -1: return

				var placed_item_data: PlacedItemData = Player.data.placed_items[id]
				var item: ItemData = Player.data.inventory[placed_item_data.item_index]
				item.quantity += 1
				Player.update_inventory_item(Player.get_item_index(item.item_name), item)
				Player.data.placed_items[id].instance.queue_free()
				Player.data.placed_items.remove_at(id)
				