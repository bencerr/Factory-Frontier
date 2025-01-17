extends Control

@export_category("Upgrade Control")
@export var ore_limit_label: RichTextLabel
@export var ore_limit_button: Button

@export var base_level_label: RichTextLabel
@export var base_level_button: Button

func update_control() -> void:
	ore_limit_label.text = "Ore Limit [[b]%s[/b]]" % Player.data.ore_limit_index
	base_level_label.text = "Base Level [[b]%s[/b]]" % Player.data.base_level

	if Player.data.ore_limit_index >= len(GameData.ore_limit_upgrades)-1:
		ore_limit_button.text = "MAXED"
		ore_limit_button.disabled = true
	else:
		ore_limit_button.text = "($%s) Upgrade" % GameData.float_to_prefix(
			GameData.ore_limit_upgrades[Player.data.ore_limit_index+1].cost
		)

	if Player.data.base_level >= len(GameData.base_level_upgrades)-1:
		base_level_button.text = "MAXED"
		base_level_button.disabled = true
	else:
		base_level_button.text = "($%s) Upgrade" % GameData.float_to_prefix(
			GameData.base_level_upgrades[Player.data.base_level+1].cost
		)

func _ready() -> void:
	update_control()

func _on_upgrade_ore_limit_button_pressed() -> void:
	if not Player.data.ore_limit_index < len(GameData.ore_limit_upgrades)-1:
		update_control()
		return

	var cost := GameData.ore_limit_upgrades[Player.data.ore_limit_index+1].cost

	if Player.data.money >= cost:
		Player.data.money -= cost
		Player.data.ore_limit_index += 1
		Player.add_money(0) # to update ore_count

	update_control()

func _on_upgrade_base_level_button_pressed() -> void:
	if not Player.data.base_level < len(GameData.base_level_upgrades)-1:
		update_control()
		return

	var cost := GameData.base_level_upgrades[Player.data.base_level+1].cost

	if Player.data.money >= cost:
		Player.data.money -= cost
		Player.data.base_level += 1
		get_node("/root/Main").load_base()
	update_control()
