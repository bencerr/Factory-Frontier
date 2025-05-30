extends Control

@export var name_label: Label
@export var stat_label: Label
@export var panel: Panel
var placed_item_id: int
var tween: Tween

func update() -> void:
	var placed_item_data: PlacedItemData = Player.data.placed_items[placed_item_id]
	var item_info: PlayerItemInfo = Player.data.inventory[placed_item_data.item_index]
	name_label.text = GameData.items[item_info.item_id].item_data.name
	stat_label.text = GameData.get_item_stats(placed_item_data.item_index)

func vfx_in(control: Control) -> void:
	if tween:
		return

	var orginal_pos = control.position
	control.position = Vector2(-control.size.x, orginal_pos.y)
	tween = control.create_tween().set_trans(Tween.TRANS_SINE)

	tween.tween_property(control, "position", orginal_pos, .325)
	tween.tween_callback(func():
		if tween:
			tween = null)
	tween.play()

func show_item_info(id: int):
	position = get_global_mouse_position()
	placed_item_id = id
	update()
	show()
	vfx_in(panel)

func _on_close_pressed() -> void:
	hide()

func _on_rotate_pressed() -> void:
	Player.data.placed_items[placed_item_id].rotation += deg_to_rad(90)
	Player.data.placed_items[placed_item_id].instance.rotation = Player.data.placed_items[
		placed_item_id
	].rotation

