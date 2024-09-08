extends Node
signal money_changed(change: float)
signal inventory_changed(id: int)

@onready var input_handler: InputHandler = get_node("/root/Main/InputHandler")
@onready var item_placement: ItemPlacement = get_node("/root/Main/InputHandler/ItemPlacement")
@onready var ui: MainInterface = get_node("/root/Main/CanvasLayer/UI")
var data: PlayerData
var item_rotation: float = 0;

func load_placed_items() -> void:
	for i in range(0, len(data.placed_items)):
		var placed_item_data: PlacedItemData = data.placed_items[i]
		var item_data: ItemData = GameData.items[placed_item_data.item_index]
		var instance: Node = item_data.scene.instantiate()
		instance.position = get_node("/root/Main/TileMap").map_to_local(placed_item_data.position)
		instance.rotation = placed_item_data.rotation
		data.placed_items[i].instance = instance
		get_node("/root/Main/PlacedItems").add_child(instance)

func check_tile(v: Vector2i) -> bool:
	for placed_item_data: PlacedItemData in data.placed_items:
		if placed_item_data.position == v:
			return false
	return true

func get_placed_item_id(v: Vector2i) -> int:
	for i in range(0, len(data.placed_items)):
		var placed_item_data: PlacedItemData = data.placed_items[i]
		if placed_item_data.position == v:
			return i
	return -1

func has_item(item_name: String) -> bool:
	for itm in data.inventory:
		if itm.item_name == item_name:
			return true
	return false

func get_item_index(item_name: String) -> int:
	for i in range(len(data.inventory)):
		if data.inventory[i].item_name == item_name:
			return i
	return -1

func get_item(inv_index: int) -> ItemData:
	return data.inventory[inv_index]

func get_item_by_name(item_name: String) -> ItemData:
	return data.inventory[get_item_index(item_name)]

func update_inventory_item(item_id: int, item: ItemData) -> bool:
	var inventory_indx: int = get_item_index(item.item_name)
	if inventory_indx == item_id:
		data.inventory[inventory_indx] = item
		inventory_changed.emit(inventory_indx)
		return true
	else:
		return false

func add_money(amount: float) -> void:
	data.money += amount
	money_changed.emit(amount)

func money_display(_money: float) -> void:
	pass

func _ready() -> void:
	money_changed.connect(money_display)
	# for v in GameData.items.keys():
	# 	data.inventory.append(GameData.items[v])
	data.inventory[0].quantity += 4
	data.inventory[1].quantity += 4
	data.inventory[2].quantity += 4
	load_placed_items()
