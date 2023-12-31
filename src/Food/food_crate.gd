extends Interactable
class_name FoodCrate

@export var food_gave: PackedScene
@export var food_name: String

func interact():
    if not GameManager.player.is_holding_item:
        var food_instance = GameManager.spawn_item(food_gave)
        GameManager.player.pickup_item(food_instance)

func get_interact_label_text():
    var player: FPSPlayer = GameManager.player
    if player.is_holding_item:
        return "Take " + food_name + " (hand full)"
    return "Take " + food_name
