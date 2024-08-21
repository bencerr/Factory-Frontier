extends Node
signal money_changed(change: float)
signal inventory_changed(id: int)

@onready var input_handler: InputHandler = get_node("/root/Main/InputHandler")
@onready var item_placement: ItemPlacement = get_node("/root/Main/InputHandler/ItemPlacement")
@onready var ui: MainInterface = get_node("/root/Main/CanvasLayer/UI")
var data: PlayerData

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
	print(data.money)

func _ready() -> void:
	money_changed.connect(money_display)
	data.inventory[0].quantity += 4
