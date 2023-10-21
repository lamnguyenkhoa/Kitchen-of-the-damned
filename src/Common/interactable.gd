extends PhysicsBody3D
class_name Interactable

enum InteractableType {
    FOOD,
    FOOD_CONTAINER,
    COOKING_STATION,
    ITEM
}

@export var type: InteractableType

func interact():
    print("This object's interact() not yet implemented ", self.name)