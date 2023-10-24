extends Node3D

@onready var setting_menu = $CanvasLayer/SettingMenu

@export var scene_after_start: PackedScene

var started = false

func _ready():
	ScreenTransitionManager.fade_in(0.8)
	await ScreenTransitionManager.transitioned


func _on_settings_button_pressed():
	setting_menu.visible = true


func _on_quit_button_pressed():
	ScreenTransitionManager.fade_out(0.8)
	await ScreenTransitionManager.transitioned
	get_tree().quit()


func _on_start_button_pressed():
	if started:
		return

	started = true
	ScreenTransitionManager.fade_out(0.8)
	await ScreenTransitionManager.transitioned
	get_tree().change_scene_to_packed(scene_after_start)
