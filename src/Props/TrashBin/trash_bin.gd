extends Interactable

func interact():
    var player: FPSPlayer = GameManager.player
    if not player.is_holding_item:
        return
    var item = player.get_current_holding_item()
    if item is Food:
        var food_item = item as Food
        player.destroy_current_holding_item()


func get_interact_label_text() -> String:
    var player: FPSPlayer = GameManager.player
    if not player.is_holding_item:
        return "Discard food (hand empty)"

    var item = player.get_current_holding_item()
    if item is Food:
        var food_item = item as Food
        return "Discard " + food_item.food_name

    return "Discard food (item not food)"