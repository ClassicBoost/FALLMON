extends Node2D
var shaders:bool = true
func _ready():
	loadSettings()
	if shaders:
		$CRT.show()
	else:
		$CRT.hide()

func _process(_delta):
	pass


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
