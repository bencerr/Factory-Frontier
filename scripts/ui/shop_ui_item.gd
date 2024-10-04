extends Control
class_name Shop_UI_Item

var item_id: int

func _ready() -> void:
	var data: ItemData = GameData.items[item_id].item_data
	$TextureRect.texture = data.icon
	$Price.text = "$" + str(data.price)

func _on_texture_button_pressed() -> void:
	var data: ItemData = GameData.items[item_id].item_data
	if Player.data.money >= data.price:
		var item_updated = Player.data.inventory[item_id]
		item_updated.quantity += 1
		Player.update_inventory_item(item_id, item_updated)
		Player.data.money -= data.price