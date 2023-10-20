extends PhysicsBody3D
class_name Interactable

enum InteractableType {
    FOOD,
    FOOD_CRATE,
    ITEM
}

@export var type: InteractableType

func interact():
    print("This object's interact() not yet implemented ", self.name)