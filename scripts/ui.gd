class_name MainInterface
extends Control

signal shop_selected_item_changed(item_id: int)

enum UITAB {NONE,SHOP,INVENTORY,REBIRTH,UPGRADE,QUEST}

@export var shop_panel: Control
@export var inv_panel: Control
@export var inv_container: Control
@export var placement_control: Control
@export var money_label: Label
@export var shop_container: Control
@export var buy_panel: Control
@export var rebirth_control: Control
@export var rebirth_price_label: Label
@export var rebirth_label: RichTextLabel
@export var ore_limit_label: Label
@export var buy_panel_subviewport: SubViewport
@export var rebirth_panel_button: TextureButton
@export var buff_label_scene: PackedScene
@export var buff_container: VBoxContainer
@export var upgrade_control: Control
@export var quest_control: Control
@export var gems_label: Label

var shop_item_id: int = -1
var current_tab: UITAB = UITAB.NONE
var sort_button_style: Resource
var sort_button_style_empty: Resource
var prev_selected_tab_panel: Panel
var icon_viewport_node: Node
var shop_filter: ItemData.ITEMTYPE
var inv_filter: ItemData.ITEMTYPE
var item_selection_ui: Control
var tab_tween: Tween
var merge_price: float = 100

@onready var input_handler: InputHandler = get_node("/root/Main/InputHandler")

func _on_input_type_changed(input_typ: InputHandler.INPUTTYPE) -> void:
	match input_typ:
		InputHandler.INPUTTYPE.CAMERA:
			placement_control.visible = false
		InputHandler.INPUTTYPE.PLACEMENT:
			placement_control.update()
			placement_control.visible = true

func refresh_inventory() -> void:
	for n in inv_container.get_children():
		inv_container.remove_child(n)
		n.queue_free()

	var template: PackedScene = load("res://scenes/ui/item.tscn")
	var sorted_inv: Array = []

	for key in Player.data.inventory.keys():
		if not GameData.items.has(key): continue
		sorted_inv.append({"key": key, "price": GameData.items[key].item_data.price})

	sorted_inv.sort_custom(func(a, b):
		return a.price < b.price
	)

	for d in sorted_inv:
		var control: UIItem = template.instantiate()
		control.item_id = d["key"]
		var cntrl_size: float = (inv_panel.size.x/3.0 - 15)
		control.custom_minimum_size = Vector2(cntrl_size, cntrl_size)
		inv_container.add_child(control)

func load_shop() -> void:
	var template: PackedScene = load("res://scenes/ui/shop_item.tscn")
	var sorted_shop: Array = []

	for key in GameData.items.keys():
		# only load non-rebirth items
		if GameData.items[key].item_data.rarity != ItemData.RARITY.COMMON: continue

		sorted_shop.append({"key": key, "price": GameData.items[key].item_data.price})

	sorted_shop.sort_custom(func(a, b):
		return a.price < b.price
	)

	var cntrl_size: float = (shop_panel.get_node("MarginContainer").size.x/2.0 - 15)
	for d in sorted_shop:
		var control: ShopUIItem = template.instantiate()
		control.item_id = d["key"]
		control.custom_minimum_size = Vector2(cntrl_size, cntrl_size)
		shop_container.add_child(control)

func filter_shop(item_type: ItemData.ITEMTYPE) -> void:
	shop_filter = item_type
	for shop_ui_itm: ShopUIItem in shop_container.get_children():
		if GameData.items[shop_ui_itm.item_id].item_data.item_type == item_type:
			shop_ui_itm.visible = true
		else:
			shop_ui_itm.visible = false

func filter_inventory(item_type: ItemData.ITEMTYPE) -> void:
	inv_filter = item_type
	for ui_item: UIItem in inv_container.get_children():
		var data: ItemData = GameData.items[ui_item.item_id].item_data
		var info: PlayerItemInfo = Player.data.inventory[ui_item.item_id]

		if data.item_type == item_type and info.quantity > 0:
			ui_item.visible = true
		else:
			ui_item.visible = false

func switch_tab_vfx_in(control: Control) -> void:
	if tab_tween:
		return

	var orginal_pos = control.position
	control.position = Vector2(orginal_pos.x, self.size.y)
	tab_tween = control.create_tween().set_trans(Tween.TRANS_SINE)

	tab_tween.tween_property(control, "position", orginal_pos, .325)
	tab_tween.tween_callback(func():
		if tab_tween:
			tab_tween = null)
	tab_tween.play()

