extends Node

signal ore_count_changed(change: int)

const GRID_SIZE: int = 16
const SUFFIXES_METRIC_SYMBOL: Dictionary = {
	"0": "",
	"1": "k",
	"2": "M",
	"3": "B",
	"4": "T",
	"5": "q",
	"6": "Q",
	"7": "sx",
	"8": "Sp",
}

var buffs: Dictionary = {
	"2x":
		func (value: float):
			return value*2,
	"3x":
		func (value: float):
			return value*3
}

var base_level_upgrades: Array[PlayerUpgrade]
var ore_limit_upgrades: Array[PlayerUpgrade]
var ad_mode := "PROD" # PROD, TESTING
var items: Dictionary = {}
var rebirth_items: Array[int] = [] # keys for items dict
var item_id_counter: int = 0
var cam_max_size: int = 100
var ore_count: int = 0:
	get:
		return ore_count
	set(val):
		ore_count = val
		ore_count_changed.emit(val)

func get_item_stats(item_id: int) -> String:
	var item: Node = GameData.items[item_id]
	var s: String = ""

	if item is Dropper:
		var ore = item.ore_scene.instantiate()
		var timer: Timer = item.get_node_or_null("Timer")
		var freq: String = ""
		if timer: freq = str(timer.wait_time)

		var ore_value: float = ore.value
		ore.queue_free()

		s += "Value: $%s" % GameData.float_to_prefix(ore_value)
		s += "\nFrequency: %ss" % freq
	elif item is Upgrader:
		s += "Mult: %sx" % GameData.float_to_prefix(item.multiplier)
		s += "\nLimit: %s" % str(item.upgrade_limit)
		if item.destroy_chance > 0:
			s += "\nDestroy: %s%%" % str(item.destroy_chance * 100)
	elif item is Furnace:
		s = "Mult: %sx" % GameData.float_to_prefix(item.mult)

	return s

func round_place(num: float, places: int):
	return (round(num*pow(10,places))/pow(10,places))

func log10(x) -> float:
	return log(x) / log(10)

func float_to_prefix(number: float) -> String:
	if number < 1000:  # No suffix needed for numbers below 1000
		return str(number)

	var exponent: int = floor(log10(number) / 3)
	if str(exponent) in SUFFIXES_METRIC_SYMBOL:
		var suffix = SUFFIXES_METRIC_SYMBOL[str(exponent)]
		var scaled_number: float = number / pow(10, exponent * 3)

		while scaled_number >= 1000:
			scaled_number /= 1000
			exponent += 1
			suffix = SUFFIXES_METRIC_SYMBOL.get(str(exponent), "")  # Update suffix

		return str(round_place(scaled_number, 2)) + suffix  # Round to 2 decimal places

	return str(number)

func calc_rebirth_price(rebirth: int) -> float:
	return 1e14 * (rebirth+1) * ((pow(10, floor(rebirth/100.0))))

func strip_item_node(node: Node) -> Node:
	for child in node.get_children():
		if !(child is Sprite2D or child is AnimatedSprite2D):
			child.queue_free()
		else:
			child.set_script(null)
	node.set_script(null)

	return node

func dir_contents(path) -> Array[Array]:
	var scene_loads: Array[Array] = []

	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				print("Found directory: " + file_name)
			else:
				if (file_name.get_extension() == "remap"):
					file_name = file_name.replace('.remap', '')

				if file_name.get_extension() == "tscn":
					var full_path = path.path_join(file_name)
					scene_loads.append([load(full_path), file_name.get_basename()])
				elif file_name.get_extension() == "tres":
					var full_path = path.path_join(file_name)
					scene_loads.append([load(full_path), file_name.get_basename()])
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")

	return scene_loads

func load_base_level_upgrades() -> void:
	var dir = "res://scenes/items/data/base_levels"

	var temp = dir_contents(dir)
	for contents: Array in temp:
		base_level_upgrades.append(contents[0])

	base_level_upgrades.sort_custom(func(a, b):
		return a.index < b.index)

func load_ore_limit_upgrades() -> void:
	var dir = "res://scenes/items/data/ore_limits"

	var temp = dir_contents(dir)
	for contents: Array in temp:
		ore_limit_upgrades.append(contents[0])

	ore_limit_upgrades.sort_custom(func(a, b):
		return a.index < b.index)

func load_items() -> void:
	var dirs := [
		"res://scenes/items/conveyors",
		"res://scenes/items/droppers",
		"res://scenes/items/furnaces",
		"res://scenes/items/upgraders"]

	for dir in dirs:
		for arr: Array in dir_contents(dir):
			var itm: Node = arr[0].instantiate()
			itm.item_data.id = hash(arr[1])
			itm.item_data.name = arr[1]
			items[itm.item_data.id] = itm
			if itm.item_data.rarity == ItemData.RARITY.REBIRTH:
				rebirth_items.append(itm.item_data.id)

func _ready() -> void:
	load_items()
	load_base_level_upgrades()
	load_ore_limit_upgrades()
	MobileAds.initialize()
