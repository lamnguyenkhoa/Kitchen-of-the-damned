extends Item
class_name Plate

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


func check_recipe_correct(required_foods: Array[String]) -> bool:
	if food_pos.get_child_count() == 0:
		return false
		
	var copied_required_foods = required_foods.duplicate()
	var holding_foods = food_pos.get_children()
	for food in holding_foods:
		if food is Food and food.food_name in copied_required_foods:
			copied_required_foods.erase(food.food_name)
		else:
			return false
	return true