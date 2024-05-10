extends CharacterBody2D

var moveSpeed:float = 130

@onready var animation_tree = $AnimationTree
@onready var sprite = $sprites
@onready var anim_player:AnimationPlayer = $AnimationPlayer

@export var charSpecies:String = 'snivy'

@export var health:float = 35
@export var maxHealth:int = 35

@export var realHP:int = 30

var moving:bool = false

var running:bool = false

func _ready():
	updateAnim(Vector2(0, 1))

func _physics_process(delta):
	moving = false
	running = false
	var input_direction = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	)
	
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
	if (velocity != Vector2.ZERO):
		sprite.texture = load("res://assets/species/species/" + charSpecies + "/walk.png")
	else:
		sprite.texture = load("res://assets/species/species/" + charSpecies + "/idle.png")
