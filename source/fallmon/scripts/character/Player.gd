extends CharacterBody2D

var moveSpeed:float = 130

var saveTimer:float = 0

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

@export var health:Array = [35.0, 35.0]
@export var stamina:Array = [35.0, 50.0]
@export var PP:Array = [10.0, 10.0]

@export var realHP:int = 30

@onready var portraitThingy = get_owner().get_node("UI/HUD/HP/front/portrait")
@onready var device = get_owner().get_node("UI/PIP-DEX")
@onready var pauseThingy = get_owner().get_node("UI/Pause")
@onready var time = get_owner().get_node("UI/Time")

# SPECIAL
var strength_default:int = 5
var perception_default:int = 5
var endurance_default:int = 5
var charisma_default:int = 5
var intelligence_default:int = 5
var agility_default:int = 5
var luck_default:int = 5
var specialStats:Array = [3, 3, 3, 3, 3, 3, 3]

var input_direction = Vector2(0,0)

@export var radiation:float = 0
var lastRadiation:float = 0

var moving:bool = false
var running:bool = false
var exhausted:bool = false

var otherCNDtype:String = ''

@export var charLevel:int = 1
@export var totalExp:int = 0
var exp_to_next:int = 1000

@export var bodyTemp:float = 37.0
@export var termias:Array = [
	38, #hyper
	35 #hypo
]

@export var conditions:Array = [
	['Head', 200.0, 200.0, ''],
	['Chest', 300.0, 300.0, ''],
	['Left Arm', 50.0, 50.0, ''],
	['Right Arm', 50.0, 50.0, ''],
	['Left Leg', 50.0, 50.0, ''],
	['Right Leg', 50.0, 50.0, ''],
	['', 50.0, 50.0, ''],
]

var weaponDifficulty:String = ''

@export var saturations:Array = [
	100,
	100,
	100
]

# type, intensity, duration
@export var effects:Array = [
	['bleeding', 0, 0],
	['poison', 0, 0],
	['healing-sickness', 0, 0]
]
@export var weapons_inventory:Array = [
	['Pistol', 0]
]
@export var aid_inventory:Array = [
	["Stimpacks", 0],
	["S. Stimpacks", 0],
	["Radaways", 0],
	["Doctor's Bag", 0],
	["First Aid Kit", 0],
	["Medic Kit", 0],
	["Bandage", 0],
	["Heal Spray", 0],
	["Antidote", 0],
	["Blood Pack", 0]
]
@export var traits:Array = []

@export var currentItemHolding:String = ''
@onready var itembg:TextureRect = $Item_BG

@onready var fanfire:AudioStreamPlayer = $fanfire
var soundToPlay:String = ''

# json
var species_sprite:String = 'example'

func _ready():
	updateAnim(Vector2(0, 1))
	stopLoading = false
	fanfire.volume_db = -INF

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
	
	if !fanfire.playing and soundToPlay == 'radiation':
		playFanfire()
	
	if radiation > lastRadiation:
		fanfire.volume_db = 0
		soundToPlay = "radiation"
	
	if soundToPlay == 'radiation':
		fanfire.volume_db -= 20 * delta
	else:
		fanfire.volume_db = 0
	lastRadiation = radiation
	
	var next = charLevel + 1
	@warning_ignore("integer_division")
	exp_to_next = (next*(next-1)/2)*1000
	
	if OS.is_debug_build():
		$Label.text = 'X: ' + str(int(self.position.x))
		$Label.text += '\nY: ' + str(int(self.position.y))
	
	if totalExp >= exp_to_next:
		charLevel += 1
		soundToPlay = 'level_pmd'
		playFanfire()
	
	if not pauseThingy.paused:
		if running and moving and not exhausted and (conditions[4][1] >= 10 and conditions[5][1] >= 10):
			moveSpeed = (300+(specialStats[5]*2)-(((health[0]/health[1])*-1)*80))*((conditions[4][1]/100)+(conditions[5][1]/100))
			stamina[0] -= 8 * delta
			anim_player.set_speed_scale(3)
		else:
			moveSpeed = (70+specialStats[5]-(((health[0]/health[1])*-1)*80))*((conditions[4][1]/100)+(conditions[5][1]/100))
			if moving:
				stamina[0] += specialStats[5] * (delta/3)
			else:
				stamina[0] += (specialStats[5]) * delta
			anim_player.set_speed_scale(1)
		
		for i in range(4,5):
			if conditions[i][1] < 10:
				conditions[i][1] += 0.1 * delta
		
		if effects[2][2] > 0:
			effects[2][2] -= 1 * delta
	
	#print(moveSpeed)
	
	if not device.device_open and not pauseThingy.paused:
		updateAnim(input_direction)
		animation_tree.active = true
	else:
		animation_tree.active = false

	if not device.device_open and not pauseThingy.paused:
		velocity = (input_direction * moveSpeed) * (delta * 60)
		move_and_slide()
	if Input.is_action_just_pressed("device"):
		device.device_open = !device.device_open
	
	new_anim_state()
	
	saveTimer += 1 * delta
	
	if charName != '' and charName != null and saveTimer > 5:
		saveChar()
		saveTimer = 0
	
	saturationsUpdate(delta)
	itemCheck(delta)
	lmbUpdate()

