extends Control
enum UI_TAB {
	NONE,
	SHOP,
	INVENTORY
}

@export var shop_panel: Control
@export var inv_panel: Control

var current_tab: UI_TAB = UI_TAB.NONE

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
