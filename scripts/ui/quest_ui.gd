extends Control

@export var quest_control: PackedScene = preload("res://scenes/ui/quest_control.tscn")

var quest_mapping = {}

func _ready() -> void:
	# Connect the quest changed signal to update the UI
	Player.quest_changed.connect(_on_quests_changed)

	# Populate the quest UI with existing quests
	for quest in Player.data.quests:
		_on_quests_changed(quest)

func _on_complete_quest_click(quest: Quest) -> void:
	if quest.is_completed():
		Player.data.gems += int(quest.reward)
		Player.data.quests.erase(quest)
		SaveHandler.save_data(Player.data)
		var qc = quest_mapping[quest]
		quest_mapping.erase(quest)
		quest_mapping.erase(qc)
		qc.queue_free()
	else:
		print("Quest not completed yet!")

func _on_quests_changed(quest: Quest) -> void:
	if quest in quest_mapping:
		var qc = quest_mapping[quest]
		qc.get_node("MarginContainer/Control/Progress").value = quest.progress * 100
		qc.get_node("MarginContainer/Control/Name").text = quest.get_quest_name()
		qc.get_node("MarginContainer/Control/Reward").text = str(quest.reward) + " gems"
	else:
		var qc = quest_control.instantiate()
		qc.get_node("MarginContainer/Control/Name").text = quest.get_quest_name()
		qc.get_node("MarginContainer/Control/Progress").value = quest.progress * 100
		qc.get_node("MarginContainer/Control/Reward").text = str(quest.reward) + " gems"
		quest_mapping[quest] = qc
		quest_mapping[qc] = quest

		qc.get_node("MarginContainer/Control/Complete").pressed.connect(
			_on_complete_quest_click.bind(quest)
		)
		$Panel/MarginContainer/Control/ScrollContainer/VBoxContainer.add_child(qc)