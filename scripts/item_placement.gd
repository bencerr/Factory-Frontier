class_name ItemPlacement
extends Node2D
signal item_placed(item: PlayerItemInfo)

var inv_index: int

@onready var tilemap: TileMap = get_node("/root/Main/TileMap")
@onready var place_particles_scene = preload("res://scenes/particles/place_particles.tscn")
@onready var item_selection_ui: Control

# returns the item index of the placed item at the given tile position (and deletes node)
func delete_item(pos: Vector2) -> int:
	var tile_pos: Vector2i = tilemap.local_to_map(tilemap.to_local(pos))
	var id: int = Player.get_placed_item_id(tile_pos)
	if id == -1: return -1

	var placed_item_data: PlacedItemData = Player.data.placed_items[id]
	var item_info: PlayerItemInfo = Player.data.inventory[placed_item_data.item_index]
	item_info.quantity += 1
	Player.update_inventory_item(placed_item_data.item_index, item_info)
	var inst = Player.data.placed_items[id].instance
	var t = inst.create_tween().set_trans(Tween.TRANS_QUAD)
	t.tween_property(inst, "scale", Vector2(.01, .01), .08)
	t.tween_callback(func():
		inst.queue_free()
		Player.data.placed_items.remove_at(id))

	return placed_item_data.item_index


func _ready() -> void:
	item_selection_ui = get_node("/root/Main/CanvasLayer/ItemSelectionControl")

func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventMouseButton and event.pressed): return
	if event.button_index != MOUSE_BUTTON_LEFT: return

	match get_node("/root/Main/InputHandler").current_input_type:
		InputHandler.INPUTTYPE.CAMERA:
			var mouse_pos: Vector2 = get_global_mouse_position()
			var tile_pos: Vector2i = tilemap.local_to_map(tilemap.to_local(mouse_pos))
			var id: int = Player.get_placed_item_id(tile_pos)

			if (item_selection_ui.visible): item_selection_ui.hide()
			if id == -1: return

			item_selection_ui.show_item_info(id)
			return
		InputHandler.INPUTTYPE.PLACEMENT:
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
				var t = instance.create_tween().set_trans(Tween.TRANS_QUAD)
				t.tween_property(instance, "scale", Vector2(.875,.875), .125)
				t.tween_property(instance, "scale", Vector2(1, 1), .125)

				item_info.quantity -= 1
				Player.update_inventory_item(inv_index, item_info)

				var pid: PlacedItemData = PlacedItemData.new()
				pid.item_index = item_info.item_id
				pid.rotation = Player.item_rotation
				pid.position = tile_pos
				pid.instance = instance

				var particles: CPUParticles2D = place_particles_scene.instantiate()
				get_node("/root/Main").add_child(particles)
				particles.position = tilemap.map_to_local(tile_pos)
				particles.emitting = true
				particles.finished.connect(particles.queue_free)

				Player.data.placed_items.append(pid)
				item_placed.emit(item_info)
		InputHandler.INPUTTYPE.DELETE:
			var mouse_pos: Vector2 = get_global_mouse_position()
			delete_item(mouse_pos)
