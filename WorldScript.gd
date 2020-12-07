extends Node

var resource_scene = load("res://ResourceScene.tscn")
var resource_node

var i = 0

var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	i += delta
	if i >= 4:
		i = 0
		resource_node = resource_scene.instance()
		rng.randomize()
		resource_node.position = Vector2(rng.randi_range(-1000, 1000), rng.randi_range(-1000, 1000))
		add_child(resource_node)
		
	
