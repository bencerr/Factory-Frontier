extends Resource
class_name ItemData

enum ITEM_TYPE {
	DROPPER,
	CONVEYOR,
	UPGRADER,
	FURNACE
}

enum RARITY {
	COMMON,
	REBIRTH
}

var id: int
var name: String # get_name()

@export var item_type: ITEM_TYPE = ITEM_TYPE.DROPPER
@export var price: float = 0
@export var rarity: RARITY = RARITY.COMMON