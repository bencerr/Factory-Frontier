extends Node

const SAVE_PATH: String = "user://Factory_Frontier.tres"

func load_data() -> Resource:
	#var as_text = FileAccess.get_file_as_string(save_path)
	#print(as_text)

	if ResourceLoader.exists(SAVE_PATH):
		print("found save file")
		var res: Resource = ResourceLoader.load(SAVE_PATH, "", ResourceLoader.CACHE_MODE_IGNORE)
		if res: return res
		print("error with save file")

	print("new save file")
	var data: PlayerData = PlayerData.new()
	data.inventory = {}
	data.placed_items = []
	return data

func save_data(data) -> void:
	print('saving to file')
	var response: int = ResourceSaver.save(data, SAVE_PATH)
	assert(response == OK)

func _ready() -> void:
	var data: Resource = load_data()
	if data is PlayerData:
		Player.data = data
	else:
		print_debug("Error loading data")

func _notification(what):
	if (
	what == NOTIFICATION_WM_CLOSE_REQUEST) or (
	what == NOTIFICATION_WM_GO_BACK_REQUEST) or (
	what == NOTIFICATION_APPLICATION_PAUSED):
		save_data(Player.data)
		get_tree().quit()
