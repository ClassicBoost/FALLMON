extends Control

@export var device_open:bool = false
@export var currentMenu:String = 'stats'
@export var currentSubMenu:String = 'cnd'

@onready var player = get_owner().get_node("Player")

@onready var ambience:AudioStreamPlayer

var otherCNDmax:float = 1

@export var item_description = ''
@export var item_type = ''
@export var item_damage = 0
@export var item_ammo = 0

func _ready():
	ambience = $ambience
	ambience.play()
	$Device/Screen/Stats/Conditions.show()
	$Device/Screen/Stats.show()
	
func _process(_delta):
	if device_open:
		show()
	else:
		hide()
	
	if Input.is_action_just_pressed("pause"):
		device_open = false
	
	if device_open:
		ambience.volume_db = 0
	else:
		ambience.volume_db = -INF
	
	match currentSubMenu:
		'cnd':
			var cndTxt = $Device/Screen/Stats/Conditions/cnd
			
			cndTxt.text = 'HEAD: ' + str(int(player.headCND/2)) + '%'
			cndTxt.text += '\nCHEST: ' + str(int(player.chestCND/3)) + '%'
			cndTxt.text += '\nARMS - L: ' + str(int(player.lArmCND*2)) + '% | R: ' + str(int(player.rArmCND*2)) + '%'
			cndTxt.text += '\nLEGS - L: ' + str(int(player.lLegCND*2)) + '% | R: ' + str(int(player.rLegCND*2)) + '%'
			if player.otherCNDtype != '':
				cndTxt.text += '\n' + player.otherCNDtype.to_upper() + ': ' + str((player.otherCND/player.otherCNDmax)*100) + '%'
		'rad':
			$Device/Screen/Stats/Radiation/rad_bar.value = player.radiation
			$Device/Screen/Stats/Radiation/percent.text = str(player.radiation/10) + '%'
		'special':
			var specialTxt = $Device/Screen/Stats/SPECIAL/special
			specialTxt.text = 'STRENGTH: ' + str(player.strength)
			specialTxt.text += '\nPERCEPTION: ' + str(player.perception)
			specialTxt.text += '\nENDURANCE: ' + str(player.endurance)
			specialTxt.text += '\nCHARISMA: ' + str(player.charisma)
			specialTxt.text += '\nINTELLIGENCE: ' + str(player.intelligence)
			specialTxt.text += '\nAGILITY: ' + str(player.agility)
			specialTxt.text += '\nLUCK: ' + str(player.luck)
		'weapons':
			if item_description == null or item_description == '':
				infoTxt.text = 'no description\n\n'
			else:
				infoTxt.text = item_description + '\n\n'
			if item_type != '':
				infoTxt.text += 'Type: ' + item_type + '\n'
			if item_damage > 0:
				infoTxt.text += 'DMG: ' + str(item_damage) + '\n'
			if item_ammo > 0:
				infoTxt.text += 'AMMO: ' + str(item_ammo) + '\n'
	
	var importantTxt = $Device/Screen/important
	importantTxt.text = player.charName + ' // ' + player.charSpecies.to_upper()
	importantTxt.text += '\nHP: ' + str(int(player.health)) + '/' + str(player.maxHealth)
	importantTxt.text += ' // STM: ' + str(int(player.stamina)) + '/' + str(player.maxStamina) 
	importantTxt.text += ' // PP: ' + str(int(player.PP)) + '/' + str(player.maxPP)

func _on_button_mouse_entered():
	$select.play()

func _on_stats_sub_pressed(menu, audio):
	if audio:
		$confirm.play()
	$Device/Screen/Stats/Radiation.hide()
	$Device/Screen/Stats/SPECIAL.hide()
	$Device/Screen/Stats/Conditions.hide()
	$Device/Screen/Inventory/weapon_list.hide()
	match menu:
		'cnd':
			$Device/Screen/Stats/Conditions.show()
		'rad':
			$Device/Screen/Stats/Radiation.show()
		'special':
			$Device/Screen/Stats/SPECIAL.show()
		'weapons':
			$Device/Screen/Inventory/weapon_list.show()
		_:
			pass
	currentSubMenu = menu

func _on_menu_pressed(menu):
	if menu != currentMenu:	
		var randomSound = randi_range(1, 5)
		match randomSound:
			2:
				$"staticRandom-1/staticRandom-2".play()
			3:
				$"staticRandom-1/staticRandom-3".play()
			4:
				$"staticRandom-1/staticRandom-4".play()
			5:
				$"staticRandom-1/staticRandom-5".play()
			_:
				$"staticRandom-1".play()
		$switchTabs.play()
		$Device/Screen/Stats.hide()
		$Device/Screen/Inventory.hide()
		match menu:
			'stats':
				$Device/Screen/Stats.show()
				_on_stats_sub_pressed('cnd', false)
			'inv':
				$Device/Screen/Inventory.show()
				_on_stats_sub_pressed('weapons', false)
			_:
				pass
		currentMenu = menu

var item_path = "blank"

func loadInfo():
	if FileAccess.file_exists("res://assets/items/weapons/" + item_path + ".json"):
		var file = FileAccess.open("res://assets/items/weapons/" + item_path + ".json", FileAccess.READ)
		var json = file.get_as_text()
		
		var info_data = JSON.parse_string(json)
		
		item_description = info_data["description"]
		item_type = info_data["type"]
		item_damage = info_data["damage"]
		item_ammo = info_data["ammo"]
		
		file.close()
	else:
		print('Item missing')

@onready var infoTxt = $Device/Screen/Inventory/info
func _on_weapon_list_selected(index):
	$confirm.play()
	match index:
		1:
			item_path = 'test'
		_:
			item_path = 'blank'
	
	loadInfo()
