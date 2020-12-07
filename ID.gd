extends Label


func _ready():
	yield(get_tree(), "idle_frame")
	#print(get_parent().id)
	self.text = str(get_parent().id)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
	
