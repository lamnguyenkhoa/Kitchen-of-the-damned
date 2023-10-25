extends Interactable

func interact():
    if GameManager.n_dish_completed == GameManager.DISH_REQUIRED_TO_WIN:
        GameManager.player.game_win()

func get_interact_label_text() -> String:
    if GameManager.n_dish_completed == GameManager.DISH_REQUIRED_TO_WIN:
        return "Leave the damned kitchen"
    return "You can't leave yet"
