extends Interactable
class_name ElectricSocket

@onready var charge_phone_timer: Timer = $ChargePhoneTimer
@onready var phone_holder: Marker3D = $PhoneHolder

var phone: Phone = null

const PHONE_BATTERY_PER_SEC = 2

func interact():
	if GameManager.player.phone_holder.get_child_count() == 1:
		charge_phone_timer.start()
		phone = GameManager.player.phone
		var phone_parent = phone.get_parent()
		phone_parent.remove_child(phone)
		phone_holder.add_child(phone)
		phone.position = Vector3(0, 0, 0)
		# Force player stop inspect and turn off flashlight
		GameManager.player.is_inspecting = false
		GameManager.player.phone_holder.position = GameManager.player.phone_hold_pos.position
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		phone.toggle_flashlight(true)
	elif phone != null:
		charge_phone_timer.stop()
		var phone_parent = phone.get_parent()
		phone_parent.remove_child(phone)
		GameManager.player.phone_holder.add_child(phone)
		phone.position = Vector3(0, 0, 0)
		phone = null
	GameManager.player.update_control_label()


func get_interact_label_text() -> String:
	if GameManager.player.phone_holder.get_child_count() == 1:
		return "Charge your phone"
	elif phone != null:
			return "Take your phone"
	return "Charge your phone (you don't have phone)"


func _on_charge_phone_timer_timeout() -> void:
	if phone != null:
		phone.battery += PHONE_BATTERY_PER_SEC
	else:
		print("Error, phone null in electric_socket")

