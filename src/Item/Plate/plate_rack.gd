extends Interactable

@export var plate_prefab: PackedScene

func interact():
    if not GameManager.player.is_holding_item:
        var plate_instance = GameManager.spawn_item(plate_prefab)
        GameManager.player.pickup_item(plate_instance)

func get_interact_label_text():
    var player: FPSPlayer = GameManager.player
    if player.is_holding_item:
        return "Take plate (hand full)"
    return "Take plate"

