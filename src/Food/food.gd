extends Interactable
class_name Food

@export var food_name: String
@export var chopped_prefab: PackedScene
@export var n_chopped_spawn: int
@export var baked_prefab: PackedScene

func interact():
    GameManager.player.pickup_item(self)


func get_interact_label_text():
    return "Pick up " + food_name
