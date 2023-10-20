extends Node

var restaurant: Node3D
var player: FPSPlayer

func _ready() -> void:
	restaurant = get_tree().get_root().get_node("Restaurant")
	player = restaurant.get_node("Player")


func spawn_item(prefab: PackedScene, pos: Vector3 = Vector3(0, 0, 0)) -> Node:
	var item = prefab.instantiate()
	restaurant.add_child(item)
	item.global_position = pos
	return item

