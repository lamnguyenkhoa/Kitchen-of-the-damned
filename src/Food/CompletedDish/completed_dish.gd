extends Interactable

@export var completed_dish_name: String

@onready var mesh_holder = $MeshHolder
@onready var actual_plate_holder = $ActualPlateHolder
@onready var food_for_check = $FoodForCheck

var required_foods: Array[String] = []
var completed = false

func _ready() -> void:
	for food in food_for_check.get_children():
		if food is Food:
			required_foods.append(food.food_name)


func interact():
	if completed:
		return

	var player: FPSPlayer = GameManager.player
	if not player.is_holding_item:
		return

	var item = player.get_current_holding_item()
	if item is Plate:
		var plate_item = item as Plate
		if plate_item.check_recipe_correct(required_foods):
			var plate_parent = plate_item.get_parent()
			plate_parent.remove_child(plate_item)
			actual_plate_holder.add_child(plate_item)
			plate_item.position = Vector3(0, 0, 0)
			plate_item.process_mode = Node.PROCESS_MODE_DISABLED
			player.is_holding_item = false
			mesh_holder.visible = false
			completed = true
			GameManager.complete_dish()


func get_interact_label_text() -> String:
	if completed:
		return "You completed " + completed_dish_name

	var player: FPSPlayer = GameManager.player
	if not player.is_holding_item:
		return "Complete " + completed_dish_name + " (hand empty)"

	var item = player.get_current_holding_item()
	if item is Plate:
		var plate_item = item as Plate
		if plate_item.check_recipe_correct(required_foods):
			return "Complete " + completed_dish_name

	return "Complete " + completed_dish_name + " (incorrect result)"
