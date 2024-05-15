extends CharacterBody2D

var moveSpeed:float = 130

@onready var animation_tree = $AnimationTree
@onready var sprite = $sprites

# animations have different frames
@onready var anim_player:AnimationPlayer = $fours
@onready var anim_player_twos:AnimationPlayer = $fours/twos
@onready var anim_player_six:AnimationPlayer = $fours/sixs

@export var charSpecies:String = 'example'
var checkPackage:bool = false
var packageFolder:String = 'assets'
var stopLoading:bool = false

var pkmnType:String = ''
var pkmnHP:int = 0
var pkmnSTM:int = 0
var pkmnPP:int = 0
var pkmnRAD:int = 0
var pkmnAC:int = 0

var save_path = "user://saves/saved_game.json"

@export var charName:String = ''

@export var isFemale:bool = false

@export var health:float = 999
var maxHealth:float = 35

@export var stamina:float = 999
var maxStamina:float = 50

@export var PP:float = 10
var maxPP:float = 10

@export var realHP:int = 30

@onready var portraitThingy = get_owner().get_node("UI/HUD/HP/front/portrait")
@onready var device = get_owner().get_node("UI/PIP-DEX")

# SPECIAL
@export var strength_default:int = 5
@export var perception_default:int = 5
@export var endurance_default:int = 5
@export var charisma_default:int = 5
@export var intelligence_default:int = 5
@export var agility_default:int = 5
@export var luck_default:int = 5
var strength:int = 3
var perception:int = 3
var endurance:int = 3
var charisma:int = 3
var intelligence:int = 3
var agility:int = 3
var luck:int = 3

var input_direction = Vector2(0,0)

@export var radiation:float = 0

var moving:bool = false
var running:bool = false
var exhausted:bool = false

@export var headCND:float = 200
@export var chestCND:float = 300
@export var lArmCND:float = 50
@export var rArmCND:float = 50
@export var lLegCND:float = 50
@export var rLegCND:float = 50
@export var otherCND:float = 50
var otherCNDtype:String = ''
var otherCNDmax:float = 0

var weaponDifficulty:String = ''

# json
var species_sprite:String = 'example'

func _ready():
	updateAnim(Vector2(0, 1))
	stopLoading = false

func _physics_process(delta):
	#save_path = "user://saves/" + charName.to_lower() + ".json"
	loadData()

	moving = false
	running = false
	input_direction = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	)
	
	if checkPackage:
		get_json("res://packages/species/data/" + charSpecies.to_lower() + ".json")
	else:
		get_json("res://assets/species/data/" + charSpecies.to_lower() + ".json")
	
	updateLimits()
	
	runPortraitUpdate()
	
	if self.velocity.x != 0 or self.velocity.y != 0:
		moving = true
		if Input.is_action_pressed("sprint"):
			running = true
	
	if running and moving and not exhausted and (lLegCND >= 10 and rLegCND >= 10):
		moveSpeed = (300+(agility*2)-(((health/maxHealth)*-1)*80))*((lLegCND/100)+(rLegCND/100))
		stamina -= 8 * delta
		anim_player.set_speed_scale(3)
	else:
		moveSpeed = (70+agility-(((health/maxHealth)*-1)*80))*((lLegCND/100)+(rLegCND/100))
		if moving:
			stamina += agility * (delta/3)
		else:
			stamina += (agility) * delta
		anim_player.set_speed_scale(1)
	
	if lLegCND < 10:
		lLegCND += 0.1 * delta
	if rLegCND < 10:
		rLegCND += 0.1 * delta
	
	#print(moveSpeed)
	
	updateAnim(input_direction)

	if not device.device_open:
		velocity = (input_direction * moveSpeed) * (delta * 60)
		move_and_slide()
	if Input.is_action_just_pressed("device"):
		device.device_open = !device.device_open
	
	new_anim_state()
	
	if charName != '' and charName != null:
		saveChar()

