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

@export var addiction_chance:float = 0
@export var item_value:int = 0
var total_item:int = 0

@onready var weapon_item:ItemList = $Device/Screen/Inventory/weapon_list
@onready var aid_item:ItemList = $Device/Screen/Inventory/aid_list

func _ready():
	ambience = $ambience
	ambience.play()
	$Device/Screen/Stats/Conditions.show()
	$Device/Screen/Stats.show()
	$Device/Screen/Inventory.hide()
	$Device/Screen/Data.hide()
	
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
	
	if item_description == null or item_description == '':
		infoTxt.text = 'no description\n\n'
	else:
		infoTxt.text = item_description + '\n\n'
	
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
			$Device/Screen/Stats/Radiation/percent.text = str(float(int(player.radiation))/10) + '%'
		'special':
			var specialTxt = $Device/Screen/Stats/SPECIAL/special
			specialTxt.text = 'STRENGTH: ' + str(player.specialStats[0])
			specialTxt.text += '\nPERCEPTION: ' + str(player.specialStats[1])
			specialTxt.text += '\nENDURANCE: ' + str(player.specialStats[2])
			specialTxt.text += '\nCHARISMA: ' + str(player.specialStats[3])
			specialTxt.text += '\nINTELLIGENCE: ' + str(player.specialStats[4])
			specialTxt.text += '\nAGILITY: ' + str(player.specialStats[5])
			specialTxt.text += '\nLUCK: ' + str(player.specialStats[6])
		'weapons':
			if item_type != '':
				infoTxt.text += 'Type: ' + item_type + '\n'
			if item_damage > 0:
				infoTxt.text += 'DMG: ' + str(item_damage) + '\n'
			if item_ammo > 0:
				infoTxt.text += 'AMMO: ' + str(item_ammo) + '\n'
			
			var weaponList:ItemList = $Device/Screen/Inventory/weapon_list
			for i in range(0,weaponList.get_item_count()):
				weaponList.set_item_disabled(i,true)
				weaponList.set_item_tooltip_enabled(i,false)
				if player.weapons_inventory[i][1] > 0:
					weaponList.set_item_disabled(i, false)
		'aid':
			var aidList:ItemList = $Device/Screen/Inventory/aid_list
			
			for i in range(0,aidList.get_item_count()):
				aidList.set_item_disabled(i,true)
				aidList.set_item_tooltip_enabled(i,false)
				if player.aid_inventory[i][1] > 0:
					aid_item.set_item_disabled(i, false)
	
	infoTxt.text += 'VALUE: '
	if item_value > 0:
		infoTxt.text += str(item_value)
	else:
		infoTxt.text += 'no value'
	
	if total_item > 0:
		infoTxt.text += '\nYou have ' + str(total_item)
	
	var importantTxt = $Device/Screen/important
	importantTxt.text = player.charName + ' // ' + player.charSpecies.to_upper() + ' // '
	if player.isFemale:
		importantTxt.text += 'FEMALE'
	else:
		importantTxt.text += 'MALE'
	importantTxt.text += '\nHP: ' + str(int(player.health[0])) + '/' + str(player.health[1])
	importantTxt.text += ' // STM: ' + str(int(player.stamina[0])) + '/' + str(player.stamina[1]) 
	importantTxt.text += ' // PP: ' + str(int(player.PP[0])) + '/' + str(player.PP[1])

func _on_button_mouse_entered():
	$select.play()

func _on_stats_sub_pressed(menu, audio):
	if audio:
		$confirm.play()
	$Device/Screen/Stats/Radiation.hide()
	$Device/Screen/Stats/SPECIAL.hide()
	$Device/Screen/Stats/Conditions.hide()
	$Device/Screen/Inventory/weapon_list.hide()
	$Device/Screen/Inventory/aid_list.hide()
	match menu:
		'cnd':
			$Device/Screen/Stats/Conditions.show()
		'rad':
			$Device/Screen/Stats/Radiation.show()
		'special':
			$Device/Screen/Stats/SPECIAL.show()
		'weapons':
			$Device/Screen/Inventory/weapon_list.show()
		'aid':
			$Device/Screen/Inventory/aid_list.show()
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

func loadInfo(category, id):
	if FileAccess.file_exists("res://assets/items/" + category + "/" + item_path.to_lower() + ".json"):
		var file = FileAccess.open("res://assets/items/" + category + "/" + item_path.to_lower() + ".json", FileAccess.READ)
		var json = file.get_as_text()
		
		var info_data = JSON.parse_string(json)
		
		item_description = info_data["description"]
		item_type = info_data["type"]
		item_value = info_data["cost"]
		match category:
			'weapons':
				item_damage = info_data["damage"]
				item_ammo = info_data["ammo"]
				total_item = player.weapons_inventory[id][1]
			'aid':
				addiction_chance = info_data["addiction"]
				total_item = player.aid_inventory[id][1]
			_:
				pass
		
		
		player.currentItemHolding = item_path
		
		file.close()
	else:
		print('Item missing')

@onready var infoTxt = $Device/Screen/Inventory/info
func _on_weapon_list_selected(index):
	$confirm.play()
	match index:
		0:
			item_path = 'Pistol'
		_:
			item_path = 'blank'

	loadInfo('weapons', index)

var aid_item_ids:Array = [
	'StimPack',
	'S-StimPack',
	'RadAway',
	'Doctors-Bag',
	'First-Aid-Kit',
	'Medic-Kit',
	'Bandage',
	'Heal-Spray',
	'AntiDote',
	'Blood-Pack'
]

func _on_aid_list_item_selected(index):
	$confirm.play()
	item_path = aid_item_ids[index]

	loadInfo('aid', index)
