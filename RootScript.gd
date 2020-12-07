extends Node


func _ready():
	pass # Replace with function body.


func _process(_delta):
	if Input.is_action_just_released("ui_pause"):
		if get_tree().paused:
			get_tree().paused = false
		else:
			get_tree().paused = true
