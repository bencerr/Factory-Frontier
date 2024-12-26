extends Control

@export var image: TextureRect
@export var viewport: SubViewport
@export var label: RichTextLabel

func play(item_id: int) -> void:
	scale = Vector2(0,0)
	modulate = Color.TRANSPARENT
	
	label.text = ""
	var node = GameData.items[item_id].duplicate()
	node.position = viewport.size/2
	node = GameData.strip_item_node(node)
	
	if viewport.get_child_count() >= 1:
		viewport.remove_child(viewport.get_child(0))
	
	viewport.add_child(node)

	var control_tween = self.create_tween().set_parallel(true)
	control_tween.tween_property(self, "scale", Vector2(1,1), .2)
	control_tween.tween_property(self, "modulate", Color.WHITE, .2)

	image.scale = Vector2.ZERO
	image.modulate = Color.TRANSPARENT
	var image_tween = image.create_tween().set_trans(Tween.TRANS_QUAD).set_parallel(true)
	image_tween.tween_property(image, "scale", Vector2(1,1), 1).set_delay(1)
	image_tween.tween_property(image, "modulate", Color.WHITE, 1).set_delay(1)
	image_tween.finished.connect(func():
		label.text = "[center] You got a [b]%s[/b] from rebirthing![/center]" % GameData.items[item_id].item_data.item_name
	)

	control_tween.chain().tween_property(self, "modulate", Color.TRANSPARENT, 2).set_delay(5)
	
	await control_tween.finished
	
	scale = Vector2(0,0)
	modulate = Color.TRANSPARENT

func _ready() -> void:
	scale = Vector2(0,0)
	modulate = Color.TRANSPARENT
	Player.rebirthed.connect(play)

