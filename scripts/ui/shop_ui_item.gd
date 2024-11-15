extends Control
class_name Shop_UI_Item

var item_id: int
var default_style: StyleBoxFlat
var selected_style: StyleBoxFlat

func _ready() -> void:
	var data: ItemData = GameData.items[item_id].item_data
	get_node("/root/Main/CanvasLayer/UI").shop_selected_item_changed.connect(_on_shop_changed)
	$TextureRect.texture = data.icon
	$Price.text = "$" + str(data.price)
	$ItemName.text = str(data.item_name)
	default_style = $Panel.get_theme_stylebox("panel").duplicate()
	selected_style = $Panel.get_theme_stylebox("panel").duplicate()
	selected_style.bg_color = selected_style.bg_color.lightened(.2)
	

func _on_shop_changed(id: int) -> void:
	if id != item_id:
		$Panel.add_theme_stylebox_override("panel", default_style)
	else:
		$Panel.add_theme_stylebox_override("panel", selected_style)

func _on_texture_button_pressed() -> void:
	get_node("/root/Main/CanvasLayer/UI").shop_selected_item_changed.emit(item_id)
