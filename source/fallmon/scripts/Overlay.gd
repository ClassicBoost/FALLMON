extends Control

var save_path = "user://settings.json"
var fps_counter:bool = true
var timeInState:float = 0
var showDebug:bool = false
var totalErrors:int = 0
var showConsole:bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	if OS.is_debug_build():
		showDebug = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# loadSettings()
	var fps = Engine.get_frames_per_second()
	
	$counter.text = ''
	
	$errors.text = ''
	if totalErrors > 0:
		$errors.text = str(totalErrors) + ' ERRORS'
	
	if fps_counter:
		$counter.text += str(fps) + ' FPS'
		$counter.text += '\n' + str(round(Performance.get_monitor(Performance.MEMORY_STATIC)/10000)/100) + 'mb / ' + str(round(Performance.get_monitor(Performance.MEMORY_STATIC_MAX)/10000)/100) + 'mb\n'
		
		if OS.is_debug_build():
			$counter.text += 'DEBUG MODE'
		if showDebug:
			$counter.text += '\n' + str((roundf(timeInState * 100) / 100))
	
	if OS.is_debug_build():
		if Input.is_action_just_pressed("debug"):
			showDebug = !showDebug
		if Input.is_action_just_pressed("console"):
			showConsole = !showConsole
	
	if showConsole:
		$console.show()
	else:
		$console.hide()
	
	timeInState += 1 * delta
	
	loadSettings()

func tree_entered():
	timeInState = 0

func loadSettings():
	if FileAccess.file_exists(save_path):
		var file = FileAccess.open(save_path, FileAccess.READ)
		var json = file.get_as_text()
		
		var saved_data = JSON.parse_string(json)
		
		fps_counter = saved_data["overlay"]
		
		file.close()
	else:
		print('bleh')

@onready var line:LineEdit = $console/LineEdit
@onready var textLines:RichTextLabel = $console/text
var expression = Expression.new()
func _command_entered(command):
	line.text = ''
	var error = expression.parse(command)
	if error != OK:
		textLines.text += expression.get_error_text() + '\n'
		outputError()
		return
	var result = expression.execute([],self)
	if not expression.has_execute_failed():
		textLines.text += str(result)
	
	textLines.text += '\n'
func _on_command_clear():
	textLines.text = ''
	totalErrors = 0
	
func outputError():
	totalErrors += 1
	$error.play()
