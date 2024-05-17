extends Control

@export var localTime:float = 510
@export var day:int = 0

@onready var blah:NinePatchRect = $NinePatchRect

func _process(delta):
	localTime += 0.2 * delta
	if localTime > 1440:
		localTime = 0
		day += 1
	
	if localTime > 1080:
		blah.modulate.a = 1 * ((localTime-1080)/360)
	else:
		blah.modulate.a = 1 * ((440-localTime)/440)
