extends Control
class_name MainInterface
enum UI_TAB {
	NONE,
	SHOP,
	INVENTORY,
	REBIRTH
}

signal shop_selected_item_changed(item_id: int)
var shop_item_id: int = -1

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

@onready var input_handler: InputHandler = get_node("/root/Main/InputHandler")
var current_tab: UI_TAB = UI_TAB.NONE
var sort_button_style: Resource
var sort_button_style_empty: Resource
var prev_selected_tab_panel: Panel
var icon_viewport_node: Node
var shop_filter: ItemData.ITEM_TYPE
var inv_filter: ItemData.ITEM_TYPE
var item_selection_ui: Control

func _on_input_type_changed(input_typ: InputHandler.INPUT_TYPE) -> void:
	match input_typ:
		InputHandler.INPUT_TYPE.CAMERA:
			placement_control.visible = false
		InputHandler.INPUT_TYPE.PLACEMENT:
			placement_control.update()
			placement_control.visible = true

func refresh_inventory() -> void:
	var template: PackedScene = load("res://scenes/ui/item.tscn")
	var sorted_inv: Array = []

	for key in Player.data.inventory.keys():
		sorted_inv.append({"key": key, "price": GameData.items[key].item_data.price})

	sorted_inv.sort_custom(func(a, b): 
		return a.price < b.price
	)

	for d in sorted_inv:
		var control: UI_Item = template.instantiate()
		control.item_id = d["key"]
		var cntrl_size: float = (inv_panel.size.x/4.0 - 15)
		control.custom_minimum_size = Vector2(cntrl_size, cntrl_size)
		inv_container.add_child(control)

func load_shop() -> void:
	var template: PackedScene = load("res://scenes/ui/shop_item.tscn")
	var sorted_shop: Array = []

	for key in GameData.items.keys():
		# only load non-rebirth items
		if GameData.items[key].item_data.rarity == ItemData.RARITY.REBIRTH: continue

		sorted_shop.append({"key": key, "price": GameData.items[key].item_data.price})

	sorted_shop.sort_custom(func(a, b): 
		return a.price < b.price
	)

	for d in sorted_shop:
		var control: Shop_UI_Item = template.instantiate()
		control.item_id = d["key"]
		var cntrl_size: float = (shop_panel.size.x/4.0 - 15)
		control.custom_minimum_size = Vector2(cntrl_size, cntrl_size)
		shop_container.add_child(control)

func filter_shop(item_type: ItemData.ITEM_TYPE) -> void:
	shop_filter = item_type
	for shop_ui_itm: Shop_UI_Item in shop_container.get_children():
		if GameData.items[shop_ui_itm.item_id].item_data.item_type == item_type:
			shop_ui_itm.visible = true
		else:
			shop_ui_itm.visible = false

func filter_inventory(item_type: ItemData.ITEM_TYPE) -> void:
	inv_filter = item_type
	for ui_item: UI_Item in inv_container.get_children():
		var data: ItemData = GameData.items[ui_item.item_id].item_data
		var info: PlayerItemInfo = Player.data.inventory[ui_item.item_id]

		if data.item_type == item_type and info.quantity > 0:
			ui_item.visible = true
		else:
			ui_item.visible = false
 
func switch_tab(tab: UI_TAB) -> void:
	if current_tab == tab:
		current_tab = UI_TAB.NONE
	else:
		current_tab = tab
	
	if item_selection_ui: item_selection_ui.hide()
	get_node("TabControl/HBoxContainer/InventoryButton/Panel").visible = false
	get_node("TabControl/HBoxContainer/ShopButton/Panel").visible = false
	get_node("TabControl/HBoxContainer/DeleteButton/Panel").visible = false
	get_node("TabControl/HBoxContainer/RebirthButton/Panel").visible = false

	match current_tab:
		UI_TAB.NONE:
			shop_panel.visible = false
			inv_panel.visible = false
			rebirth_control.visible = false
		UI_TAB.SHOP:
			shop_panel.visible = true
			inv_panel.visible = false
			rebirth_control.visible = false
			input_handler.disable_placing()
			get_node("TabControl/HBoxContainer/ShopButton/Panel").visible = true
		UI_TAB.INVENTORY:
			shop_panel.visible = false
			inv_panel.visible = true
			rebirth_control.visible = false
			input_handler.disable_placing()
			get_node("TabControl/HBoxContainer/InventoryButton/Panel").visible = true
		UI_TAB.REBIRTH:
			rebirth_control.visible = true
			shop_panel.visible = false
			inv_panel.visible = false
			input_handler.disable_placing()
			get_node("TabControl/HBoxContainer/RebirthButton/Panel").visible = true

func _on_rebirth_button_pressed() -> void:
	switch_tab(UI_TAB.REBIRTH)

func _on_inventory_button_pressed() -> void:
	switch_tab(UI_TAB.INVENTORY)

func _on_shop_button_pressed() -> void:
	switch_tab(UI_TAB.SHOP)

func _on_delete_button_pressed() -> void:
	if get_node("/root/Main/InputHandler").current_input_type == InputHandler.INPUT_TYPE.DELETE:
		input_handler.disable_deleting()
		get_node("TabControl/HBoxContainer/DeleteButton/Panel").visible = false
	else:
		input_handler.enable_deleting()
		placement_control.visible = false
		switch_tab(UI_TAB.NONE)
		get_node("TabControl/HBoxContainer/DeleteButton/Panel").visible = true

