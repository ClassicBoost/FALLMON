extends Control

var game_volume:int = 1

var save_path = "user://volume.json"

@export
var bus_name: String

var bus_index: int

var volumeNum:float = 1

var timer:float = 1

var muteAnyway:bool = false

func _ready() -> void:
	position.y = -300
	volumeNum = game_volume
	loadSettings()
	bus_index = AudioServer.get_bus_index(bus_name)
	
func _process(delta):
	if Input.is_action_just_pressed("volUp") or Input.is_action_just_pressed("volDown"):
		position.y = 0
		timer = 1
		if Input.is_action_just_pressed("volUp") and volumeNum >= 1:
			$volume/deny.play()
		else:
			$volume.play()
		
	if Input.is_action_just_pressed("volUp") and volumeNum < 1:
		volumeNum += 0.1
	if Input.is_action_just_pressed("volDown") and volumeNum > 0:
		volumeNum -= 0.1
		
	timer -= 1 * delta
	
	@warning_ignore("narrowing_conversion")
	game_volume = volumeNum
	
	saveSettings()
	
	if timer < 0 and position.y > -100:
		position.y -= 20 * delta
	
	if muteAnyway:
		$Panel/ProgressBar.value = 0
	else:
		$Panel/ProgressBar.value = volumeNum

func _on_progress_bar_value_changed(value):
	@warning_ignore("narrowing_conversion")
	AudioServer.set_bus_volume_db(volumeNum, linear_to_db(value))

func saveSettings():		
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	
	var saved_data = {}
	
	saved_data["percent"] = volumeNum
	
	var json = JSON.stringify(saved_data)
	
	file.store_string(json)
	file.close()
	
func loadSettings():
	if FileAccess.file_exists(save_path):
		var file = FileAccess.open(save_path, FileAccess.READ)
		var json = file.get_as_text()
		
		var saved_data = JSON.parse_string(json)
		
		volumeNum = saved_data["percent"]
		
		file.close()
	else:
		print('bleh')
