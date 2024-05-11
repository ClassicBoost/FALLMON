extends Control

var highlighted:bool = false
@onready var image = $NinePatchRect

@onready var player = get_owner().get_node("Player")
var portrait:String = 'unown'

func _ready():
	image.modulate.a = 0.5
	
func _process(delta):
	if image.modulate.a > 0.5 and not highlighted:
		image.modulate.a -= 0.1 * delta
	$NinePatchRect/healthBar.value = (player.health/player.maxHealth) * 100
	
	$NinePatchRect/front/portrait.texture = load("res://assets/graphics/portraits/" + portrait + ".png")
	
	get_json()
	

func _on_mouse_entered():
	image.modulate.a = 1
	highlighted = true

func _on_mouse_exited():
	highlighted = false

@onready var json_path = "res://assets/species/data/" + player.charSpecies.to_lower() + ".json"
	
func get_json():
	if FileAccess.file_exists(json_path):
		var file = FileAccess.open(json_path, FileAccess.READ)
		var json = file.get_as_text()
		
		var saved_data = JSON.parse_string(json)
		
		portrait = saved_data["portrait"]
		
		file.close()
	else:
		print('bleh')
		portrait = 'unown'
