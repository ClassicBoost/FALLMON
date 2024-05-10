extends Node2D

# Called when the node enters the scene tree for the first time.
var wait:float = 1
func _ready():
	preload("res://source/fallmon/scenes/game/Main_Menu.tscn").instantiate()

func _process(delta):
	wait -= 1 * delta
	
	if wait < 0:
		get_tree().change_scene_to_file("res://source/fallmon/scenes/game/Main_Menu.tscn")
