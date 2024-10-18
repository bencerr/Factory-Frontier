extends Control
class_name MainInterface
enum UI_TAB {
	NONE,
	SHOP,
	INVENTORY
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

@onready var input_handler: InputHandler = Player.input_handler
var current_tab: UI_TAB = UI_TAB.NONE
var sort_button_style: Resource
var sort_button_style_empty: Resource

func _on_input_type_changed(input_typ: InputHandler.INPUT_TYPE) -> void:
	match input_typ:
		InputHandler.INPUT_TYPE.CAMERA:
			placement_control.visible = false
		InputHandler.INPUT_TYPE.PLACEMENT:
			placement_control.update()
			placement_control.visible = true

func refresh_inventory() -> void:
	var template: PackedScene = load("res://scenes/ui/item.tscn")
	for key in Player.data.inventory.keys():
		var control: UI_Item = template.instantiate()
		control.item_id = key
		inv_container.add_child(control)

func load_shop() -> void:
	var template: PackedScene = load("res://scenes/ui/shop_item.tscn")
	for key in GameData.items.keys():
		var control: Shop_UI_Item = template.instantiate()
		control.item_id = key
		shop_container.add_child(control)

func filter_shop(item_type: ItemData.ITEM_TYPE) -> void:
	for shop_ui_itm: Shop_UI_Item in shop_container.get_children():
		if GameData.items[shop_ui_itm.item_id].item_data.item_type == item_type:
			shop_ui_itm.visible = true
		else:
			shop_ui_itm.visible = false

func filter_inventory(item_type: ItemData.ITEM_TYPE) -> void:
	for ui_item: UI_Item in inv_container.get_children():
		if GameData.items[ui_item.item_id].item_data.item_type == item_type:
			ui_item.visible = true
		else:
			ui_item.visible = false
 
func switch_tab(tab: UI_TAB) -> void:
	if current_tab == tab:
		current_tab = UI_TAB.NONE
	else:
		current_tab = tab
	
	match current_tab:
		UI_TAB.NONE:
			shop_panel.visible = false
			inv_panel.visible = false
		UI_TAB.SHOP:
			shop_panel.visible = true
			inv_panel.visible = false
			input_handler.disable_placing()
		UI_TAB.INVENTORY:
			shop_panel.visible = false
			inv_panel.visible = true
			input_handler.disable_placing()

func _on_inventory_button_pressed() -> void:
	switch_tab(UI_TAB.INVENTORY)

func _on_shop_button_pressed() -> void:
	switch_tab(UI_TAB.SHOP)

func _ready() -> void:
	sort_button_style = load("res://resources/sort_button_selected.tres")
	sort_button_style_empty = load("res://resources/empty_style_box.tres")
	Player.input_handler.input_type_changed.connect(_on_input_type_changed)
	refresh_inventory()
	Player.money_changed.connect(_on_money_change)
	shop_selected_item_changed.connect(_on_shop_selected_item_changed)
	_on_money_change(0)
	load_shop()

func _on_money_change(_value: float) -> void:
	money_label.text = "$" + GameData.float_to_string(Player.data.money)

func _on_delete_button_pressed() -> void:
	if Player.input_handler.current_input_type == InputHandler.INPUT_TYPE.DELETE:
		input_handler.disable_deleting()
	else:
		input_handler.enable_deleting()
		placement_control.visible = false
		switch_tab(UI_TAB.NONE)

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
	buy_panel.get_node("MarginContainer/Panel/TextureRect").texture = item_data.icon
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
