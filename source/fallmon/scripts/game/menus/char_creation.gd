extends Control

@onready var listPage = get_owner().get_node("BG/List")
@onready var speciesInfo = "res://assets/species/data/pikachu.json"

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

# I should probably use arrays. But I'm dumb and lazy
var pkmnType:String = ""

var pkmnSTR:int = 0
var pkmnPER:int = 0
var pkmnEND:int = 0
var pkmnCHA:int = 0
var pkmnINT:int = 0
var pkmnAGL:int = 0
var pkmnLUK:int = 0

var pkmnHP:int = 0
var pkmnSTM:int = 0
var pkmnPP:int = 0

var pkmnRAD:int = 0
var pkmnAC:int = 0
var pkmnDIF:String = ''
var pkmnLMB:String = ''

var totalSTR = 0
var totalPER = 0
var totalEND = 0
var totalCHA = 0
var totalINT = 0
var totalAGL = 0
var totalLUK = 0

func _ready():
	preload("res://source/fallmon/scenes/game/testing_room.tscn").instantiate()
	for i in range(0,$Top/SpeciesList.get_item_count()):
		$Top/SpeciesList.set_item_tooltip_enabled(i,false)
		
func _process(_delta):
	$SPECIAL/Text.text = 'STRENGTH: ' + str(startStr) + ' (' + str(startStr+pkmnSTR) + ')'
	$SPECIAL/Text.text += '\nPERCEPTION: ' + str(startPer) + ' (' + str(startPer+pkmnPER) + ')'
	$SPECIAL/Text.text += '\nENDURANCE: ' + str(startEnd) + ' (' + str(startEnd+pkmnEND) + ')'
	$SPECIAL/Text.text += '\nCHARISMA: ' + str(startCha) + ' (' + str(startCha+pkmnCHA) + ')'
	$SPECIAL/Text.text += '\nINTELLIGENCE: ' + str(startInt) + ' (' + str(startInt+pkmnINT) + ')'
	$SPECIAL/Text.text += '\nAGILITY: ' + str(startAgl) + ' (' + str(startAgl+pkmnAGL) + ')'
	$SPECIAL/Text.text += '\nLUCK: ' + str(startLuk) + ' (' + str(startLuk+pkmnLUK) + ')'
	$SPECIAL/Text.text += '\nPOINTS LEFT: ' + str(pointsLeft)
	
	totalSTR = startStr+pkmnSTR
	totalPER = startPer+pkmnPER
	totalEND = startEnd+pkmnEND
	totalCHA = startCha+pkmnCHA
	totalINT = startInt+pkmnINT
	totalAGL = startAgl+pkmnAGL
	totalLUK = startLuk+pkmnLUK
	
	loadPokemon()

func _on_mouse_entered():
	$select.play()


func _on_back_pressed():
	$confirm.play()
	hide()
	listPage.show()

func _on_create_pressed():
	$ERROR.text = ''
	if charName != '' and (totalSTR > 0 and totalPER > 0 and totalEND > 0 and totalCHA > 0 and totalINT > 0 and totalAGL > 0 and totalLUK > 0):
		saveChar()
	else:
		$nah.play()
		if charName == '':
			$ERROR.text += 'ADD A NAME'
		if (totalSTR <= 0 or totalPER <= 0 or totalEND <= 0 or totalCHA <= 0 or totalINT <= 0 or totalAGL <= 0 or totalLUK <= 0):
			$ERROR.text += '\nSTAT(S) IS AT OR BELOW 0'

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
	charSpecies = $Top/SpeciesList.get_item_text(index).to_lower()
	speciesInfo = "res://assets/species/data/" + str(charSpecies) + ".json"
	print('Species swapped to ' + str(charSpecies.to_upper()))

func loadPokemon():
	if FileAccess.file_exists(speciesInfo):
		var file = FileAccess.open(speciesInfo, FileAccess.READ)
		var json = file.get_as_text()
		
		var saved_data = JSON.parse_string(json)
		
		pkmnType = saved_data["type"]
		
		pkmnSTR = saved_data["str"]
		pkmnPER = saved_data["per"]
		pkmnEND = saved_data["end"]
		pkmnCHA = saved_data["cha"]
		pkmnINT = saved_data["int"]
		pkmnAGL = saved_data["agl"]
		pkmnLUK = saved_data["luk"]
		
		pkmnHP = saved_data["hp"]
		pkmnSTM = saved_data["stamina"]
		pkmnPP = saved_data["pp"]
		
		pkmnRAD = saved_data["radresist"]
		pkmnAC = saved_data["ac"]
		pkmnDIF = saved_data['holding_difficulty']
		pkmnLMB = saved_data['extra_limb']
		
		file.close()

var save_path:String = "user://saves/saved_game.json"
func saveChar():
	save_path = "user://saves/" + str(charName.to_lower()) + ".json"
	
	print("user://saves/" + charName.to_lower() + ".json")
	if FileAccess.file_exists(save_path):
		$nah.play()
		print('File with this name already exists')
		pass
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	
	var saved_data = {}
	
	saved_data["type"] = pkmnType
	saved_data['hp_pkmn'] = pkmnHP
	saved_data['stm_pkmn'] = pkmnSTM
	saved_data['pp_pkmn'] = pkmnPP
	saved_data['rad_pkmn'] = pkmnRAD
	saved_data['ac_pkmn'] = pkmnAC
		
	saved_data["name"] = charName
	saved_data["species"] = charSpecies
	saved_data["female"] = isFemale # kupe
		
	saved_data["str"] = startStr + pkmnSTR
	saved_data["per"] = startPer + pkmnPER
	saved_data["end"] = startEnd + pkmnEND
	saved_data["cha"] = startCha + pkmnCHA
	saved_data["int"] = startInt + pkmnINT
	saved_data["agl"] = startAgl + pkmnAGL
	saved_data["luk"] = startLuk + pkmnLUK
	
	saved_data["stamina"] = 999
	saved_data["pp"] = 999
	saved_data['health'] = 999
	saved_data['real_hp'] = 30
	saved_data["weapon_difficulty"] = pkmnDIF
	saved_data["extra_limb"] = pkmnLMB
	saved_data['direction'] = Vector2(0,1)
	
	saved_data["time"] = 510
	saved_data["day"] = 0
	
	saved_data["body_temp"] = 37
	# I know ice types exists but like, just spawning in you would overheat quickly
	
	saved_data["head_cnd"] = 200 
	saved_data["chest_cnd"] = 300 
	saved_data["larm_cnd"] = 50 
	saved_data["rarm_cnd"] = 50
	saved_data["lleg_cnd"] = 50
	saved_data["rleg_cnd"] = 50
	saved_data["other_cnd"] = 999
	
	saved_data["pos_x"] = -288
	saved_data["pos_y"] = -96
	
	saved_data['weapon_pistol'] = 0
	saved_data['stimpacks'] = 0
	saved_data['radaways'] = 0
	saved_data['s-stimpacks'] = 0
	saved_data['antidote'] = 0
	saved_data['bandage'] = 0
	saved_data['doctors-bag'] = 0
	saved_data['medical-kit'] = 0
	saved_data['first-aid-kit'] = 0
	saved_data['heal-spray'] = 0
	saved_data['blood-pack'] = 0
	saved_data['radiation'] = 0
	
	saved_data["hunger"] = 100.9
	saved_data["thirst"] = 100.9
	saved_data["sleep"] = 100.9
	
	saved_data['level'] = 1
	saved_data['exp'] = 0
		
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
