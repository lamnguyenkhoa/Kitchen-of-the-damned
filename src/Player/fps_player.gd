extends CharacterBody3D
class_name FPSPlayer

@export var phone: Phone

@onready var aim_ray: RayCast3D = $Head/Camera3d/RayCast3d
@onready var camera: Camera3D = $Head/Camera3d
@onready var item_hold_pos: Marker3D = $Head/Camera3d/ItemHoldPos
@onready var phone_hold_pos: Marker3D = $Head/Camera3d/PhoneHoldPos
@onready var phone_inspect_pos: Marker3D = $Head/Camera3d/PhoneInspectPos
@onready var phone_holder = $Head/Camera3d/PhoneHolder
@onready var head = $Head
@onready var stand_collision: CollisionShape3D = $StandCollision
@onready var crouch_collision: CollisionShape3D = $CrouchCollision
@onready var footstep_sfx: AudioStreamPlayer3D = $FootstepSFX

@onready var interact_label: Label = $CanvasLayer/InteractLabel
@onready var slash_vfx: TextureRect = $CanvasLayer/Slash
@onready var screen_flash: TextureRect = $CanvasLayer/ScreenFlash
@onready var control_label: Label = $CanvasLayer/ControlLabel
@onready var gameover_screen = $CanvasLayer/GameoverScreen
@onready var win_screen = $CanvasLayer/WinScreen



var mouse_sensibility = 1500
var mouse_relative_x = 0
var mouse_relative_y = 0
var is_inspecting = false
var looked_at_collider: Object = null
var looked_at_collider_idx: int = 0
var is_crouching = false
var current_movespeed = 0
var died = false

var is_holding_item = false :
	set(value):
		is_holding_item = value
		update_control_label()

const BASE_SPEED = 5.0
const CROUCH_SPEED_MUL_MODIFIER = 0.5
const JUMP_VELOCITY = 4.5
const THROW_STRENGTH = 15
const CROUCH_SOUND_DB = -30

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	#Captures mouse and stops rgun from hitting yourself
	aim_ray.add_exception(self)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	update_control_label()

	footstep_sfx.play()
	footstep_sfx.stream_paused = true


func _physics_process(delta):
	if died:
		return

	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	if Input.is_action_just_pressed("inspect_item") and phone_holder.get_child_count() == 1:
		var tween = get_tree().create_tween()
		if not is_inspecting:
			is_inspecting = true
			tween.tween_property(phone_holder, "position", phone_inspect_pos.position, 0.25)
			Input.mouse_mode = Input.MOUSE_MODE_CONFINED
		else:
			is_inspecting = false
			tween.tween_property(phone_holder, "position", phone_hold_pos.position, 0.25)
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	# Get the input direction and handle the movement/deceleration.
	current_movespeed = BASE_SPEED
	if is_crouching:
		current_movespeed *= CROUCH_SPEED_MUL_MODIFIER

	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * current_movespeed
		velocity.z = direction.z * current_movespeed
	else:
		velocity.x = move_toward(velocity.x, 0, current_movespeed)
		velocity.z = move_toward(velocity.z, 0, current_movespeed)

	if velocity.length_squared() == 0:
		footstep_sfx.stream_paused = true
	else:
		footstep_sfx.stream_paused = false

	if not is_on_floor():
		footstep_sfx.stream_paused = true

	# Look at pickup-able item
	if aim_ray.is_colliding() and not is_inspecting:
		looked_at_collider = aim_ray.get_collider()
		looked_at_collider_idx = aim_ray.get_collider_shape()
		if looked_at_collider is Interactable:
			var interactable = looked_at_collider as Interactable
			interact_label.text = interactable.get_interact_label_text()
			interact_label.visible = true
			if Input.is_action_just_pressed("interact"):
				interactable.interact()
		else:
			interact_label.visible = false
			looked_at_collider = null
	else:
		interact_label.visible = false
		looked_at_collider = null

	if Input.is_action_just_pressed("drop") and is_holding_item and not is_inspecting:
		drop_item()

	if Input.is_action_just_pressed("throw") and is_holding_item and not is_inspecting:
		throw_item()

	if Input.is_action_just_pressed("flashlight_toggle") and phone_holder.get_child_count() == 1:
		phone.toggle_flashlight()

	if Input.is_action_just_pressed("crouch"):
		crouch()


	move_and_slide()

