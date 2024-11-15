extends Node

const save_path: String = "user://Factory_Frontier.tres"
var db_client: DatabaseClient

func load_data() -> Resource:
	if ResourceLoader.exists(save_path):
		return ResourceLoader.load(save_path, "", ResourceLoader.CACHE_MODE_IGNORE)
	
	print("new save file")
	var data: PlayerData = PlayerData.new()
	data.inventory = {}
	data.placed_items = []
	return data

func save_data(data) -> void:
	print('saving to file')
	var response: int = ResourceSaver.save(data, save_path, ResourceSaver.FLAG_CHANGE_PATH)
	assert(response == OK)

func _ready() -> void:
	
	var data: Resource = load_data()
	if data is PlayerData:
		Player.data = data
	else:
		print_debug("Error loading data")
	db_client = DatabaseClient.new()
	add_child(db_client)
	for child in (await db_client.get_items()):
		print(child.item_name)
		print(child.item_type)
	

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_WM_GO_BACK_REQUEST:
		save_data(Player.data)
		get_tree().quit()
