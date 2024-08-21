extends Control

@export var name_label: Label
@export var quantity_label: Label
@export var item_image: TextureRect

func update() -> void:
	var data: ItemData = Player.data.inventory[Player.item_placement.inv_index]
	name_label.text = data.item_name
	quantity_label.text = str(data.quantity)
	item_image.texture = data.texture

func _on_item_placed(_item: ItemData) -> void:
	update()

func _ready() -> void:
	Player.item_placement.item_placed.connect(_on_item_placed)