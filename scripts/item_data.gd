extends Resource
class_name ItemData

enum ITEM_TYPE {
	DROPPER,
	CONVEYOR,
	UPGRADER,
	FURNACE
}

var id: int

@export var item_name: String = ""
@export var item_type: ITEM_TYPE = ITEM_TYPE.DROPPER
@export var price: float = 0
@export var icon: Texture2D