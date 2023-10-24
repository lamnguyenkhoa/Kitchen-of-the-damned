extends Node

var restaurant: Node3D
var player: FPSPlayer
var n_dish_completed = 0

const DISH_REQUIRED_TO_WIN = 2

func spawn_item(prefab: PackedScene, pos: Vector3 = Vector3(0, 0, 0)) -> Node:
	var item = prefab.instantiate()
	restaurant.add_child(item)
	item.global_position = pos
	return item


func reset_state():
	restaurant = get_tree().get_root().get_node("Restaurant")
	player = restaurant.get_node("Player")
	n_dish_completed = 0


func complete_dish():
	n_dish_completed += 1
	if n_dish_completed == DISH_REQUIRED_TO_WIN:
		player.game_win()
