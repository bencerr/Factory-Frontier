extends Control

@export var name_label: Label
var placed_item_id: int

func update() -> void:
	var placed_item_data: PlacedItemData = Player.data.placed_items[placed_item_id]
	var item_info: PlayerItemInfo = Player.data.inventory[placed_item_data.item_index]
	name_label.text = GameData.items[item_info.item_id].item_data.name

func show_item_info(id: int, pos: Vector2):
	global_position = pos
	placed_item_id = id
	update()
	show()

func _on_close_pressed() -> void:
	hide()

func _on_rotate_pressed() -> void:
	Player.data.placed_items[placed_item_id].rotation += deg_to_rad(90)
	Player.data.placed_items[placed_item_id].instance.rotation = Player.data.placed_items[placed_item_id].rotation

