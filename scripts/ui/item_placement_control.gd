extends Control

@export var name_label: Label
@export var quantity_label: Label
@export var item_image: TextureRect

func update() -> void:
	var info: PlayerItemInfo = Player.data.inventory[get_node("/root/Main/InputHandler/ItemPlacement").inv_index]
	var item_node: Node2D = GameData.items[get_node("/root/Main/InputHandler/ItemPlacement").inv_index]
	name_label.text = item_node.item_data.item_name
	quantity_label.text = str(info.quantity)
	item_image.texture = item_node.item_data.icon

func _on_item_placed(_item: PlayerItemInfo) -> void:
	update()

func _ready() -> void:
	get_node("/root/Main/InputHandler/ItemPlacement").item_placed.connect(_on_item_placed)

func _on_rotate_button_pressed() -> void:
	item_image.rotation -= PI/2
	Player.item_rotation = item_image.rotation

func _on_exit_button_pressed() -> void:
	get_node("/root/Main/InputHandler").disable_placing()
