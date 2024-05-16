extends Control

var paused:bool = false
var shaders:bool = true
var time = Time.get_datetime_dict_from_system()
var pm = ''
@onready var player = get_owner().get_node("Player")

func _ready():
	pass
	
func _process(_delta):
	loadSettings()
	if shaders:
		$CRT.show()
	else:
		$CRT.hide()
	
	if Input.is_action_just_pressed("pause"):
		$select.play()
		paused = !paused
		pauseMenu(paused)
	
	if time.hour >= 12:
		pm = 'PM '
	else:
		pm = 'AM '
	
	time = Time.get_datetime_dict_from_system()
	$bg/saved.text = 'Last Saved: ' + str(float(int(player.saveTimer*10))/10) + 's'
	$bg/time.text = pm + ("%02d:%02d:%02d" % [time.hour, time.minute, time.second]) + "\n" + ("%02d/%02d/----" % [time.day, time.month])
	
	loadSettings()
		
func pauseMenu(pauseStatus:bool):
	if pauseStatus:
		get_tree().paused = true
		show()
		$ambience.play()
	else:
		$ambience.stop()
		get_tree().paused = false
		hide()
	paused = pauseStatus
	print('paused: ' + str(paused))
		
func _on_mouse_entered():
	$select.play()

func _on_resume_pressed():
	pauseMenu(false)
	$confirm.play()

func _on_configuration_pressed():
	$Settings.show()

func _on_quit_pressed():
	pauseMenu(false)
	get_tree().change_scene_to_file("res://source/fallmon/scenes/game/Main_Menu.tscn")

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
