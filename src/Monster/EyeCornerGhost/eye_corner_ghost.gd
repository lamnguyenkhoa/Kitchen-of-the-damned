extends Monster

@export var roam_node_group: Node3D
@export var jumpscare_sound: AudioStream
@export var ghost_mesh: MeshInstance3D
@export var roam_node_idx: int = 0

@onready var respawn_timer: Timer = $RespawnTimer
@onready var growl_sfx: AudioStreamPlayer3D = $GrowlSFX
@onready var collision_shape: CollisionShape3D = $CollisionShape3D

var roam_nodes: Array[Marker3D] = []
var despawned = true
var ghost_material: StandardMaterial3D
var can_be_seen = false

const ANGLE_THRESHOLD = 40
const DEFAULT_GHOST_MATERIAL_ALPHA = 1
const DAMAGE = 50
const RESPAWN_TIME = 15
const SAFE_SPAWN_CHECK_DISTANCE = 10

func _ready():
	despawn()
	respawn_timer.start(1)
	# Convert Array[Node] to Array[Marker3D]
	roam_nodes.assign(roam_node_group.get_children())
	# Make sure to not await during _ready.
	call_deferred("actor_setup")
	ghost_material = ghost_mesh.mesh.surface_get_material(0)


func _process(delta: float) -> void:
	if GameManager.player == null or despawned:
		return

	var monster_dir = global_position - GameManager.player.global_position
	var look_dir = GameManager.player.get_look_direction()
	var look_angle = rad_to_deg(monster_dir.angle_to(look_dir))
	if look_angle < ANGLE_THRESHOLD:
		can_be_seen = false
	else:
		can_be_seen = true
	var alpha_perc = remap(look_angle, ANGLE_THRESHOLD, 2 * ANGLE_THRESHOLD, 0.2, DEFAULT_GHOST_MATERIAL_ALPHA)
	alpha_perc = clamp(alpha_perc, 0, DEFAULT_GHOST_MATERIAL_ALPHA)
	ghost_material.albedo_color.a = alpha_perc


func _physics_process(delta):
	if despawned:
		return

	if navigation_agent.is_navigation_finished():
		roam_node_idx += 1
		if roam_node_idx >= len(roam_nodes):
			roam_node_idx = 0

	var current_agent_position: Vector3 = global_position
	var next_path_position: Vector3 = navigation_agent.get_next_path_position()

	navigation_agent.set_target_position(roam_nodes[roam_node_idx].global_position)
	var new_velocity = (next_path_position - current_agent_position).normalized() * move_speed
	velocity = new_velocity
	move_and_slide()

func actor_setup():
	# Wait for the first physics frame so the NavigationServer can sync.
	await get_tree().physics_frame
	navigation_agent.set_target_position(roam_nodes[roam_node_idx].global_position)


func _on_ghost_area_body_entered(body:Node3D) -> void:
	if despawned:
		return
		
	if body is FPSPlayer:
		GameManager.player.damaged(DAMAGE)
		SoundManager.play_sound(jumpscare_sound)
		call_deferred("despawn")



func despawn():
	despawned = true
	visible = false
	can_be_seen = false
	respawn_timer.start(RESPAWN_TIME)
	growl_sfx.stop()
	collision_shape.disabled = true


func respawn():
	despawned = false
	visible = true
	can_be_seen = true
	growl_sfx.play()
	collision_shape.disabled = false

func _on_respawn_timer_timeout() -> void:
	if GameManager.player.global_position.distance_to(global_position) < SAFE_SPAWN_CHECK_DISTANCE:
		respawn_timer.start(1)
		return

	respawn()
