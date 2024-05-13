extends Control

var save_path = "user://settings.json"

var shaders:bool = true
var overlay:bool = true

func _ready():
	loadSettings()

func _process(_delta):
	saveSettings()
	
	if shaders:
		$bg/shaders/setting.text = 'ON'
	else:
		$bg/shaders/setting.text = 'OFF'
	
	if overlay:
		$bg/overlay_info/setting.text = 'ON'
	else:
		$bg/overlay_info/setting.text = 'OFF'
	
func saveSettings():
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	
	var saved_data = {}
	
	saved_data["shaders"] = shaders
	saved_data["overlay"] = overlay
	
	var json = JSON.stringify(saved_data)
	
	file.store_string(json)
	file.close()

func loadSettings():
	if FileAccess.file_exists(save_path):
		var file = FileAccess.open(save_path, FileAccess.READ)
		var json = file.get_as_text()
		
		var saved_data = JSON.parse_string(json)
		
		shaders = saved_data["shaders"]
		overlay = saved_data["overlay"]
		
		file.close()
	else:
		print('bleh')
		
func _on_mouse_entered(info):
	$select.play()
	
	match info:
		'shaders':
			$description.text = 'Turn this off if you are epileptic\nor game running very slowly'
		'overlay':
			$description.text = 'Shows framerate and memory on the top right\nif enabled'
		_:
			$description.text = ''

func _on_shaders_pressed():
	shaders = !shaders
	$confirm.play()

func _on_leave_pressed():
	$confirm.play()
	hide()

func _on_mouse_exited():
	$description.text = ''

func _on_overlay_info_pressed():
	overlay = !overlay
	$confirm.play()
