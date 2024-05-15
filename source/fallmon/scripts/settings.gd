extends Control

var save_path = "user://settings.json"

var shaders:bool = true
var overlay:bool = true
var smooth_filter:bool = false

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
	
	if smooth_filter:
		$bg/smooth_filter/setting.text = 'ON'
	else:
		$bg/smooth_filter/setting.text = 'OFF'
	
func saveSettings():
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	
	var saved_data = {}
	
	saved_data["shaders"] = shaders
	saved_data["overlay"] = overlay
	saved_data["smooth-filter"] = smooth_filter
	
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
		smooth_filter = saved_data["smooth-filter"]
		
		if smooth_filter:
			ProjectSettings.set("rendering/textures/canvas_textures/default_texture_filter", 1)
			ProjectSettings.set("rendering/anti_aliasing/quality/msaa_2d", 4)
		else:
			ProjectSettings.set("rendering/textures/canvas_textures/default_texture_filter", 0)
			ProjectSettings.set("rendering/anti_aliasing/quality/msaa_2d", 0)
		
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
		'smooth':
			$description.text = 'If enabled the game, somewhat has an\nanti-aliasing filter'
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


func _on_smooth_filter_pressed():
	smooth_filter = !smooth_filter
	$confirm.play()
