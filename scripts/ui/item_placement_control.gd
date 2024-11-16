extends Control

@export var name_label: Label
@export var quantity_label: Label
var icon_viewport_node: Node2D

func update() -> void:
	var info: PlayerItemInfo = Player.data.inventory[get_node("/root/Main/InputHandler/ItemPlacement").inv_index]
	var item_node: Node2D = GameData.items[get_node("/root/Main/InputHandler/ItemPlacement").inv_index]
	name_label.text = item_node.item_data.item_name
	quantity_label.text = str(info.quantity)
	icon_viewport_node = GameData.items[info.item_id].duplicate()
	icon_viewport_node = GameData.strip_item_node(icon_viewport_node)
	icon_viewport_node.position = Vector2(16,16)
	$ItemImage/SubViewport.add_child(icon_viewport_node)

func _on_item_placed(_item: PlayerItemInfo) -> void:
	update()

func _ready() -> void:
	get_node("/root/Main/InputHandler/ItemPlacement").item_placed.connect(_on_item_placed)

func _on_rotate_button_pressed() -> void:
	icon_viewport_node.rotation += deg_to_rad(90)
	Player.item_rotation = icon_viewport_node.rotation

func _on_exit_button_pressed() -> void:
	icon_viewport_node.queue_free()
	get_node("/root/Main/InputHandler").disable_placing()
