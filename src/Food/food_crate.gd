extends Interactable
class_name FoodCrate

@export var food_gave: PackedScene

func interact():
    if not GameManager.player.is_holding_item:
        var food_instance = GameManager.spawn_item(food_gave)
        GameManager.player.pickup_item(food_instance)