func switch_tab(tab: UITAB) -> void:
	if current_tab == tab:
		current_tab = UITAB.NONE
	else:
		current_tab = tab

	if item_selection_ui: item_selection_ui.hide()
	get_node("TabControl/HBoxContainer/InventoryButton").button_pressed = false
	get_node("TabControl/HBoxContainer/ShopButton").button_pressed = false
	get_node("TabControl/HBoxContainer/RebirthButton").button_pressed = false
	get_node("TabControl/HBoxContainer/UpgradeButton").button_pressed = false
	get_node("TabControl/HBoxContainer/QuestButton").button_pressed = false

	match current_tab:
		UITAB.NONE:
			shop_panel.visible = false
			inv_panel.visible = false
			rebirth_control.visible = false
			upgrade_control.visible = false
			quest_control.visible = false
		UITAB.SHOP:
			shop_panel.visible = true
			inv_panel.visible = false
			rebirth_control.visible = false
			upgrade_control.visible = false
			quest_control.visible = false
			input_handler.disable_placing()
			switch_tab_vfx_in(shop_panel)
			get_node("TabControl/HBoxContainer/ShopButton").button_pressed = true
		UITAB.INVENTORY:
			shop_panel.visible = false
			inv_panel.visible = true
			rebirth_control.visible = false
			upgrade_control.visible = false
			quest_control.visible = false
			input_handler.disable_placing()
			switch_tab_vfx_in(inv_panel)
			get_node("TabControl/HBoxContainer/InventoryButton").button_pressed = true
		UITAB.REBIRTH:
			rebirth_control.visible = true
			shop_panel.visible = false
			inv_panel.visible = false
			upgrade_control.visible = false
			quest_control.visible = false
			input_handler.disable_placing()
			switch_tab_vfx_in(rebirth_control)
			get_node("TabControl/HBoxContainer/RebirthButton").button_pressed = true
		UITAB.UPGRADE:
			upgrade_control.visible = true
			rebirth_control.visible = false
			shop_panel.visible = false
			inv_panel.visible = false
			quest_control.visible = false
			input_handler.disable_placing()
			switch_tab_vfx_in(upgrade_control)
			get_node("TabControl/HBoxContainer/UpgradeButton").button_pressed = true
		UITAB.QUEST:
			quest_control.visible = true
			rebirth_control.visible = false
			shop_panel.visible = false
			inv_panel.visible = false
			upgrade_control.visible = false
			input_handler.disable_placing()
			switch_tab_vfx_in(upgrade_control)
			get_node("TabControl/HBoxContainer/QuestButton").button_pressed = true

func _on_rebirth_button_pressed() -> void:
	switch_tab(UITAB.REBIRTH)

func _on_inventory_button_pressed() -> void:
	switch_tab(UITAB.INVENTORY)

func _on_shop_button_pressed() -> void:
	switch_tab(UITAB.SHOP)

func _on_upgrade_button_pressed() -> void:
	switch_tab(UITAB.UPGRADE)

func _on_quest_button_pressed() -> void:
	switch_tab(UITAB.QUEST)

func _on_delete_button_pressed() -> void:
	if get_node("/root/Main/InputHandler").current_input_type == InputHandler.INPUTTYPE.DELETE:
		input_handler.disable_deleting()
	else:
		input_handler.enable_deleting()
		placement_control.visible = false
		switch_tab(UITAB.NONE)

func _ready() -> void:
	sort_button_style = load("res://resources/sort_button_selected.tres")
	sort_button_style_empty = load("res://resources/empty_style_box.tres")
	item_selection_ui = get_node("/root/Main/CanvasLayer/ItemSelectionControl")

	# events
	get_node("/root/Main/InputHandler").input_type_changed.connect(_on_input_type_changed)
	shop_selected_item_changed.connect(_on_shop_selected_item_changed)
	Player.money_changed.connect(_on_money_change)
	GameData.ore_count_changed.connect(_on_ore_count_changed)

	# init code
	_on_money_change(0)
	refresh_inventory()
	load_shop()
	filter_shop(ItemData.ITEMTYPE.DROPPER)
	filter_inventory(ItemData.ITEMTYPE.DROPPER)

	var temp1 = get_node("ShopControl/SortPanel/Panel/HBoxContainer/Button")
	temp1.add_theme_stylebox_override("normal", sort_button_style)
	var temp2 = get_node("InventoryControl/SortPanel/Panel/HBoxContainer/Button")
	temp2.add_theme_stylebox_override("normal", sort_button_style)

	rebirth_price_label.text = "Cost: $%s" % GameData.float_to_prefix(
			GameData.calc_rebirth_price(Player.data.rebirths)
		)
	rebirth_label.text = "[center][b]%s[/b] rebirths[/center]" % str(Player.data.rebirths)

	if Player.data.rebirths == 0 and Player.data.money < GameData.calc_rebirth_price(0)/100000:
		rebirth_panel_button.visible = false
	else:
		rebirth_panel_button.visible = true

	_on_shop_selected_item_changed(hash("Conveyor"))
	load_merge_items()
	Player.rebirthed.connect(refresh_merge_tab)
	refresh_merge_tab()
	_on_gems_changed(0)
	Player.gems_changed.connect(_on_gems_changed)

