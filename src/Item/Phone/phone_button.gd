extends Node3D
class_name PhoneButton

@onready var mesh: MeshInstance3D = $Mesh

var is_selected = false
var phone: Phone

func _ready() -> void:
	phone = get_parent().get_parent()

func _input(event):
	if event.is_action_pressed("left_click") and is_selected:
		print("Pressed " + self.name)
		mesh.position = Vector3(0, 0, -0.03)
		var tween = get_tree().create_tween()
		tween.tween_property(mesh, "position", Vector3(0, 0, 0), 0.25)
		match self.name:
			"Accept":
				phone.screen_label.text = ""
			"Decline":
				phone.screen_label.text = ""
			"Up":
				return
			"Left":
				return
			"Right":
				return
			"Down":
				return
			"10":
				add_character_to_screen("*")
			"11":
				add_character_to_screen("0")
			"12":
				add_character_to_screen("#")
			_:
				add_character_to_screen(self.name)

func add_character_to_screen(character: String):
	if phone.battery <= 0:
		return

	if len(phone.screen_label.text) >= 18:
		phone.screen_label.text = phone.screen_label.text.erase(0, 1)
	phone.screen_label.text += character

func _on_area_3d_mouse_entered() -> void:
	is_selected = true

func _on_area_3d_mouse_exited() -> void:
	is_selected = false
