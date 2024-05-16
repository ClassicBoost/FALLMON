extends Node2D
@onready var player = $Player

var inArea = false

func _on_radiation_area_body_entered(body):
	if body.get_name() == 'Player':
		inArea = true

func _on_radiation_area_body_exited(body):
	if body.get_name() == 'Player':
		inArea = false
		
func _process(delta):
	if inArea:
		player.radiation += 1 * delta