func _on_money_change(_value: float) -> void:
	money_label.text = "$" + GameData.float_to_prefix(Player.data.money)
	if Player.data.rebirths == 0 and Player.data.money < GameData.calc_rebirth_price(0)/100000:
		rebirth_panel_button.visible = false
	else:
		rebirth_panel_button.visible = true

func _on_button_4_pressed() -> void:
	if current_tab == UITAB.SHOP:
		deselect_shop_filters()
		get_node(
			"ShopControl/SortPanel/Panel/HBoxContainer/Button4"
		).add_theme_stylebox_override(
			"normal", sort_button_style
		)
		filter_shop(ItemData.ITEMTYPE.UPGRADER)
	elif current_tab == UITAB.INVENTORY:
		deselect_inv_filters()
		get_node(
			"InventoryControl/SortPanel/Panel/HBoxContainer/Button4"
		).add_theme_stylebox_override(
		"normal", sort_button_style
		)
		filter_inventory(ItemData.ITEMTYPE.UPGRADER)

func _on_button_3_pressed() -> void:
	if current_tab == UITAB.SHOP:
		deselect_shop_filters()
		get_node(
			"ShopControl/SortPanel/Panel/HBoxContainer/Button3"
		).add_theme_stylebox_override(
			"normal", sort_button_style
		)
		filter_shop(ItemData.ITEMTYPE.FURNACE)
	elif current_tab == UITAB.INVENTORY:
		deselect_inv_filters()
		get_node(
			"InventoryControl/SortPanel/Panel/HBoxContainer/Button3"
		).add_theme_stylebox_override(
			"normal", sort_button_style
		)
		filter_inventory(ItemData.ITEMTYPE.FURNACE)

func _on_button_2_pressed() -> void:
	if current_tab == UITAB.SHOP:
		deselect_shop_filters()
		get_node(
			"ShopControl/SortPanel/Panel/HBoxContainer/Button2"
		).add_theme_stylebox_override(
			"normal", sort_button_style
		)
		filter_shop(ItemData.ITEMTYPE.CONVEYOR)
	elif current_tab == UITAB.INVENTORY:
		deselect_inv_filters()
		get_node(
			"InventoryControl/SortPanel/Panel/HBoxContainer/Button2"
		).add_theme_stylebox_override(
			"normal", sort_button_style
		)
		filter_inventory(ItemData.ITEMTYPE.CONVEYOR)

func _on_button_pressed() -> void:
	if current_tab == UITAB.SHOP:
		deselect_shop_filters()
		get_node(
			"ShopControl/SortPanel/Panel/HBoxContainer/Button"
		).add_theme_stylebox_override(
			"normal", sort_button_style
		)
		filter_shop(ItemData.ITEMTYPE.DROPPER)
	elif current_tab == UITAB.INVENTORY:
		deselect_inv_filters()
		get_node(
			"InventoryControl/SortPanel/Panel/HBoxContainer/Button"
		).add_theme_stylebox_override(
			"normal", sort_button_style
		)
		filter_inventory(ItemData.ITEMTYPE.DROPPER)

func deselect_shop_filters() -> void:
	for button in get_node("ShopControl/SortPanel/Panel/HBoxContainer").get_children():
		if button is Button:
			button.add_theme_stylebox_override("normal", sort_button_style_empty)

func deselect_inv_filters() -> void:
	for button in get_node("InventoryControl/SortPanel/Panel/HBoxContainer").get_children():
		if button is Button:
			button.add_theme_stylebox_override("normal", sort_button_style_empty)

func _on_shop_selected_item_changed(id: int) -> void:
	shop_item_id = id
	var item_data: ItemData = GameData.items[id].item_data

	for c in buy_panel_subviewport.get_children():
		c.queue_free()

	icon_viewport_node = GameData.items[id].duplicate()
	icon_viewport_node.position = buy_panel_subviewport.size / 2
	icon_viewport_node = GameData.strip_item_node(icon_viewport_node)
	buy_panel_subviewport.add_child(icon_viewport_node)
	buy_panel.get_node("MarginContainer/VBoxContainer/ItemName").text = item_data.name

	var stats = GameData.get_item_stats(id)
	buy_panel.get_node("MarginContainer/VBoxContainer/Stats").text = stats
	buy_panel.get_node("MarginContainer/VBoxContainer/Price").text = "$%s" % (
		GameData.float_to_prefix(item_data.price))

func _on_buy_pressed() -> void:
	if not GameData.items.has(shop_item_id): return
	var data: ItemData = GameData.items[shop_item_id].item_data
	if Player.data.money >= data.price:
		var item_updated = Player.data.inventory[shop_item_id]
		item_updated.quantity += 1
		Player.update_inventory_item(shop_item_id, item_updated)
		Player.add_money(-1 * data.price)

