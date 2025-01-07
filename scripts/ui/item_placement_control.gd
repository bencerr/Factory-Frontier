extends Control

@export var name_label: Label
@export var quantity_label: Label
@export var texture_rect: TextureRect
var icon_viewport_node: Node2D

func update() -> void:
	var inv_index = get_node("/root/Main/InputHandler/ItemPlacement").inv_index
	var info: PlayerItemInfo = Player.data.inventory[inv_index]
	var item_node: Node2D = GameData.items[get_node("/root/Main/InputHandler/ItemPlacement").inv_index]
	name_label.text = item_node.item_data.name
	quantity_label.text = str(info.quantity)
	for c in $ItemImage/SubViewport.get_children():
		c.queue_free()
	icon_viewport_node = GameData.items[info.item_id].duplicate()
	icon_viewport_node = GameData.strip_item_node(icon_viewport_node)
	icon_viewport_node.position = get_node("ItemImage/SubViewport").size / 2
	get_node("Rotate").rotation = Player.item_rotation
	texture_rect.rotation = Player.item_rotation
	$ItemImage/SubViewport.add_child(icon_viewport_node)

func _on_item_placed(_item: PlayerItemInfo) -> void:
	update()

func _ready() -> void:
	get_node("/root/Main/InputHandler/ItemPlacement").item_placed.connect(_on_item_placed)

func _on_close_pressed() -> void:
	icon_viewport_node.queue_free()
	get_node("/root/Main/InputHandler").disable_placing()

func _on_rotate_pressed() -> void:
	Player.item_rotation += deg_to_rad(90)
	get_node("Rotate").rotation = Player.item_rotation
	texture_rect.rotation = Player.item_rotation
