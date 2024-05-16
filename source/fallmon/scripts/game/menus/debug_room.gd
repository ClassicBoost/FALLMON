extends Node2D

@onready var portraitThingy = $Control/Portrait/portrait

func _ready():
	pass

func _process(_delta):
	if Input.is_action_just_pressed("pause"):
		get_tree().change_scene_to_file("res://source/fallmon/scenes/game/Main_Menu.tscn")
	
func _on_portrait_value_changed(value):
	portraitThingy.expression = value


func _on_portrait_icon_text_text_submitted(new_text):
	portraitThingy.texture = load("res://assets/graphics/portraits/" + new_text + ".png")
	if portraitThingy.texture == null:  # prevent crashing
		portraitThingy.texture = load("res://assets/graphics/portraits/unown.png")
