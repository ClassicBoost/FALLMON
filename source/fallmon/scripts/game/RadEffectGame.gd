extends ColorRect

@onready var player = get_owner().get_node("Player")
@onready var pauseStuff = get_owner().get_node("UI/Pause")
var shaders:bool = true
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	loadSettings()
	if shaders:
		show()
	else:
		hide()
	position.x = player.position.x - 500
	position.y = player.position.y - 500
	material.set_shader_parameter("spread", 0.01 * (player.radiation/1000))

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
