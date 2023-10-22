extends Interactable
class_name OvenDoor

@export var anim_player: AnimationPlayer

var is_open = false

func interact():
    if not anim_player.is_playing():
        if is_open:
            anim_player.play("close_door")
            is_open = false
        else:
            anim_player.play("open_door")
            is_open = true

func get_interact_label_text():
    if is_open:
        return "Close oven"
    else:
        return "Open oven"