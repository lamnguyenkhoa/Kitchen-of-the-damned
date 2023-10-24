extends Node

@onready var eye_corner_ghost_timer: Timer = $RespawnEyeCornerGhostTimer

var restaurant: Node3D
var player: FPSPlayer
var eye_corner_ghost: Monster
var n_dish_completed = 0

const SAFE_SPAWN_CHECK_DISTANCE = 10
const EYE_CORNER_GHOST_RESPAWN_TIME = 15
const DISH_REQUIRED_TO_WIN = 2

func spawn_item(prefab: PackedScene, pos: Vector3 = Vector3(0, 0, 0)) -> Node:
	var item = prefab.instantiate()
	restaurant.add_child(item)
	item.global_position = pos
	return item

func despawn_eye_corner_ghost():
	eye_corner_ghost.despawned = true
	eye_corner_ghost.visible = false
	eye_corner_ghost.can_be_seen = false
	eye_corner_ghost.process_mode = Node.PROCESS_MODE_DISABLED
	eye_corner_ghost_timer.start(EYE_CORNER_GHOST_RESPAWN_TIME)

func _on_respawn_eye_corner_ghost_timer_timeout() -> void:
	# If player too close to spawn pos, wait for 1 sec before retry
	if player.global_position.distance_to(eye_corner_ghost.global_position) < SAFE_SPAWN_CHECK_DISTANCE:
		eye_corner_ghost_timer.start(1)
		return

	eye_corner_ghost.despawned = false
	eye_corner_ghost.visible = true
	eye_corner_ghost.can_be_seen = true
	eye_corner_ghost.process_mode = Node.PROCESS_MODE_INHERIT


func reset_state():
	restaurant = get_tree().get_root().get_node("Restaurant")
	player = restaurant.get_node("Player")
	eye_corner_ghost = restaurant.get_node("EyeCornerGhost")
	eye_corner_ghost_timer.stop()
	despawn_eye_corner_ghost()
	eye_corner_ghost_timer.start(1)
	n_dish_completed = 0


func complete_dish():
	n_dish_completed += 1
	if n_dish_completed == DISH_REQUIRED_TO_WIN:
		player.game_win()
