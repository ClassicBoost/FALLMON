extends Control

@onready var creationPage = get_owner().get_node("BG/Creation")
@onready var shader = get_owner().get_node("CRT")
var textName:String = ''
var plzStop:bool = false

var save_path:String = ""

func _ready():
	plzStop = false
	
	#if OS.is_debug_build():
	#	$NinePatchRect/SAVE_FOLDER.show()

func _process(_delta):
	if not plzStop:
		saveTheName()

func _on_mouse_entered():
	$select.play()

func _on_play_pressed():
	$confirm.play()
	plzStop = true
	loadChar()

func _on_new_pressed():
	$confirm.play()
	hide()
	creationPage.show()

func _on_delete_pressed():
	$confirm.play()

func _on_back_pressed():
	$confirm.play()
	get_tree().change_scene_to_file("res://source/fallmon/scenes/game/Main_Menu.tscn")

func _on_saves_pressed():
	var path = ProjectSettings.globalize_path("user://saves/")

	OS.shell_show_in_file_manager(path, true)

func _on_save_folder_pressed():
	$FileDialog.show()


func _on_line_edit_text_changed(new_text):
	textName = new_text
	print(new_text)

func loadChar():
	#save_path = "user://saves/" + str(textName.to_lower()) + ".json"
	
	#print("user://saves/" + textName.to_lower() + ".json")
	
	var file = FileAccess.open("user://zarade.json", FileAccess.WRITE)
	
	var saved_data = {}
		
	saved_data["name"] = save_path
		
	var json = JSON.stringify(saved_data)
		
	file.store_string(json)
	file.close()
	
	if FileAccess.file_exists(save_path):
		get_tree().change_scene_to_file("res://source/fallmon/scenes/game/testing_room.tscn")
	else:
		$FileDialog.show()
		$nah.play()
		print('Character missing')

func saveTheName():
	pass


func _on_file_dialog_file_selected(path):
	save_path = path
	print(path)
	_on_play_pressed()
