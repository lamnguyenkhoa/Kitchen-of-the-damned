extends Interactable

@onready var chop_item_pos: Marker3D = $ChopItemPos

func interact():
    var player: FPSPlayer = GameManager.player
    if not player.is_holding_item:
        return
    var item = player.get_current_holding_item()
    if item is Food:
        var food_item = item as Food
        if food_item.chopped_prefab != null and food_item.n_chopped_spawn > 0:
            var rng = RandomNumberGenerator.new()
            rng.randomize()
            var rand_x = 0 
            var rand_z = 0
            for i in range(food_item.n_chopped_spawn):
                rand_x = rng.randf_range(-0.25, 0.25)
                rand_z = rng.randf_range(-0.25, 0.25)
                GameManager.spawn_item(food_item.chopped_prefab, chop_item_pos.global_position + Vector3(rand_x, 0, rand_z))
            player.destroy_current_holding_item()


func get_interact_label_text():
    var player: FPSPlayer = GameManager.player
    if not player.is_holding_item:
        return "Cut food (hand empty)"

    var item = player.get_current_holding_item()
    if item is Food:
        var food_item = item as Food
        if food_item.chopped_prefab != null and food_item.n_chopped_spawn > 0:
            return "Cut " + food_item.food_name
        else:
            return "Cut food (can't cut " + food_item.food_name + ")"

    return "Cut food (item not food)"