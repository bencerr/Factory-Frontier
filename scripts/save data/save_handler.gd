extends Node
signal money_changed(change: float)

const save_path: String = "user://Factory_Frontier.res"
var player_data: PlayerData

func add_money(amount: float) -> void:
	player_data.money += amount
	money_changed.emit(amount)

func money_display(_money: float) -> void:
	print(player_data.money)

func load_data() -> Resource:
	if ResourceLoader.exists(save_path):
		return ResourceLoader.load(save_path, "", ResourceLoader.CACHE_MODE_IGNORE)
	
	print("new save file")
	var data: PlayerData = PlayerData.new()
	data.inventory = PlayerInventory.new()
	return data

func save_data(data) -> void:
	print('saving to file')
	var response: int = ResourceSaver.save(data, save_path, ResourceSaver.FLAG_CHANGE_PATH)
	assert(response == OK)

func _ready() -> void:
	var data: Resource = load_data()
	if data is PlayerData:
		player_data = data
	money_changed.connect(money_display)
	print(player_data.inventory)

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_WM_GO_BACK_REQUEST:
		save_data(player_data)
		get_tree().quit()
