extends Node
signal money_changed(change: float)
signal inventory_changed(id: int)

var data: PlayerData
var item_rotation: float = 0;

# Placed Items
func load_placed_items() -> void:
	for i in range(0, len(data.placed_items)):
		var placed_item_data: PlacedItemData = data.placed_items[i]
		var n: Node2D = GameData.items[placed_item_data.item_index]
		var instance: Node2D = n.duplicate()
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

# Inventory

func get_item_name(id: int) -> String:
	return GameData.items[id].item_data.name

func get_item_index(item_name: String) -> int:
	for key in range(GameData.items.keys):
		if get_item_name(key) == item_name:
			return key
	return -1

func get_item_by_name(item_name: String) -> ItemData:
	return data.inventory[get_item_index(item_name)]

func update_inventory_item(item_id: int, item: PlayerItemInfo) -> bool:
	if data.inventory.has(item_id):
		data.inventory[item_id] = item
		inventory_changed.emit(item_id)
		return true
	else:
		return false

func add_money(amount: float) -> void:
	data.money += amount
	money_changed.emit(amount)

func _ready() -> void:
	for item_key in GameData.items.keys():
		if not data.inventory.has(item_key):
			data.inventory[item_key] = PlayerItemInfo.new()
			data.inventory[item_key].item_id = item_key
			data.inventory[item_key].quantity = 0
	
	for key in data.inventory.keys():
		data.inventory[key].quantity = 1

	load_placed_items()