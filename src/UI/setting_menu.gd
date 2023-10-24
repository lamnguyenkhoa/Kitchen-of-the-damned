extends Control

@onready var fullscreen_toggle: CheckButton = $VBoxContainer/FullscreenControl/FullscreenToggle
@onready var music_volume_slider = $VBoxContainer/BGMControl/BGM_HSlider
@onready var sfx_volume_slider = $VBoxContainer/SFXControl/SFX_HSlider
@onready var ui_sfx_volume_slider = $VBoxContainer/UIControl/UI_HSlider
@onready var mouse_sen_slider = $VBoxContainer/MouseSenControl/MouseSen_HSlider

var old_mouse_mode = Input.MOUSE_MODE_CONFINED

const MOUSE_SENSE_MODIFIER = 5000

func _ready() -> void:
	music_volume_slider.value = SoundManager.get_music_volume() * 100
	sfx_volume_slider.value = SoundManager.get_sound_volume() * 100
	ui_sfx_volume_slider.value = db_to_linear(
		AudioServer.get_bus_volume_db(AudioServer.get_bus_index("UI"))
	) * 100
	mouse_sen_slider.value = GameManager.mouse_sensitivity * MOUSE_SENSE_MODIFIER

func _input(event):
	if event.is_action_pressed("setting_menu"):
		visible = !visible
		get_tree().paused = visible
		if visible:
			old_mouse_mode = Input.mouse_mode
			Input.mouse_mode = Input.MOUSE_MODE_CONFINED
		else:
			Input.mouse_mode = old_mouse_mode


func _on_ui_h_slider_value_changed(value:float) -> void:
	var volume_between_0_and_1 = remap(value, 0, 100, 0, 1)
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("UI"),
		linear_to_db(volume_between_0_and_1)
	)

func _on_sfx_h_slider_value_changed(value:float) -> void:
	SoundManager.set_sound_volume(value / 100)


func _on_bgm_h_slider_value_changed(value:float) -> void:
	SoundManager.set_music_volume(value / 100)


func _on_fullscreen_toggle_pressed() -> void:
	# Checked = Fullscreen, Unchecked = Windowed
	var window_mode
	match fullscreen_toggle.button_pressed:
		true:
			window_mode = DisplayServer.WINDOW_MODE_FULLSCREEN
		false:
			window_mode = DisplayServer.WINDOW_MODE_WINDOWED

	DisplayServer.window_set_mode(window_mode)


func _on_close_button_pressed() -> void:
	visible = false


func _on_mouse_sen_h_slider_value_changed(value:float) -> void:
	GameManager.mouse_sensitivity = value / MOUSE_SENSE_MODIFIER
