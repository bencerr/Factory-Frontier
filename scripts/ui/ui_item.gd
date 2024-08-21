extends Control
class_name UI_Item

var item_name: String

func update() -> void:
	var data: ItemData = Player.get_item_by_name(item_name)
	$TextureRect.texture = data.texture
	$QuantityLabel.text = str(data.quantity)
	if data.quantity <= 0:
		visible = false

func _ready() -> void:
	update()
	Player.inventory_changed.connect(_on_inventory_changed)

func _on_inventory_changed(id: int) -> void:
	if id == Player.get_item_index(item_name):
		update()

func _on_texture_button_pressed() -> void:
	var input_handler: InputHandler = Player.input_handler
	input_handler.enable_placing(Player.get_item_index(item_name))
	Player.ui.switch_tab(Player.ui.UI_TAB.NONE)
