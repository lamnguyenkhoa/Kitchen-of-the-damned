extends Node3D

@onready var roof = $Roof

func _ready() -> void:
	GameManager.reset_state()
	ScreenTransitionManager.fade_in(0.5)
	await ScreenTransitionManager.transitioned
