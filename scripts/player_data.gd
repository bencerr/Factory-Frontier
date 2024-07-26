extends Node
signal money_changed(change: float)

const save_file_name: String = "user://Factory_Frontier.save"
var money: float = 0

func add_money(amount: float) -> void:
	money += amount
	money_changed.emit(amount)

func money_display(_money: float) -> void:
	print(money)

func save() -> Dictionary:
	var save_dict = {
		"filename": get_scene_file_path(),
		"money": money,
	}

	return save_dict

func load_game() -> void:
	if not FileAccess.file_exists(save_file_name):
		print("not save file found, new save")
		return
	var game_save = FileAccess.open(save_file_name, FileAccess.READ)

	while game_save.get_position() < game_save.get_length():
		var json_string = game_save.get_line()
		var json = JSON.new()
		
		var parse_result = json.parse(json_string)
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue
			
		var node_data = json.get_data()
		
		for i in node_data.keys():
			if i == "filename":
				continue
			self.set(i, node_data[i])

func _ready() -> void:
	money_changed.connect(money_display)
	load_game()

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_WM_GO_BACK_REQUEST:
		save_game()
		get_tree().quit()

func save_game():
	var game_save = FileAccess.open(save_file_name, FileAccess.WRITE)
	var node_data = save()
	var json_string = JSON.stringify(node_data)
	
	game_save.store_line(json_string)
	print('saved to file')