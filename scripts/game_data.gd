extends Node

var items: Dictionary = {}
var rebirth_items: Array[int] = [] # keys for items dict

const grid_size: int = 16
var item_id_counter: int = 0

const suffixes_metric_symbol: Dictionary = {
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

func log10(x) -> float:
	return log(x) / log(10)

func float_to_prefix(number: float) -> String:
	if number < 1000:  # No suffix needed for numbers below 1000
		return str(number)

	var exponent: int = floor(log10(number) / 3)
	if str(exponent) in suffixes_metric_symbol:
		var suffix = suffixes_metric_symbol[str(exponent)]
		var scaled_number: float = number / pow(10, exponent * 3)

		while scaled_number >= 1000:
			scaled_number /= 1000
			exponent += 1
			suffix = suffixes_metric_symbol.get(str(exponent), "")  # Update suffix

		return str(round(scaled_number)) + suffix
	else:
		return str(number)

func calc_rebirth_price(rebirth: int) -> float:
	return 0
	#return 1e1 * pow(rebirth+1,1.1)

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
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")

	return scene_loads

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
