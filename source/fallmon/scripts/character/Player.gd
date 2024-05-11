extends CharacterBody2D

var moveSpeed:float = 130

@onready var animation_tree = $AnimationTree
@onready var sprite = $sprites

# animations have different frames
@onready var anim_player:AnimationPlayer = $fours
@onready var anim_player_six:AnimationPlayer = $fours/sixs

@export var charSpecies:String = 'tepig'

@export var isFemale:bool = false

@export var health:float = 35
@export var maxHealth:int = 35

@export var realHP:int = 30

var moving:bool = false

var running:bool = false

# json
var species_sprite:String = 'example'

func _ready():
	updateAnim(Vector2(0, 1))

func _physics_process(delta):
	moving = false
	running = false
	var input_direction = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	)
	
	get_json()
	
	if health > maxHealth:
		health = maxHealth
	
	if health < 0:
		realHP -= 1
		health += 1
	
	if realHP > 30:
		realHP = 30
	
	if self.velocity.x != 0 or self.velocity.y != 0:
		moving = true
		if Input.is_action_pressed("sprint"):
			running = true
	
	if running and moving:
		moveSpeed = 400
		anim_player.set_speed_scale(3)
	else:
		moveSpeed = 130
		anim_player.set_speed_scale(1)
	
	velocity = (input_direction * moveSpeed) * (delta * 60)
	
	updateAnim(input_direction)

	move_and_slide()
	new_anim_state()

func updateAnim(anim:Vector2):
	if (anim != Vector2.ZERO):
		animation_tree.set("parameters/Idle/blend_position", anim)

func new_anim_state():
	var current_anim:String = 'idle'
	
	if (velocity != Vector2.ZERO):
		sprite.texture = load("res://assets/species/species/" + species_sprite + "/walk.png")
		current_anim = 'walk'
	else:
		sprite.texture = load("res://assets/species/species/" + species_sprite + "/idle.png")
		current_anim = 'idle'
	
	update_offsets(current_anim)


func update_offsets(current_anim:String):
	sprite.set_hframes(4)
	animation_tree.set_animation_player(NodePath("../fours"))
	match current_anim:
		'idle':
			if charSpecies == 'tepig' or charSpecies == 'oshawott' or charSpecies == 'pikachu':
				sprite.set_hframes(6)
				animation_tree.set_animation_player(NodePath("../fours/sixs"))

var json_path = "res://assets/species/data/" + charSpecies.to_lower() + ".json"

func get_json():
	if FileAccess.file_exists(json_path):
		var file = FileAccess.open(json_path, FileAccess.READ)
		var json = file.get_as_text()
		
		var saved_data = JSON.parse_string(json)
		
		species_sprite = saved_data["sprite_male"]
		
		if isFemale:
			species_sprite = saved_data["sprite_female"]
		
		file.close()
	else:
		print('bleh')
