extends Control

@export var name_label: Label
@export var stat_label: Label
var placed_item_id: int

func get_item_stats() -> String:
	var placed_item_data: PlacedItemData = Player.data.placed_items[placed_item_id]
	var item: Node = GameData.items[placed_item_data.item_index]
	var s: String = ""

	if item is Dropper:
		var ore = item.ore_scene.instantiate()
		var timer: Timer = item.get_node_or_null("Timer")
		var freq: String = ""
		if timer: freq = str(timer.wait_time)

		var ore_value: float = ore.value
		ore.queue_free()

		s += "Value: $%s" % GameData.float_to_prefix(ore_value)
		s += "\nFrequency: %sx" % freq
	elif item is Upgrader:
		s = "Mult: %sx" % GameData.float_to_prefix(item.multiplier)
	elif item is Furnace:
		s = "Mult: %sx" % GameData.float_to_prefix(item.mult)

	return s

func update() -> void:
	var placed_item_data: PlacedItemData = Player.data.placed_items[placed_item_id]
	var item_info: PlayerItemInfo = Player.data.inventory[placed_item_data.item_index]
	name_label.text = GameData.items[item_info.item_id].item_data.name
	stat_label.text = get_item_stats()

func show_item_info(id: int):
	position = get_global_mouse_position()
	placed_item_id = id
	update()
	show()

func _on_close_pressed() -> void:
	hide()

func _on_rotate_pressed() -> void:
	Player.data.placed_items[placed_item_id].rotation += deg_to_rad(90)
	Player.data.placed_items[placed_item_id].instance.rotation = Player.data.placed_items[
		placed_item_id
	].rotation

