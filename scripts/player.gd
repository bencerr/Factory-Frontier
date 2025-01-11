extends Node
signal money_changed(change: float)
signal inventory_changed(id: int)
signal rebirthed(id: int)
signal tile_map_loaded(tm: TileMap)
signal buffs_changed()

var data: PlayerData
var item_rotation: float = 0;
var _tilemap: TileMap

# Placed Items
func load_placed_items() -> void:
	if get_node_or_null("/root/Main/TileMap") == null:
		await tile_map_loaded
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

	return false

func add_money(amount: float) -> void:
	if len(data.buffs) >= 1:
		for buff_name in GameData.buffs.keys():
			if len(data.buffs.filter(func(buff: Buff): return buff.name == buff_name)) > 0:
				amount = GameData.buffs[buff_name].call(amount)
	data.money += amount
	money_changed.emit(amount)

func do_rebirth():
	data.money = 0

	for i in range(0, data.placed_items.size()):
		var placed_item_data: PlacedItemData = data.placed_items[i]
		var id = placed_item_data.item_index
		var item_info: PlayerItemInfo = Player.data.inventory[id]
		var item_data: ItemData = GameData.items[id].item_data

		if item_data.rarity == ItemData.RARITY.REBIRTH:
			item_info.quantity += 1
			update_inventory_item(id, item_info)

		data.placed_items[i].instance.queue_free()

	data.placed_items.clear()

	for key in data.inventory.keys():
		if GameData.items[key].item_data.rarity == ItemData.RARITY.REBIRTH: continue
		var item_info: PlayerItemInfo = data.inventory[key]
		item_info.quantity = 0
		update_inventory_item(key, item_info)

	data.rebirths += 1
	money_changed.emit(0)

	var winner = GameData.rebirth_items.pick_random()
	var item_updated = Player.data.inventory[winner]
	item_updated.quantity += 1
	update_inventory_item(winner, item_updated)
	rebirthed.emit(winner)
	SaveHandler.save_data(data)

func _ready() -> void:
	for item_key in GameData.items.keys():
		if not data.inventory.has(item_key):
			data.inventory[item_key] = PlayerItemInfo.new()
			data.inventory[item_key].item_id = item_key
			data.inventory[item_key].quantity = 0

	for item_key in data.inventory.keys():
		if not GameData.items.has(item_key):
			print("data loss: %s" % item_key)
			data.inventory.erase(item_key)

	load_placed_items()

func _on_tile_map_loaded(tm: TileMap) -> void:
	_tilemap = tm
