class_name UIItem
extends Control

var item_id: int

func update() -> void:
	var data: ItemData = GameData.items[item_id].item_data
	var info: PlayerItemInfo = Player.data.inventory[item_id]
	$QuantityLabel.text = "x" + str(info.quantity)
	$ItemName.text = data.name

	if info.quantity <= 0 or get_node("/root/Main/CanvasLayer/UI").inv_filter != data.item_type:
		visible = false
	else:
		visible = true

func _ready() -> void:
	update()
	var node = GameData.items[item_id].duplicate()
	node.position = Vector2(16,16)
	node = GameData.strip_item_node(node)
	$TextureRect/SubViewport.add_child(node)
	Player.inventory_changed.connect(_on_inventory_changed)

func _on_inventory_changed(id: int) -> void:
	if id == item_id:
		update()

func _on_texture_button_pressed() -> void:
	var input_handler: InputHandler = get_node("/root/Main/InputHandler")
	input_handler.enable_placing(item_id)
	get_node("/root/Main/CanvasLayer/UI").switch_tab(MainInterface.UITAB.NONE)
