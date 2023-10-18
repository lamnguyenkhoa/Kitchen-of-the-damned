extends Node3D
class_name PhoneButton

@onready var mesh: MeshInstance3D = $Mesh

var is_selected = false

func _input(event):
	if event.is_action_pressed("left_click") and is_selected:
		print("Pressed " + self.name)
		mesh.position = Vector3(0, 0, -0.03)
		var tween = get_tree().create_tween()
		tween.tween_property(mesh, "position", Vector3(0, 0, 0), 0.25)
		match self.name:
			"Accept":
				get_parent().get_node("Label3D").text = ""
			"Decline":
				get_parent().get_node("Label3D").text = ""

			"Up":
				return
			"Left":
				return
			"Right":
				return
			"Down":
				return
			_:
				if len(get_parent().get_node("Label3D").text) < 27:
					get_parent().get_node("Label3D").text += self.name



func _on_area_3d_mouse_entered() -> void:
	is_selected = true


func _on_area_3d_mouse_exited() -> void:
	is_selected = false