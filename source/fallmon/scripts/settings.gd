extends Control

var save_path = "user://settings.json"

var shaders:bool = true

func _ready():
	loadSettings()

func _process(_delta):
	saveSettings()
	
	if shaders:
		$bg/shaders/setting.text = 'ON'
	else:
		$bg/shaders/setting.text = 'OFF'
	
func saveSettings():
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	
	var saved_data = {}
	
	saved_data["shaders"] = shaders
	
	var json = JSON.stringify(saved_data)
	
	file.store_string(json)
	file.close()

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

func _on_shaders_pressed():
	shaders = !shaders
	$confirm.play()

func _on_shaders_mouse_entered():
	$description.text = 'Turn this off if you are epileptic\nor game running very slowly'

func _on_leave_pressed():
	hide()

func _on_mouse_exited():
	$description.text = ''
