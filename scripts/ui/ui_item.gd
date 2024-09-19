extends Control
class_name UI_Item

var item_id: int

func update() -> void:
	var data: ItemData = GameData.items[item_id].item_data
	var info: PlayerItemInfo = Player.data.inventory[item_id]
	$TextureRect.texture = data.icon
	$QuantityLabel.text = str(info.quantity)
	if info.quantity <= 0:
		visible = false

func _ready() -> void:
	update()
	Player.inventory_changed.connect(_on_inventory_changed)

func _on_inventory_changed(id: int) -> void:
	if id == item_id:
		update()

func _on_texture_button_pressed() -> void:
	var input_handler: InputHandler = Player.input_handler
	input_handler.enable_placing(item_id)
	Player.ui.switch_tab(Player.ui.UI_TAB.NONE)
