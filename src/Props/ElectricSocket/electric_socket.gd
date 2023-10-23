extends Interactable
class_name ElectricSocket

@onready var charge_phone_timer: Timer = $ChargePhoneTimer
@onready var phone_holder: Marker3D = $PhoneHolder

var phone: Phone = null

const PHONE_BATTERY_PER_SEC = 5

func interact():
	if phone_holder.get_child_count() == 0:
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
	else:
		charge_phone_timer.stop()
		var phone_parent = phone.get_parent()
		phone_parent.remove_child(phone)
		GameManager.player.phone_holder.add_child(phone)
		phone.position = Vector3(0, 0, 0)
		phone = null

func get_interact_label_text() -> String:
	if phone_holder.get_child_count() == 0:
		return "Charge your phone"
	else:
		return "Take your phone"


func _on_charge_phone_timer_timeout() -> void:
	if phone != null:
		phone.battery += PHONE_BATTERY_PER_SEC
	else:
		print("Error, phone null in electric_socket")

