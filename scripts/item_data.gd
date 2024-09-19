extends Resource
class_name ItemData

enum ITEM_TYPE {
	DROPPER,
	CONVEYOR,
    UPGRADER,
    FURNACE
}

@export var item_name: String = ""
@export var item_type: ITEM_TYPE = ITEM_TYPE.DROPPER
@export var icon: Texture2D
@export var id: int = 0