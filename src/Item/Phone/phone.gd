extends Node3D
class_name Phone

@onready var screen_label: Label3D = $ScreenLabel
@onready var transcript_label: Label3D = $CallTranscript
@onready var time_label: Label3D = $TimeLabel
@onready var flashlight_icon: Sprite3D = $FlashlightIcon
@onready var battery_label: Label3D = $BatteryLabel
@onready var phone_light: OmniLight3D = $PhoneLight
@onready var flash_light: SpotLight3D = $Flashlight

@onready var flashlight_battery_timer: Timer = $FlashlightBatteryTimer

var battery: int = 100 :
	set(value):
		battery = clamp(value, 0, MAX_BATTERY)
		battery_label.text = str(battery) + "%"
		if battery == 0:
			no_battery_shutdown()
		else:
			if phone_light.visible == false:
				has_battery_startup()

const MAX_BATTERY = 100

func _ready() -> void:
	battery = 2
	battery_label.text = str(battery) + "%"
	flashlight_battery_timer.start()

func toggle_flashlight(force_off: bool = false):
	# Return whether toggle success or not
	if force_off:
		flashlight_icon.visible = false
		flashlight_battery_timer.paused =true
		flash_light.visible = false
		return

	if flashlight_icon.visible:
		# Want to turn off
		flashlight_icon.visible = false
		flashlight_battery_timer.paused = true
		flash_light.visible = false
	else:
		# Want to turn on
		if battery > 0:
			flashlight_icon.visible = true
			flashlight_battery_timer.paused = false
			flash_light.visible = true

func no_battery_shutdown():
	phone_light.visible = false
	flashlight_icon.visible = false
	flash_light.visible = false
	battery_label.visible = false
	time_label.visible = false
	screen_label.text = ""
	transcript_label.visible = false
	flashlight_battery_timer.paused = true

func has_battery_startup():
	phone_light.visible = true
	battery_label.visible = true
	time_label.visible = true
	transcript_label.visible = true

func _on_flashlight_battery_timer_timeout() -> void:
	battery -= 1

