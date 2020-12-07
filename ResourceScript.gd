extends StaticBody2D
# Resource

# some resources should duplicate over time (grow like grass?)
# some should be non renewable, but worth more

var self_scene = load("res://ResourceScene.tscn")
var self_node

var rng = RandomNumberGenerator.new()

func _ready():
	$Timer.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Timer_timeout():
	#print("Time to generate new grass")
	rng.randomize()
	self_node = self_scene.instance()
	self_node.position = (self.position + 
	$CollisionShape2D.shape.extents.x * 2 * Vector2(rng.randi_range(-1,1),rng.randi_range(-1,1)))
	# + Vector2(rng.randi_range(-20,20),rng.randi_range(-20,20))
	var query = Physics2DShapeQueryParameters.new()
	query.set_transform(self_node.transform)
	query.set_shape($CollisionShape2D.shape)
	
	var space_state = get_world_2d().get_direct_space_state()
	var result = space_state.get_rest_info(query)
	
	if not result:
		get_parent().add_child(self_node)
	print($CollisionShape2D.shape.extents)
	
	# Maybe check how many are nearby, if too much, dont spawn?