func playFanfire():
	if soundToPlay != '':
		fanfire.stream = load("res://assets/audios/sounds/player/" + soundToPlay + ".ogg")
	
	fanfire.play()

func lmbUpdate():
	for i in range(0,conditions.size()):
		conditions[i][3] = ''
		if conditions[i][1] < float(conditions[i][2]):
			conditions[i][3] = 'Damged'
		if conditions[i][1] < float(conditions[i][2] * 0.9):
			conditions[i][3] = 'Badly Damaged'
		if conditions[i][1] < float(conditions[i][2] * 0.67):
			conditions[i][3] = 'Sprained'
		if conditions[i][1] < float(conditions[i][2] * 0.33):
			conditions[i][3] = 'Injured'
		if conditions[i][1] <= 0:
			conditions[i][3] = 'Crippled'

var saturationTitle:Array = [
	['','Peckish','Hungry','Very Hungry','Starving'],
	['','Perched','Thirsty','Very Thirsty','Dehydrated'],
	['','Tired','Very Tired','Falling Over','Fainted'],
]
var saturationEffects:Array = [
	[[0,0,0],[0,0,1],[0,1,2],[1,2,3],[2,3,4]],
	[[0,0,0],[0,0,1],[0,1,2],[1,2,3],[2,3,4]],
	[[0],[1],[3],[5],[5]],
]
var hgrTitle = ''
var thsTitle = ''
var slpTitle = ''
func saturationsUpdate(delta):
	saturations[0] -= 0.017 * delta
	saturations[1] -= 0.04 * delta
	if not moving:
		saturations[2] -= 0.0001 * delta
	else:
		saturations[2] -= (0.0002*moveSpeed) * delta
	
	var hgrShit = 0
	var thsShit = 0
	var slpShit = 0
	if saturations[0] < 80:
		hgrShit = 1
	if saturations[0] < 50:
		hgrShit = 2
	if saturations[0] < 20:
		hgrShit = 3
	if saturations[0] <= 0:
		hgrShit = 4
	
	if (saturations[0] <= 0 or saturations[1] <= 0) and health[0] > 0 and not pauseThingy.paused:
		health[0] -= 0.2 * delta
	
	if saturations[1] < 80:
		thsShit = 1
	if saturations[1] < 50:
		thsShit = 2
	if saturations[1] < 20:
		thsShit = 3
	if saturations[1] <= 0:
		thsShit = 4
	
	if saturations[2] < 85:
		slpShit = 1
	if saturations[2] < 40:
		slpShit = 2
	if saturations[2] < 15:
		slpShit = 3
	if saturations[2] <= 0:
		slpShit = 4
	
	specialStats[0] -= saturationEffects[0][hgrShit][0]
	specialStats[1] -= saturationEffects[0][thsShit][1]
	specialStats[2] -= saturationEffects[0][hgrShit][1]
	specialStats[4] -= saturationEffects[0][thsShit][2]
	specialStats[5] -= saturationEffects[0][hgrShit][2] + saturationEffects[1][thsShit][2] + saturationEffects[2][slpShit][0]
	hgrTitle = saturationTitle[0][hgrShit]
	thsTitle = saturationTitle[1][thsShit]
	slpTitle = saturationTitle[2][slpShit]

