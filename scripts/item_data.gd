class_name ItemData
extends Resource

enum ITEMTYPE {
	DROPPER,
	CONVEYOR,
	UPGRADER,
	FURNACE
}

enum RARITY {
	COMMON,
	REBIRTH
}

@export var item_type: ITEMTYPE = ITEMTYPE.DROPPER
@export var price: float = 0
@export var rarity: RARITY = RARITY.COMMON

var id: int
# name = resource_name
var name: String
