extends CharacterBody3D
class_name FPSPlayer

@export var phone: Phone

@onready var aim_ray: RayCast3D = $Head/Camera3d/RayCast3d
@onready var camera: Camera3D = $Head/Camera3d
@onready var item_hold_pos: Marker3D = $Head/Camera3d/ItemHoldPos
@onready var phone_hold_pos: Marker3D = $Head/Camera3d/PhoneHoldPos
@onready var phone_inspect_pos: Marker3D = $Head/Camera3d/PhoneInspectPos
@onready var phone_holder = $Head/Camera3d/PhoneHolder
@onready var flashlight: SpotLight3D = $Head/Camera3d/Flashlight

@onready var interact_label = $CanvasLayer/InteractLabel

var mouse_sensibility = 1500
var mouse_relative_x = 0
var mouse_relative_y = 0
var is_inspecting = false
var is_holding_item = false
var looked_at_collider: Object = null
var looked_at_collider_idx: int = 0

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const THROW_STRENGTH = 15

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	#Captures mouse and stops rgun from hitting yourself
	aim_ray.add_exception(self)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	if Input.is_action_just_pressed("inspect_item"):
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
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	# Look at pickup-able item
	if aim_ray.is_colliding():
		looked_at_collider = aim_ray.get_collider()
		looked_at_collider_idx = aim_ray.get_collider_shape()
		if looked_at_collider is Interactable:
			var interactable = looked_at_collider as Interactable
			interact_label.visible = true
			if Input.is_action_just_pressed("pickup"):
				interactable.interact()
		else:
			interact_label.visible = false
			looked_at_collider = null
	else:
		interact_label.visible = false
		looked_at_collider = null

	if Input.is_action_just_pressed("drop") and is_holding_item:
		drop_item()

	if Input.is_action_just_pressed("throw") and is_holding_item:
		throw_item()

	if Input.is_action_just_pressed("flashlight_toggle"):
		toggle_flashlight()

	move_and_slide()

func _input(event):
	if event is InputEventMouseMotion and not is_inspecting:
		rotation.y -= event.relative.x / mouse_sensibility
		camera.rotation.x -= event.relative.y / mouse_sensibility
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90) )
		mouse_relative_x = clamp(event.relative.x, -50, 50)
		mouse_relative_y = clamp(event.relative.y, -50, 10)


func toggle_flashlight():
	flashlight.visible = !flashlight.visible
	phone.flashlight_icon.visible = flashlight.visible


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
