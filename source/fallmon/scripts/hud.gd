extends Control

var highlighted:bool = false
@onready var image = $NinePatchRect

@onready var player = get_owner().get_node("Player")

func _ready():
	image.modulate.a = 0.5
	
func _process(delta):
	if image.modulate.a > 0.5 and not highlighted:
		image.modulate.a -= 0.1 * delta
	$NinePatchRect/healthBar.value = (player.health/player.maxHealth) * 100
	

func _on_mouse_entered():
	image.modulate.a = 1
	highlighted = true

func _on_mouse_exited():
	highlighted = false