var heldRtimer:float = 1
var goBackUp:bool = false
var stupidFloat:float = 0
func itemCheck(delta):
	itembg.texture = load("res://assets/graphics/items/none.png")
	if currentItemHolding != '':
		itembg.texture = load("res://assets/graphics/items/" + currentItemHolding.to_lower() + ".png")
		itembg.modulate.a = 1
		if Input.is_action_pressed("reset") and not device.device_open and not pauseThingy.paused:
			heldRtimer -= 1 * delta
			if heldRtimer < 0:
				heldRtimer = 1
				currentItemHolding = ''
		else:
			heldRtimer = 1
	else:
		itembg.modulate.a -= 1 * delta
	
	if itembg.texture == null: # prevent crashing
		itembg.texture = load("res://assets/graphics/missing.png")
	
	if not pauseThingy.paused:
		if goBackUp:
			itembg.position.y -= 6 * delta
			stupidFloat -= 6 * delta
		else:
			itembg.position.y += 6 * delta
			stupidFloat += 6 * delta
	
	if stupidFloat > 6:
		goBackUp = true
	elif stupidFloat < 0:
		goBackUp = false
	
	if Input.is_action_just_pressed("useItem") and not pauseThingy.paused:
		match currentItemHolding.to_lower():
			'stimpack':
				if health[0] > 5 and realHP < 30 and aid_inventory[0][1] > 0 and effects[2][2] <= 0:
					health[0] -= 5
					realHP += 5
					aid_inventory[0][1] -= 1
					effects[2][2] = 5
				else:
					$nah.play()
			'radaway':
				if health[0] > 5 and radiation > 0 and aid_inventory[2][1] > 0:
					health[0] -= 5
					radiation -= 50
					aid_inventory[2][1] -= 1
				else:
					$nah.play()
			's-stimpack':
				if health[0] > 5 and realHP < 30 and aid_inventory[1][1] > 0 and effects[2][2] <= 0:
					health[0] -= 5
					realHP = 999
					aid_inventory[1][1] -= 1
					effects[2][2] = 5
				else:
					$nah.play()
			'bandage':
				if effects[0][2] > 0 and aid_inventory[6][1] > 0:
					effects[0][2] = 0
					aid_inventory[6][1] -= 1
				else:
					$nah.play()
			'antidote':
				if effects[1][2] > 0 and aid_inventory[8][1] > 0:
					effects[1][2] = 0
					aid_inventory[8][1] -= 1
				else:
					$nah.play()
			'blood-pack':
				if realHP < 30 and aid_inventory[9][1] > 0:
					realHP += 1
					aid_inventory[9][1] -= 1
				else:
					$nah.play()
			'doctors-bag','first-aid-kit','medic-kit':
				print('wip!')
				$nah.play()
			'heal-spray':
				if health[0] < health[1] and aid_inventory[7][1] > 0 and effects[2][2] <= 0:
					health[0] += 20
					aid_inventory[7][1] -= 1
					effects[2][2] = 5
				else:
					$nah.play()
			_:
				pass

func updateLimits():
	portraitThingy.expression = 0
	specialStats[0] = strength_default
	specialStats[1] = perception_default
	specialStats[2] = endurance_default
	specialStats[3] = charisma_default
	specialStats[4] = intelligence_default
	specialStats[5] = agility_default
	specialStats[6] = luck_default
	stamina[1] = specialStats[5]*10+pkmnSTM
	health[1] = 20+(specialStats[2]*2)+specialStats[0]+pkmnHP
	PP[1] = (specialStats[0]*2)+pkmnPP
	for i in range(0,2):
		if saturations[i] > 100 or health[0] < 0:
			saturations[i] = 100
		if saturations[i] < 0:
			saturations[i] = 0
	if radiation < 0:
		radiation = 0
	if health[0] > health[1]:
		health[0] = health[1]
	if stamina[0] > stamina[1]:
		stamina[0] = stamina[1]
	if PP[0] > PP[1]:
		PP[0] = PP[1]
	if stamina[0] < 0:
		stamina[0] = 0
		exhausted = true
	if stamina[0] > 10:
		exhausted = false
	if radiation > 1050:
		health[0] -= 1
		radiation = 1050
	for i in range(0,conditions.size()):
		if conditions[i][1] > conditions[i][2]:
			conditions[i][1] = conditions[i][2]
	if health[0] < 0:
		realHP -= 1
		health[0] += 1
	if realHP > 30:
		realHP = 30

