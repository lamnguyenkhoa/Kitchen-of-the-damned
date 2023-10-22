extends Item

@onready var food_pos: Marker3D = $FoodPos

var food_total_height = 0

func interact():
	var player: FPSPlayer = GameManager.player
	if not player.is_holding_item:
		GameManager.player.pickup_item(self)

	var item = player.get_current_holding_item()
	if item is Food:
		var food_item: Food = item as Food
		var food_parent = food_item.get_parent()
		food_parent.remove_child(food_item)
		food_pos.add_child(food_item)
		food_item.position = Vector3(0, food_total_height, 0)
		food_item.process_mode = Node.PROCESS_MODE_DISABLED
		var food_height = food_item.food_mesh.get_aabb().size.y * food_item.food_mesh.scale.y
		food_total_height += food_height
		print(food_item.food_mesh.get_aabb())

		player.is_holding_item = false


func get_interact_label_text():
	var player: FPSPlayer = GameManager.player
	if not player.is_holding_item:
		return "Pick up " + item_name

	var item = player.get_current_holding_item()
	if item is Food:
		var food_item = item as Food
		return "Put " + food_item.food_name + " on plate"

	return "Put food on plate (item not food)"
