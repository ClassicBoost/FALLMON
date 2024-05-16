extends Control

var highlighted:String = ''
@onready var image = $HP
@onready var portraitSprite = $HP/front/portrait

@onready var player = get_owner().get_node("Player")
@onready var portraitThingy = get_owner().get_node("UI/HUD/HP/front/portrait")
var portrait:String = 'unown'

@onready var healthBar:TextureProgressBar = $HP/front/healthBar
@onready var staminaBar:TextureProgressBar = $Stamina/stamina/staminaBar

func _ready():
	image.modulate.a = 0.5
	$Stamina.modulate.a = 0.5
	
func _process(delta):
	if image.modulate.a > 0.5 and highlighted != 'health':
		image.modulate.a -= 0.1 * delta
	if $Stamina.modulate.a > 0.5 and highlighted != 'stamina':
		$Stamina.modulate.a -= 0.1 * delta
	
	healthBar.value = player.health[0]
	healthBar.max_value = player.health[1]
	$HP/front/realHP.value = (player.realHP)
	staminaBar.value = player.stamina[0]
	staminaBar.max_value = player.stamina[1]
	
	portraitSprite.texture = load("res://assets/graphics/portraits/" + portrait + ".png")
	if portraitSprite.texture == null:  # prevent crashing
		portraitSprite.texture = load("res://assets/graphics/portraits/unown.png")
	
	get_json("res://assets/species/data/" + player.charSpecies.to_lower() + ".json")

func get_json(json_path:String):
	if FileAccess.file_exists(json_path):
		var file = FileAccess.open(json_path, FileAccess.READ)
		var json = file.get_as_text()
		
		var saved_data = JSON.parse_string(json)
		
		portrait = saved_data["portrait"]
		
		file.close()
	else:
		portrait = 'unown'

func _on_hp_mouse_entered():
	image.modulate.a = 1
	highlighted = 'health'

func _on_stamina_mouse_entered():
	$Stamina.modulate.a = 1
	highlighted = 'stamina'


func _on_mouse_exited():
	highlighted = ''

func _on_stamina_bar_value_changed(_value):
	$Stamina.modulate.a = 1


func _on_health_bar_value_changed(_value):
	image.modulate.a = 1
