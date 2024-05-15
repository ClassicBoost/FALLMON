extends Node2D

# Called when the node enters the scene tree for the first time.
var wait:float = 0
func _ready():
	preload("res://source/fallmon/scenes/game/Main_Menu.tscn").instantiate()

func _process(delta):
	wait += 1 * delta
	
	if wait >= 1 and wait < 3:
		$ColorRect/Label.show()
		$ColorRect/me.show()
	if wait >= 3 and wait < 4:
		$ColorRect/Label.hide()
		$ColorRect/me.hide()
	if wait >= 4 and wait < 6:
		$ColorRect/Label.show()
		$ColorRect/Label.text = 'MADE WITH'
		$ColorRect/godot.show()
	if wait >= 6:
		$ColorRect/Label.hide()
		$ColorRect/godot.hide()
	if wait > 7 or Input.is_action_just_pressed("accept"):
		get_tree().change_scene_to_file("res://source/fallmon/scenes/game/video.tscn")
	
	if Input.is_action_just_pressed("reset"):
		resetSettings()

var save_path = "user://settings.json"
func resetSettings():
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	
	var saved_data = {}
	
	saved_data["shaders"] = true
	saved_data["overlay"] = true
	saved_data["smooth-filter"] = false
	
	var json = JSON.stringify(saved_data)
	
	file.store_string(json)
	file.close()