func updateLimits():
	portraitThingy.expression = 0
	strength = strength_default
	perception = perception_default
	endurance = endurance_default
	charisma = charisma_default
	intelligence = intelligence_default
	agility = agility_default
	luck = luck_default
	# $Label.text = str(strength) + str(perception) + str(endurance) + str(charisma) + str(intelligence) + str(agility) + str(luck)
	maxStamina = agility*10+pkmnSTM
	maxHealth = 20+(endurance*2)+strength+pkmnHP
	maxPP = (strength*2)+pkmnPP
	
	if radiation < 0:
		radiation = 0
	if health > maxHealth:
		health = maxHealth
	if stamina > maxStamina:
		stamina = maxStamina
	if PP > maxPP:
		PP = maxPP
	if stamina < 0:
		stamina = 0
		exhausted = true
	if stamina > 10:
		exhausted = false
	if radiation > 1000:
		health -= 1
		radiation -= 1
	if headCND > 200:
		headCND = 200
	if chestCND > 300:
		chestCND = 300
	if lArmCND > 50:
		lArmCND = 50
	if rArmCND > 50:
		rArmCND = 50
	if lLegCND > 50:
		lLegCND = 50
	if rLegCND > 50:
		rLegCND = 50
	if otherCND > otherCNDmax:
		otherCND = otherCNDmax	
	if health < 0:
		realHP -= 1
		health += 1
	if realHP > 30:
		realHP = 30

func runPortraitUpdate():
	if stamina <= 10 or health <= 10:
		portraitThingy.expression = 2
	if health <= 4:
		portraitThingy.expression = 13

func updateAnim(anim:Vector2):
	if (anim != Vector2.ZERO):
		animation_tree.set("parameters/Idle/blend_position", anim)

func new_anim_state():
	if species_sprite == '' or species_sprite == null:
		pass
	
	var current_anim:String = 'idle'
	
	if (velocity != Vector2.ZERO):
		sprite.texture = load("res://" + packageFolder + "/species/sprites/" + species_sprite + "/walk.png")
		current_anim = 'walk'
	else:
		sprite.texture = load("res://" + packageFolder + "/species/sprites/" + species_sprite + "/idle.png")
		current_anim = 'idle'
	
	if sprite.texture == null: # prevent crashing
		sprite.texture = load("res://assets/graphics/missing.png")
	
	update_offsets(current_anim)

func update_offsets(current_anim:String):
	match current_anim:
		'idle':
			if charSpecies == 'tepig' or charSpecies == 'oshawott' or charSpecies == 'pikachu':
				sprite.set_hframes(6)
				animation_tree.set_animation_player(NodePath("../fours/sixs"))
			elif charSpecies == 'wooper':
				sprite.set_hframes(2)
				animation_tree.set_animation_player(NodePath("../fours/twos"))
			else:
				sprite.set_hframes(4)
				animation_tree.set_animation_player(NodePath("../fours"))
		'walk':
			if charSpecies == 'wooper':
				sprite.set_hframes(8)
				animation_tree.set_animation_player(NodePath("../fours/eights"))
			else:
				sprite.set_hframes(4)
				animation_tree.set_animation_player(NodePath("../fours"))
		_:
			sprite.set_hframes(4)
			animation_tree.set_animation_player(NodePath("../fours"))

var isMissing:bool = false
func get_json(json_path:String):
	if FileAccess.file_exists(json_path):
		var file = FileAccess.open(json_path, FileAccess.READ)
		var json = file.get_as_text()
		
		var saved_data = JSON.parse_string(json)
		
		species_sprite = saved_data["sprite_male"]
		
		if isFemale:
			species_sprite = saved_data["sprite_female"]
		
		if checkPackage and isMissing:
			print('Json file found through package folder!')
		
		if checkPackage:
			packageFolder = 'packages'
		else:
			packageFolder = 'assets'
		
		isMissing = false
		
		file.close()
	else:
		if not isMissing:
			print(charSpecies + '.json file is missing or unable to load.')
			isMissing = true
		checkPackage = !checkPackage # check to see if the sprite exists in the package folder
		
