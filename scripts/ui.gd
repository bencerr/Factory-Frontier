extends Control
class_name MainInterface
enum UI_TAB {
	NONE,
	SHOP,
	INVENTORY
}

@export var shop_panel: Control
@export var inv_panel: Control
@export var inv_container: Control
@export var placement_control: Control

var current_tab: UI_TAB = UI_TAB.NONE

func _on_input_type_changed(input_typ: InputHandler.INPUT_TYPE) -> void:
	match input_typ:
		InputHandler.INPUT_TYPE.CAMERA:
			placement_control.visible = false
		InputHandler.INPUT_TYPE.PLACEMENT:
			placement_control.update()
			placement_control.visible = true

func refresh_inventory() -> void:
	var template: PackedScene = load("res://scenes/ui/item.tscn")
	for item_data in Player.data.inventory:
		var control: UI_Item = template.instantiate()
		control.item_name = item_data.item_name
		inv_container.add_child(control)
 
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
		UI_TAB.INVENTORY:
			shop_panel.visible = false
			inv_panel.visible = true

func _on_inventory_button_pressed() -> void:
	switch_tab(UI_TAB.INVENTORY)

func _on_shop_button_pressed() -> void:
	switch_tab(UI_TAB.SHOP)

func _ready() -> void:
	Player.input_handler.input_type_changed.connect(_on_input_type_changed)
	refresh_inventory()
