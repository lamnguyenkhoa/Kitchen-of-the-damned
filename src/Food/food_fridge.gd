extends Interactable
class_name FoodFridge

@export var food_gave: PackedScene

@onready var anim_player: AnimationPlayer = $AnimationPlayer

var is_open = false

func interact():
	var hit_node = GameManager.player.get_current_looking_collision_shape()
	if hit_node.name == "DoorCollision":
		if not anim_player.is_playing():
			if is_open:
				anim_player.play("close_door")
				is_open = false
			else:
				anim_player.play("open_door")
				is_open = true
	elif hit_node.name == "BodyCollision":
		if not GameManager.player.is_holding_item and is_open:
			var food_instance = GameManager.spawn_item(food_gave)
			GameManager.player.pickup_item(food_instance)
	else:
		print("Unexpected collision detect bug in food_fridge.gd")