func loadData():
	if not stopLoading:
		var file_two = FileAccess.open("user://zarade.json", FileAccess.READ)
		var json_two = file_two.get_as_text()
			
		var saved_data_two = JSON.parse_string(json_two)
			
		save_path = saved_data_two["name"]
	if FileAccess.file_exists(save_path):
		var file = FileAccess.open(save_path, FileAccess.READ)
		var json = file.get_as_text()
		
		var saved_data = JSON.parse_string(json)
		
		charName = saved_data["name"]
		pkmnType = saved_data["type"]
		pkmnHP = saved_data['hp_pkmn']
		pkmnSTM = saved_data['stm_pkmn']
		pkmnPP = saved_data['pp_pkmn']
		pkmnRAD = saved_data['rad_pkmn']
		pkmnAC = saved_data['ac_pkmn']
		
		charName = saved_data["name"]
		charSpecies = saved_data["species"]
		isFemale = saved_data["female"]
		
		strength_default = saved_data["str"]
		perception_default = saved_data["per"]
		endurance_default = saved_data["end"]
		charisma_default = saved_data["cha"]
		intelligence_default = saved_data["int"]
		agility_default = saved_data["agl"]
		luck_default = saved_data["luk"]
		
		weaponDifficulty = saved_data["weapon_difficulty"]
		otherCNDtype = saved_data["extra_limb"]
		
		if not stopLoading:
			headCND = saved_data["head_cnd"]
			chestCND = saved_data["chest_cnd"]
			lArmCND = saved_data["larm_cnd"]
			rArmCND = saved_data["rarm_cnd"]
			lLegCND = saved_data["lleg_cnd"]
			rLegCND = saved_data["rleg_cnd"]
			otherCND = saved_data["other_cnd"]
			
			input_direction = saved_data["direction"]
			stamina = saved_data["stamina"]
			PP = saved_data["pp"]
			health = saved_data['health']
			realHP = saved_data['real_hp']
			
			self.global_position.x = saved_data["pos_x"]
			self.global_position.y = saved_data["pos_y"]
			
			match otherCNDtype:
				'tail':
					otherCNDmax = 50
				'wings':
					otherCNDmax = 30
				_:
					otherCNDmax = 0
			print("hello, " + charName)
			stopLoading = true
		
		file.close()
	else:
		print('missing from: ' + save_path)
		get_tree().change_scene_to_file("res://source/fallmon/scenes/game/character_menu.tscn")

func saveChar():
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
	saved_data["female"] = isFemale
		
	saved_data["str"] = strength_default
	saved_data["per"] = perception_default
	saved_data["end"] = endurance_default
	saved_data["cha"] = charisma_default
	saved_data["int"] = intelligence_default
	saved_data["agl"] = agility_default
	saved_data["luk"] = luck_default
	
	saved_data["direction"] = input_direction
	saved_data["stamina"] = stamina
	saved_data["pp"] = PP
	saved_data['health'] = health
	saved_data['real_hp'] = realHP
	
	saved_data["head_cnd"] = headCND 
	saved_data["chest_cnd"] = chestCND 
	saved_data["larm_cnd"] = lArmCND 
	saved_data["rarm_cnd"] = rArmCND
	saved_data["lleg_cnd"] = lLegCND
	saved_data["rleg_cnd"] = rLegCND
	saved_data["other_cnd"] = otherCND
	
	saved_data["weapon_difficulty"] = weaponDifficulty
	saved_data["extra_limb"] = otherCNDtype
	
	saved_data["pos_x"] = self.global_position.x
	saved_data["pos_y"] = self.global_position.y
	
	var json = JSON.stringify(saved_data)
		
	file.store_string(json)
	file.close()