func runPortraitUpdate():
	if stamina[0] <= (stamina[1]*0.3) or health[0] <= 10:
		portraitThingy.expression = 2
	if health[0] <= 4:
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
			charLevel = saved_data['level']
			totalExp = saved_data['exp']
			isFemale = saved_data["female"]
			radiation = saved_data["radiation"]
			weapons_inventory[0][1] = saved_data['weapon_pistol']
			aid_inventory[0][1] = saved_data['stimpacks']
			aid_inventory[2][1] = saved_data['radaways']
			aid_inventory[1][1] = saved_data['s-stimpacks']
			aid_inventory[3][1] = saved_data['doctors-bag']
			aid_inventory[4][1] = saved_data['first-aid-kit']
			aid_inventory[5][1] = saved_data['medical-kit']
			aid_inventory[6][1] = saved_data['bandage']
			aid_inventory[7][1] = saved_data['heal-spray']
			aid_inventory[8][1] = saved_data['antidote']
			aid_inventory[9][1] = saved_data['blood-pack']
			conditions[0][1] = saved_data["head_cnd"]
			conditions[1][1] = saved_data["chest_cnd"]
			conditions[2][1] = saved_data["larm_cnd"]
			conditions[3][1] = saved_data["rarm_cnd"]
			conditions[4][1] = saved_data["lleg_cnd"]
			conditions[5][1] = saved_data["rleg_cnd"]
			conditions[6][1] = saved_data["other_cnd"]
			
			input_direction = saved_data["direction"]
			stamina[0] = saved_data["stamina"]
			PP[0] = saved_data["pp"]
			health[0] = saved_data['health']
			realHP = saved_data['real_hp']
			
			bodyTemp = saved_data["body_temp"]
			
			time.localTime = saved_data["time"]
			time.day = saved_data["day"]
			
			saturations[0] = saved_data["hunger"]
			saturations[1] = saved_data["thirst"]
			saturations[2] = saved_data["sleep"]
			
			self.global_position.x = saved_data["pos_x"]
			self.global_position.y = saved_data["pos_y"]
			
			match otherCNDtype:
				'tail':
					conditions[6][2] = 50
				'wings':
					conditions[6][2] = 30
				_:
					conditions[6][2] = 0
				
			conditions[6][0] = otherCNDtype.to_upper()
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
	saved_data["stamina"] = stamina[0]
	saved_data["pp"] = PP[0]
	saved_data['health'] = health[0]
	saved_data['real_hp'] = realHP
	
	saved_data["radiation"] = radiation
	
	saved_data["head_cnd"] = conditions[0][1] 
	saved_data["chest_cnd"] = conditions[1][1] 
	saved_data["larm_cnd"] = conditions[2][1] 
	saved_data["rarm_cnd"] = conditions[3][1]
	saved_data["lleg_cnd"] = conditions[4][1]
	saved_data["rleg_cnd"] = conditions[5][1]
	saved_data["other_cnd"] = conditions[6][1]
	
	saved_data["body_temp"] = bodyTemp
	
	saved_data["weapon_difficulty"] = weaponDifficulty
	saved_data["extra_limb"] = otherCNDtype
	
	saved_data["time"] = time.localTime
	saved_data["day"] = time.day
	
	saved_data["hunger"] = saturations[0]
	saved_data["thirst"] = saturations[1]
	saved_data["sleep"] = saturations[2]
	
	#inventory
	saved_data['weapon_pistol'] = weapons_inventory[0][1]
	
	saved_data['stimpacks'] = aid_inventory[0][1]
	saved_data['s-stimpacks'] = aid_inventory[1][1]
	saved_data['radaways'] = aid_inventory[2][1]
	saved_data['doctors-bag'] =  aid_inventory[3][1]
	saved_data['first-aid-kit'] =  aid_inventory[4][1]
	saved_data['medical-kit'] =  aid_inventory[5][1]
	saved_data['bandage'] = aid_inventory[6][1]
	saved_data['heal-spray'] =  aid_inventory[7][1]
	saved_data['antidote'] = aid_inventory[8][1]
	saved_data['blood-pack'] =  aid_inventory[9][1]
	
	saved_data['level'] = charLevel
	saved_data['exp'] = totalExp
	
	saved_data["pos_x"] = self.global_position.x
	saved_data["pos_y"] = self.global_position.y
	
	var json = JSON.stringify(saved_data)
	
	#print('game saved')
		
	file.store_string(json)
	file.close()
