extends Control

func _ready():
	if OS.has_feature("mobile"):
		show()
	else:
		hide()

func _on_pause_pressed():
	Input.action_press("pause")
	Input.action_release("pause")

func _on_device_pressed():
	Input.action_press("device")
	Input.action_release("device")

func _on_item_pressed():
	Input.action_press("useItem")
	Input.action_release("useItem")

func _on_left_pressed():
	Input.action_press("left")

func _on_down_pressed():
	Input.action_press("down")

func _on_right_pressed():
	Input.action_press("right")

func _on_up_pressed():
	Input.action_press("up")

func _on_interact_pressed():
	Input.action_press("interact")
	Input.action_release("interact")

func _on_sprint_pressed():
	Input.action_press("sprint")

func _on_left_button_up():
	Input.action_release("left")

func _on_down_button_up():
	Input.action_release("down")

func _on_right_button_up():
	Input.action_release("right")

func _on_up_button_up():
	Input.action_release("up")

func _on_sprint_button_up():
	Input.action_release("sprint")
