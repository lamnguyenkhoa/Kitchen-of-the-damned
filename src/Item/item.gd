extends Interactable
class_name Item

@export var item_name: String

func interact():
    GameManager.player.pickup_item(self)

func get_interact_label_text():
    return "Pick up " + item_name
