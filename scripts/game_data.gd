extends Node

var items: Dictionary = {
	0: create_item("Conveyor", Vector2i(0,0), "res://scenes/items/conveyor.tscn"),
	1: create_item("Dropper", Vector2i(1,0), "res://scenes/items/dropper.tscn"),
	2: create_item("Furnace", Vector2i(2,0), "res://scenes/items/furnace.tscn")
}

const grid_size: int = 16
var item_id_counter: int = 0

func create_item(new_name: String, atlas_coords: Vector2i, scene: String) -> ItemData:
	var id: ItemData = ItemData.new()
	id.item_name = new_name
	id.quantity = 0
	id.texture.atlas = load("res://sprites/tilesets/icons.png")
	id.texture.region = Rect2(atlas_coords.x * grid_size, atlas_coords.y * grid_size, grid_size, grid_size)
	id.id = item_id_counter
	id.scene = load(scene)
	item_id_counter += 1
	return id

func _ready() -> void:
	pass