extends Node

var items: Dictionary = {}

const grid_size: int = 16
var item_id_counter: int = 0

func dir_contents(path):
	var scene_loads = []	

	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				print("Found directory: " + file_name)
			else:
				if file_name.get_extension() == "tscn":
					var full_path = path.path_join(file_name)
					scene_loads.append(load(full_path))
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")

	return scene_loads

func load_items() -> void:
	for res: Resource in dir_contents("res://scenes/items"):
		#var res := load(file_path)
		var itm: Node = res.instantiate()
		items[itm.item_data.id] = itm
		#print_debug(str(itm.item_data.id) + ": "+ itm.item_data.item_name)

func _ready() -> void:
	load_items()
