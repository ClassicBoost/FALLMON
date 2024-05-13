extends Node2D

var shaders:bool = true
func _ready():
	pass

func _process(_delta):
	#if Input.is_action_just_pressed("debug2") and OS.is_debug_build():
	#	get_tree().change_scene_to_file("res://source/fallmon/scenes/game/testing_room.tscn")
							
	loadSettings()
	if shaders:
		$CRT.show()
	else:
		$CRT.hide()
	
	$ColorRect/version.text = ProjectSettings.get("application/config/version")
	if OS.is_debug_build():
		$ColorRect/version.text += '\nDebug Build'

var save_path = "user://settings.json"
func loadSettings():
	if FileAccess.file_exists(save_path):
		var file = FileAccess.open(save_path, FileAccess.READ)
		var json = file.get_as_text()
		
		var saved_data = JSON.parse_string(json)
		
		shaders = saved_data["shaders"]
		
		file.close()
	else:
		print('bleh')

func _on_mouse_entered():
	$select.play()

func _on_exit_pressed():
	get_tree().quit()

func _on_settings_pressed():
	$confirm.play()
	$Settings.show()

func _on_play_pressed():
	$confirm.play()
	get_tree().change_scene_to_file("res://source/fallmon/scenes/game/character_menu.tscn")


func _on_intro_pressed():
	get_tree().change_scene_to_file("res://source/fallmon/scenes/game/video.tscn")