func _ready() -> void:
	sort_button_style = load("res://resources/sort_button_selected.tres")
	sort_button_style_empty = load("res://resources/empty_style_box.tres")
	get_node("/root/Main/InputHandler").input_type_changed.connect(_on_input_type_changed)
	refresh_inventory()
	Player.money_changed.connect(_on_money_change)
	shop_selected_item_changed.connect(_on_shop_selected_item_changed)
	_on_money_change(0)
	load_shop()
	filter_shop(ItemData.ITEM_TYPE.DROPPER)
	get_node("ShopControl/SortPanel/Panel/HBoxContainer/Button").add_theme_stylebox_override("normal", sort_button_style)
	filter_inventory(ItemData.ITEM_TYPE.DROPPER)
	get_node("InventoryControl/SortPanel/Panel/HBoxContainer/Button").add_theme_stylebox_override("normal", sort_button_style)
	item_selection_ui = get_node("/root/Main/ItemSelectionControl")
	rebirth_price_label.text = "Cost: 	$" + GameData.float_to_prefix(GameData.calc_rebirth_price(Player.data.rebirths))
	rebirth_label.text = "[center][b] " + str(Player.data.rebirths) +" [/b] rebirths[/center]"

func _on_money_change(_value: float) -> void:
	money_label.text = "$" + GameData.float_to_prefix(Player.data.money)

func _on_button_4_pressed() -> void:
	if current_tab == UI_TAB.SHOP:
		deselect_shop_filters()
		get_node("ShopControl/SortPanel/Panel/HBoxContainer/Button4").add_theme_stylebox_override("normal", sort_button_style)
		filter_shop(ItemData.ITEM_TYPE.UPGRADER)
	elif current_tab == UI_TAB.INVENTORY:
		deselect_inv_filters()
		get_node("InventoryControl/SortPanel/Panel/HBoxContainer/Button4").add_theme_stylebox_override("normal", sort_button_style)
		filter_inventory(ItemData.ITEM_TYPE.UPGRADER)

func _on_button_3_pressed() -> void:
	if current_tab == UI_TAB.SHOP:
		deselect_shop_filters()
		get_node("ShopControl/SortPanel/Panel/HBoxContainer/Button3").add_theme_stylebox_override("normal", sort_button_style)
		filter_shop(ItemData.ITEM_TYPE.FURNACE)
	elif current_tab == UI_TAB.INVENTORY:
		deselect_inv_filters()
		get_node("InventoryControl/SortPanel/Panel/HBoxContainer/Button3").add_theme_stylebox_override("normal", sort_button_style)
		filter_inventory(ItemData.ITEM_TYPE.FURNACE)

func _on_button_2_pressed() -> void:
	if current_tab == UI_TAB.SHOP:
		deselect_shop_filters()
		get_node("ShopControl/SortPanel/Panel/HBoxContainer/Button2").add_theme_stylebox_override("normal", sort_button_style)
		filter_shop(ItemData.ITEM_TYPE.CONVEYOR)
	elif current_tab == UI_TAB.INVENTORY:
		deselect_inv_filters()
		get_node("InventoryControl/SortPanel/Panel/HBoxContainer/Button2").add_theme_stylebox_override("normal", sort_button_style)
		filter_inventory(ItemData.ITEM_TYPE.CONVEYOR)

func _on_button_pressed() -> void:
	if current_tab == UI_TAB.SHOP:
		deselect_shop_filters()
		get_node("ShopControl/SortPanel/Panel/HBoxContainer/Button").add_theme_stylebox_override("normal", sort_button_style)
		filter_shop(ItemData.ITEM_TYPE.DROPPER)
	elif current_tab == UI_TAB.INVENTORY:
		deselect_inv_filters()
		get_node("InventoryControl/SortPanel/Panel/HBoxContainer/Button").add_theme_stylebox_override("normal", sort_button_style)
		filter_inventory(ItemData.ITEM_TYPE.DROPPER)

func deselect_shop_filters() -> void:
	for button in get_node("ShopControl/SortPanel/Panel/HBoxContainer").get_children():
		if button is Button:
			button.add_theme_stylebox_override("normal", sort_button_style_empty)

func deselect_inv_filters() -> void:
	for button in get_node("InventoryControl/SortPanel/Panel/HBoxContainer").get_children():
		if button is Button:
			button.add_theme_stylebox_override("normal", sort_button_style_empty)

func _on_cancel_pressed() -> void:
	buy_panel.visible = false

func _on_shop_selected_item_changed(id: int) -> void:
	shop_item_id = id
	var item_data: ItemData = GameData.items[id].item_data

	for c in buy_panel.get_node("MarginContainer/Panel/TextureRect/SubViewport").get_children():
		c.queue_free()
	
	icon_viewport_node = GameData.items[id].duplicate()
	icon_viewport_node.position = Vector2(16,16)
	icon_viewport_node = GameData.strip_item_node(icon_viewport_node)
	buy_panel.get_node("MarginContainer/Panel/TextureRect/SubViewport").add_child(icon_viewport_node)
	buy_panel.get_node("MarginContainer/Panel/VBoxContainer/ItemName").text = item_data.item_name
	buy_panel.get_node("MarginContainer/Panel/VBoxContainer/Price").text = "$" + str(item_data.price)
	buy_panel.visible = true

func _on_buy_pressed() -> void:
	var data: ItemData = GameData.items[shop_item_id].item_data
	if Player.data.money >= data.price:
		var item_updated = Player.data.inventory[shop_item_id]
		item_updated.quantity += 1
		Player.update_inventory_item(shop_item_id, item_updated)
		Player.data.money -= data.price

func _on_do_rebirth_button_pressed() -> void:
	var price := GameData.calc_rebirth_price(Player.data.rebirths)

	if Player.data.money >= price:
		Player.do_rebirth()
		rebirth_label.text = "[center][b] " + str(Player.data.rebirths) +" [/b] rebirths[/center]"
		rebirth_price_label.text = "Cost: 	$" + GameData.float_to_prefix(GameData.calc_rebirth_price(Player.data.rebirths))
