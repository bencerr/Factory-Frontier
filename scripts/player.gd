extends Node
signal money_changed(change: float)
signal inventory_changed(id: int)
signal rebirthed(id: int)
signal tile_map_loaded(tm: TileMap)
signal buffs_changed()
signal main_loaded()
signal quest_changed(quest: Quest)

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
	for quest in data.quests:
		if quest.type == QuestManager.QUESTTYPE.REACH_MONEY:
			quest.update_progress(quest.progress + (amount/quest.goal))
			quest_changed.emit(quest)

func do_rebirth():
	data.money = 0

	for i in range(0, data.placed_items.size()):
		var placed_item_data: PlacedItemData = data.placed_items[i]
		var id = placed_item_data.item_index
		var item_info: PlayerItemInfo = Player.data.inventory[id]
		var item_data: ItemData = GameData.items[id].item_data

		if item_data.rarity != ItemData.RARITY.COMMON:
			item_info.quantity += 1
			update_inventory_item(id, item_info)

		data.placed_items[i].instance.queue_free()

	data.placed_items.clear()

	for key in data.inventory.keys():
		if GameData.items[key].item_data.rarity != ItemData.RARITY.COMMON: continue
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

	for quest in data.quests:
		if quest.type == QuestManager.QUESTTYPE.REBIRTH:
			quest.update_progress(1)
			quest_changed.emit(quest)
		elif quest.type == QuestManager.QUESTTYPE.REBIRTH_TIME:
			var prog = quest.goal - data.time_in_rebirth
			print("rebirth time quest progress: %s" % prog)
			if prog < 0:
				prog = 0
			else:
				prog = 1

			quest.update_progress(prog)
			quest_changed.emit(quest)

	data.time_in_rebirth = 0.0

func _ready() -> void:
	for item_key in GameData.items.keys():
		if not data.inventory.has(item_key):
			data.inventory[item_key] = PlayerItemInfo.new()
			data.inventory[item_key].item_id = item_key
			data.inventory[item_key].quantity = 0

	# data.inventory[4222123733].quantity = 4

	for item_key in data.inventory.keys():
		if not GameData.items.has(item_key):
			print("data loss: %s" % item_key)
			data.inventory.erase(item_key)
	if get_node_or_null("/root/Main") == null:
		await main_loaded
	get_node("/root/Main").load_base()
	load_placed_items()
	load_quests()

func load_quests() -> void:
	var quests = QuestManager.generate_quests(data.rebirths, 3)
	data.quests = quests
	for q in data.quests:
		quest_changed.emit(q)

func _on_tile_map_loaded(tm: TileMap) -> void:
	_tilemap = tm
