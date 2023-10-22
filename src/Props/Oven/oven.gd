extends Interactable
class_name Oven

@onready var baked_item_pos: Marker3D = $BakeItemPos
@onready var oven_light: OmniLight3D = $OmniLight3D
@onready var oven_timer: Timer = $OvenTimer

@export var oven_door: OvenDoor

enum OvenState {
	EMPTY,
	HAS_FOOD,
	IS_COOKING,
	COOKED
}

var current_oven_state: OvenState = OvenState.EMPTY

func interact():
	var player: FPSPlayer = GameManager.player
	if not player.is_holding_item or not oven_door.is_open:
		return

	var item = player.get_current_holding_item()
	if item is Food:
		var food_item = item as Food
		if food_item.baked_prefab != null:
			GameManager.spawn_item(food_item.baked_prefab, baked_item_pos.global_position)
			player.destroy_current_holding_item()


func get_interact_label_text():
	if not oven_door.is_open:
		return ""

	var player: FPSPlayer = GameManager.player
	if not player.is_holding_item:
		return "Bake food (hand empty)"

	var item = player.get_current_holding_item()
	if item is Food:
		var food_item = item as Food
		return "Bake " + food_item.food_name

	return "Bake food (item not food)"
