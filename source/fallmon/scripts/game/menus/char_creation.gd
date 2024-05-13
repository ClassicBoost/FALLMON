extends Control

@onready var listPage = get_owner().get_node("BG/List")

var startStr:int = 5
var startPer:int = 5
var startEnd:int = 5
var startCha:int = 5
var startInt:int = 5
var startAgl:int = 5
var startLuk:int = 5

var pointsLeft:int = 5

var isFemale:bool = false

var charName:String = '' # to prevent showing as blank
var charSpecies:String = 'pikachu' # to prevent showing as blank

func _ready():
	preload("res://source/fallmon/scenes/game/testing_room.tscn").instantiate()
		
func _process(_delta):
	$SPECIAL/Text.text = 'STRENGTH: ' + str(startStr)
	$SPECIAL/Text.text += '\nPERCEPTION: ' + str(startPer)
	$SPECIAL/Text.text += '\nENDURANCE: ' + str(startEnd)
	$SPECIAL/Text.text += '\nCHARISMA: ' + str(startCha)
	$SPECIAL/Text.text += '\nINTELLIGENCE: ' + str(startInt)
	$SPECIAL/Text.text += '\nAGILITY: ' + str(startAgl)
	$SPECIAL/Text.text += '\nLUCK: ' + str(startLuk)
	$SPECIAL/Text.text += '\nPOINTS LEFT: ' + str(pointsLeft)

func _on_mouse_entered():
	$select.play()


func _on_back_pressed():
	$confirm.play()
	hide()
	listPage.show()

func _on_create_pressed():
	if charName != '' and charName != 'loadinfo':
		saveChar()

func _on_special_stat_pressed(type, increase):
	$confirm.play()
	match type:
		'str':
			if increase and startStr < 10 and pointsLeft > 0:
				startStr += 1
				pointsLeft -= 1
			if not increase and startStr > 1:
				startStr -= 1
				pointsLeft += 1
		'per':
			if increase and startPer < 10 and pointsLeft > 0:
				startPer += 1
				pointsLeft -= 1
			if not increase and startPer > 1:
				startPer -= 1
				pointsLeft += 1
		'end':
			if increase and startEnd < 10 and pointsLeft > 0:
				startEnd += 1
				pointsLeft -= 1
			if not increase and startEnd > 1:
				startEnd -= 1
				pointsLeft += 1
		'cha':
			if increase and startCha < 10 and pointsLeft > 0:
				startCha += 1
				pointsLeft -= 1
			if not increase and startCha > 1:
				startCha -= 1
				pointsLeft += 1
		'int':
			if increase and startInt < 10 and pointsLeft > 0:
				startInt += 1
				pointsLeft -= 1
			if not increase and startInt > 1:
				startInt -= 1
				pointsLeft += 1
		'agl':
			if increase and startAgl < 10 and pointsLeft > 0:
				startAgl += 1
				pointsLeft -= 1
			if not increase and startAgl > 1:
				startAgl -= 1
				pointsLeft += 1
		'luk':
			if increase and startLuk < 10 and pointsLeft > 0:
				startLuk += 1
				pointsLeft -= 1
			if not increase and startLuk > 1:
				startLuk -= 1
				pointsLeft += 1
		_:
			print('nothing changed')
			pass
	print('SPECIAL change requested\nChanged: ' + str(type) + ' Increased: ' + str(increase))


func _on_name_text_changed(new_text):
	charName = str(new_text)
	print('Character name is now: ' + str(new_text))


func _on_species_selected(index):
	$confirm.play()
	match index:
		0:
			charSpecies = 'pikachu'
		1:
			charSpecies = 'snivy'
		2:
			charSpecies = 'tepig'
		3:
			charSpecies = 'oshawott'
		4:
			charSpecies = 'axew'
		5:
			charSpecies = 'riolu'
		_:
			pass
	print('Species swapped to ' + str(charSpecies.to_upper()))

var save_path:String = "user://saves/saved_game.json"
func saveChar():
	#save_path = "user://saves/" + str(charName.to_lower()) + ".json"
	
	print("user://saves/" + charName.to_lower() + ".json")
	#if FileAccess.file_exists(save_path):
	#	$nah.play()
	#	print('File with this name already exists')
	#	pass
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	
	var saved_data = {}
		
	saved_data["name"] = charName
	saved_data["species"] = charSpecies
	saved_data["female"] = isFemale # kupe
		
	saved_data["str"] = startStr
	saved_data["per"] = startPer
	saved_data["end"] = startEnd
	saved_data["cha"] = startCha
	saved_data["int"] = startInt
	saved_data["agl"] = startAgl
	saved_data["luk"] = startLuk
	
	saved_data["stamina"] = 999
	saved_data["pp"] = 999
	saved_data['health'] = 999
	saved_data['real_hp'] = 30
	saved_data['direction'] = Vector2(0,1)
	
	saved_data["pos_x"] = -288
	saved_data["pos_y"] = -96
		
	var json = JSON.stringify(saved_data)
		
	file.store_string(json)
	file.close()

	_on_back_pressed()
	# get_tree().change_scene_to_file("res://source/fallmon/scenes/game/testing_room.tscn")


func _on_gender_pressed():
	$confirm.play()
	isFemale = !isFemale
	
	if isFemale:
		$Top/Gender.text = 'FEMALE'
	else:
		$Top/Gender.text = 'MALE'