func _on_do_rebirth_button_pressed() -> void:
	var price := GameData.calc_rebirth_price(Player.data.rebirths)

	if Player.data.money >= price:
		Player.do_rebirth()
		rebirth_label.text = "[center][b]%s[/b] rebirths[/center]" % str(Player.data.rebirths)
		rebirth_price_label.text = "Cost: $%s" % GameData.float_to_prefix(
			GameData.calc_rebirth_price(Player.data.rebirths)
		)

func _on_ore_count_changed(_val: int) -> void:
	ore_limit_label.text = "%s / %s ores" % [
		GameData.ore_count,
		GameData.ore_limit_upgrades[Player.data.ore_limit_index].value
	]

func _on_buff_timer_timeout() -> void:
	for i in range(len(Player.data.buffs)-1, -1, -1):
		var buff = Player.data.buffs[i]
		buff.time_left -= 1
		if buff.time_left <= 0:
			if buff.buff_label_instance:
				buff.buff_label_instance.queue_free()
			Player.data.buffs.remove_at(i)

	for buff in Player.data.buffs:
		var minutes = buff.time_left / 60
		var seconds = fmod(buff.time_left, 60)
		var time_string = "%02d:%02d" % [minutes, seconds]

		if not buff.buff_label_instance:
			buff.buff_label_instance = buff_label_scene.instantiate()
			buff_container.add_child(buff.buff_label_instance)
			buff_container.move_child(buff.buff_label_instance, 0)
		buff.buff_label_instance.text = "%s: %s" % [buff.name, time_string]

func load_merge_items() -> void:
	var root_path = "res://scenes/items/merge/"
	var dir_contents = DirAccess.get_files_at(root_path)
	var template = load("res://scenes/ui/merge_control.tscn")

	for file_name in dir_contents:
		if (file_name.get_extension() == "remap"):
			file_name = file_name.replace('.remap', '')

		var res: MergeData = load(root_path + file_name)

		var merge_control = template.instantiate()

		var item_template = load("res://scenes/ui/merge_item.tscn")

		var item_data: ItemData = GameData.items[hash(res.item_name)].item_data
		merge_control.get_node("ItemName").text = item_data.name
		merge_control.get_node("Button").pressed.connect(_on_merge_button_pressed.bind(
			res, merge_control.get_node("Button"))
		)

		for item_name in res.items:
			var clone = item_template.instantiate()
			merge_control.get_node("HBoxContainer").add_child(clone)

			var vp: SubViewport = clone.get_node("TextureRect/SubViewport")
			for c in vp.get_children():
				c.queue_free()

			var vp_node = GameData.items[hash(item_name)].duplicate()
			vp_node.position = Vector2(16, 16)
			vp_node = GameData.strip_item_node(vp_node)
			vp.add_child(vp_node)

		rebirth_control.get_node(
			"Panel/TabContainer/Merge/Control/ScrollContainer/VBoxContainer"
		).add_child(merge_control)

func _on_merge_button_pressed(merge_data: MergeData, btn: Button) -> void:
	if btn.text != "Craft": return
	var quantities = {}

	for item_name in merge_data.items:
		var id = hash(item_name)
		if quantities.has(id):
			quantities[id] += 1
		else:
			quantities[id] = 1

	# check player has all items
	for item_name in merge_data.items:
		var id = hash(item_name)
		if Player.data.inventory[id].quantity < quantities[id]:
			return

	# check player has enough gems
	if Player.data.gems < merge_price:
		return

	Player.set_gems(Player.data.gems - merge_price)

	# remove items
	for item_name in merge_data.items:
		var id = hash(item_name)
		Player.data.inventory[id].quantity -= 1

	# give merge item
	Player.data.inventory[hash(merge_data.item_name)].quantity += 1

	refresh_inventory()
	btn.text = "Crafted"
	await get_tree().create_timer(1).timeout
	btn.text = "Craft"

func _on_x_money_button_pressed() -> void:
	get_node("/root/Main").play_rewarded_ad.emit()

func refresh_merge_tab(_id=0) -> void:
	var merge_control = get_node("RebirthControl/Panel/TabContainer/Merge")
	if Player.data.rebirths < 5:
		merge_control.name = "<Locked 5 Rebirths>"
	else:
		merge_control.name = "Merge"

func _on_tab_container_tab_selected(tab:int) -> void:
	if tab == 1 and Player.data.rebirths < 5:
		get_node("RebirthControl/Panel/TabContainer").current_tab = 0

func _on_gems_changed(_value: int) -> void:
	gems_label.text = str(Player.data.gems) + " gems"