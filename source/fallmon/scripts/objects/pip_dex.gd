extends Control

@export var device_open:bool = false
@export var currentMenu:String = 'main'
@export var currentSubMenu:String = 'cnd'

@onready var player = get_owner().get_node("Player")

@onready var ambience:AudioStreamPlayer

var otherCNDmax:float = 1

func _ready():
	ambience = $ambience
	ambience.play()
	
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
	
	var importantTxt = $Device/Screen/important
	importantTxt.text = player.charName + ' // ' + player.charSpecies.to_upper()
	importantTxt.text += '\nHP: ' + str(int(player.health)) + '/' + str(player.maxHealth)
	importantTxt.text += ' // STM: ' + str(int(player.stamina)) + '/' + str(player.maxStamina) 
	importantTxt.text += ' // PP: ' + str(int(player.PP)) + '/' + str(player.maxPP)

func _on_button_mouse_entered():
	$select.play()

func _on_stats_sub_pressed(menu):
	$confirm.play()
	$Device/Screen/Stats/Radiation.hide()
	$Device/Screen/Stats/SPECIAL.hide()
	$Device/Screen/Stats/Conditions.hide()
	match menu:
		'cnd':
			$Device/Screen/Stats/Conditions.show()
		'rad':
			$Device/Screen/Stats/Radiation.show()
		'special':
			$Device/Screen/Stats/SPECIAL.show()
		_:
			pass
	currentSubMenu = menu
