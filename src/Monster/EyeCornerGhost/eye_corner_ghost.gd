extends Monster

@export var roam_node_group: Node3D

var roam_nodes: Array[Marker3D] = []
var roam_node_idx = 0

const ANGLE_THRESHOLD = 48

func _ready():
	# Convert Array[Node] to Array[Marker3D]
	roam_nodes.assign(roam_node_group.get_children())
	# Make sure to not await during _ready.
	call_deferred("actor_setup")

func _process(delta: float) -> void:
	var monster_dir = global_position - GameManager.player.global_position
	var look_dir = GameManager.player.get_look_direction()
	var look_angle = rad_to_deg(monster_dir.angle_to(look_dir))
	if look_angle < ANGLE_THRESHOLD:
		visible = false
	else:
		visible = true

func _physics_process(delta):
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



