extends Control
class_name Shop_UI_Item

var item_id: int

func _ready() -> void:
	var data: ItemData = GameData.items[item_id].item_data
	Player.ui.shop_selected_item_changed.connect(_on_shop_changed)
	$TextureRect.texture = data.icon
	$Price.text = "$" + str(data.price)

func _on_shop_changed(id: int) -> void:
	var stylebox: StyleBoxFlat = $Panel.get_theme_stylebox("panel").duplicate()
	if id != item_id:
		stylebox.bg_color = Color(0.349, 0.333, 0.349)
		$Panel.add_theme_stylebox_override("panel", stylebox)
	else:
		stylebox.bg_color = Color(0.349, 0.333, 0.349).lightened(.2)
		$Panel.add_theme_stylebox_override("panel", stylebox)

func _on_texture_button_pressed() -> void:
	Player.ui.shop_selected_item_changed.emit(item_id)
