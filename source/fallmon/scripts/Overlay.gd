extends Control

var save_path = "user://settings.json"
var fps_counter:bool = true
var timeInState:float = 0
var showDebug:bool = false
# Called when the node enters the scene tree for the first time.
func _ready():
	if OS.is_debug_build():
		showDebug = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# loadSettings()
	var fps = Engine.get_frames_per_second()
	
	$counter.text = ''
	
	if OS.is_debug_build():
		$counter.text = 'DEBUG MODE\n'
	$counter.text += str(fps) + ' FPS'
	
	if not fps_counter and not showDebug:
		$counter.text = ''
	if showDebug:
		$counter.text += '\nMemory: ' + str(round(Performance.get_monitor(Performance.MEMORY_STATIC)/10000)/100) + 'mb / ' + str(round(Performance.get_monitor(Performance.MEMORY_STATIC_MAX)/10000)/100) + 'mb'
		$counter.text += '\n' + str((roundf(timeInState * 100) / 100))
	
	if OS.is_debug_build() and Input.is_action_just_pressed("debug"):
		showDebug = !showDebug
	
	timeInState += 1 * delta

func tree_entered():
	timeInState = 0

func loadSettings():
	if FileAccess.file_exists(save_path):
		var file = FileAccess.open(save_path, FileAccess.READ)
		var json = file.get_as_text()
		
		var saved_data = JSON.parse_string(json)
		
		fps_counter = saved_data["fps_counter"]
		
		file.close()
	else:
		print('bleh')
