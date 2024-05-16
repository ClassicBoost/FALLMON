extends Node2D

var timer:float = 1
var wait:float = 1
func _ready():
	$skip.position.y = 900
	
	if OS.has_feature("mobile"):
		$Overlay/Skip.show()

func _process(delta):
	if Input.is_anything_pressed() and wait < 0:
		$skip.position.y = 648
		timer = 1
	
	timer -= 1 * delta
	wait -= 1 * delta
	if timer < 0:
		$skip.position.y += 30 * delta
	
	if Input.is_action_just_pressed("pause"):
		get_tree().change_scene_to_file("res://source/fallmon/scenes/game/Main_Menu.tscn")

func _on_video_stream_player_finished():
	get_tree().change_scene_to_file("res://source/fallmon/scenes/game/Main_Menu.tscn")


func _on_skip_pressed():
	get_tree().change_scene_to_file("res://source/fallmon/scenes/game/Main_Menu.tscn")
