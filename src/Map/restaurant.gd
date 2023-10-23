extends Node3D

func _ready() -> void:
	ScreenTransitionManager.fade_in(1.5)
	await ScreenTransitionManager.transitioned
	GameManager.reset_state()