func _input(event):
	if died:
		return

	if event is InputEventMouseMotion and not is_inspecting:
		rotation.y -= event.relative.x / mouse_sensibility
		camera.rotation.x -= event.relative.y / mouse_sensibility
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90) )
		mouse_relative_x = clamp(event.relative.x, -50, 50)
		mouse_relative_y = clamp(event.relative.y, -50, 10)


func crouch():
	var tween = get_tree().create_tween()
	if is_crouching:
		tween.tween_property(head, "position:y", 0, 0.25)
		stand_collision.disabled = false
		crouch_collision.disabled = true
		is_crouching = false
		footstep_sfx.volume_db = 0
	else:
		tween.tween_property(head, "position:y", -0.7, 0.25)
		stand_collision.disabled = true
		crouch_collision.disabled = false
		is_crouching = true
		footstep_sfx.volume_db = CROUCH_SOUND_DB

func get_look_direction() -> Vector3:
	var direction = -camera.get_global_transform().basis.z
	return direction


func get_current_looking_collision_shape():
	if looked_at_collider != null:
		var hit_node = looked_at_collider.shape_owner_get_owner(looked_at_collider_idx)
		return hit_node
	else:
		return null


func get_current_holding_item():
	if is_holding_item:
		return item_hold_pos.get_child(0)
	else:
		return null

func throw_item():
	var item = item_hold_pos.get_child(0)
	if item is RigidBody3D:
		var item_to_throw = drop_item() as RigidBody3D
		var direction = -camera.get_global_transform().basis.z
		item_to_throw.apply_central_impulse(direction * THROW_STRENGTH)
		return item_to_throw
	return null


func drop_item() -> Node:
	var item = item_hold_pos.get_child(0)
	var item_pos = item.global_position
	item_hold_pos.remove_child(item)
	GameManager.restaurant.add_child(item)
	item.process_mode = Node.PROCESS_MODE_INHERIT
	item.global_position = item_pos
	is_holding_item = false
	return item

func pickup_item(collider: Node3D) -> Node:
	if is_holding_item:
		drop_item()
	var item_parent = collider.get_parent()
	item_parent.remove_child(collider)
	item_hold_pos.add_child(collider)
	collider.position = Vector3(0, 0, 0)
	collider.process_mode = Node.PROCESS_MODE_DISABLED
	is_holding_item = true
	return collider

func destroy_current_holding_item():
	if not is_holding_item:
		return
	var item = drop_item()
	item.queue_free()

func update_control_label():
	control_label.text = "E: Interact | C: Crouch"
	if phone_holder.get_child_count() == 1:
		control_label.text += " | Tab: Phone | F: Flashlight"
	if is_holding_item:
		control_label.text += " | G: Drop | LMB: Throw"


func damaged(amount: int):
	if died:
		return

	screen_flash.modulate = Color(1, 0, 0, 0.3)
	var tween2 = get_tree().create_tween()
	tween2.tween_property(screen_flash, "modulate:a", 0, 2)

	slash_vfx.modulate.a = 1
	var tween = get_tree().create_tween()
	tween.tween_property(slash_vfx, "modulate:a", 0.8, 1)
	tween.tween_property(slash_vfx, "modulate:a", 0, 2)

	# If phone don't have battery anymore (or don't have phone) to protect you,
	# you die next hit
	if phone.battery <= 0 or phone_holder.get_child_count() == 0:
		game_over()
	phone.battery -= amount


func game_over():
	print("GameOver")
	var tween = get_tree().create_tween()
	tween.tween_property(gameover_screen, "modulate:a", 1, 2)
	interact_label.visible = false
	died = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func game_win():
	print("GameWin")
	var tween = get_tree().create_tween()
	tween.tween_property(win_screen, "modulate:a", 1, 2)
	interact_label.visible = false
	died = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _on_retry_button_pressed() -> void:
	ScreenTransitionManager.fade_out(0.7)
	await ScreenTransitionManager.transitioned
	await get_tree().create_timer(0.6).timeout
	get_tree().reload_current_scene()
