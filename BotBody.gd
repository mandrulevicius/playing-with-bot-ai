extends KinematicBody2D
# Bot Class
var STARTING_RESOURCES = 1000
var STARTING_BUILD_COST = 100

var speed = 50
var direction = Vector2(0,0)

var bot_build_time = 2

# dictionaries instead of lists for stats? or objects, but first dictionaries

var parent_id
var parent_build = []

var id
var current_version = []
var current_template = []

var total_bots_built = 0

var initial_resources
var current_total_resources

var goals	#improve, build, explore, find viable size-reducing builds, survive.
var current_efficiency
# track goals and efficiency through multiple variables

enum Objectives {AVOID_COLLISION, GATHER_RESOURCE, BUILD_NEW_BOT, FOLLOW_PARENT, SPREAD_OUT, EXPLORE}

# build a clone
# first goal - ask for attention in the middle of the screen
# ui for info viewing
var self_scene = load("res://BotBodyScene.tscn")
var self_node

var rng = RandomNumberGenerator.new()

var i = 0

var close_objects = []
var visible_objects = []


func _ready():
	parent_id = "-1"
	id = "0"
	initial_resources = STARTING_RESOURCES*10 # initial resources should be in template?
	current_version.append(STARTING_RESOURCES)
	current_version.append(STARTING_BUILD_COST)
	parent_build = current_version
	current_template = current_version
	current_total_resources = initial_resources
	
	self.set_stats_label()
	
	Global.add_bot_to_list(self)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	i += delta
	if Input.is_action_just_released("ui_build"):
		self.build_new_bot(id, current_version, current_template)
	if i > 2: # (process runs faster than 60fps) - now just uses seconds
		i = 0
		#print('step')
		#print(self.global_position)
		#for visible_object in visible_objects:
			#print("Visible object: ", visible_object)
			#print("Visible object position: ", visible_object.global_position)
		#self.move_and_slide(Vector2(5000,5000)) # slow
		#print("self: %s | parent ID %s" % [self.id, parent_id])
	
	act()
	
	for collision_no in (get_slide_count() - 1):
		var collision = get_slide_collision(collision_no) # can bug out and be empty when new bot built. Or spawned on top?
		print("Collided with: ", collision.collider.name)  # still bugs out sometimes
		if "Resource" in collision.collider.name:
			print("Collided with object: ", collision.collider)
			collision.collider.queue_free()
			current_total_resources += 100
			print("current_total_resources: " + str(current_total_resources))


func set_stats_label():
	$Stats.text = ("ID: " + str(id) + "\n" + 
		"Parent ID: " + str(parent_id) + "\n" + 
		"Parent build: " + str(parent_build) + "\n" +
		"initial_resources: " + str(initial_resources) + "\n" + 
		"current_total_resources: " + str(current_total_resources) + "\n"
		)


func get_version_info():  # returns all template info
	# return only current version or include history? probably better to separate
	pass
	
	
func update_self_version(): # update only after new build is tested for issues
							# and makes a tested second generation
							# and makes a tested third generation
	pass
	
	
func get_build_template(): # returns current construction template
	pass
	
	
func update_build_template():
	pass
	
	
func build_new_bot(building_parent_id, building_parent_build, build):
	yield(get_tree().create_timer(bot_build_time), "timeout")
	print('<Bot %s | Build %s> Trying to build a bot model %s' % [str(building_parent_id), building_parent_build, build])
	#Global.create_new_bot()
	#get_parent().add_child()
	if current_total_resources - build[0] - build[1] > building_parent_build[0]:
		print('<Bot %s | Build %s> current_total_resources: %s' % [str(building_parent_id), building_parent_build, current_total_resources])
		print('<Bot %s | Build %s> current_template initial_resources: %s' % [str(building_parent_id), building_parent_build, current_template[0]])
		print('<Bot %s | Build %s> current_version initial_resources: %s' % [str(building_parent_id), building_parent_build, current_version[0]])
		current_total_resources = current_total_resources - build[0] - build[1]
		self_node = self_scene.instance()
		self_node.position = self.global_position # self is a node2d, not a kinematicbody2d
		get_parent().add_child(self_node)
		self_node.parent_id = building_parent_id
		self_node.parent_build = building_parent_build
		self_node.id = str(building_parent_id) + '_' + str(total_bots_built)
		self_node.current_version = build
		self_node.current_total_resources = build[0]
		self_node.current_template = self_node.current_version
		
		self.set_stats_label()
		self_node.set_stats_label()
		
		total_bots_built += 1
		var output_string = '<Bot %s | Build %s> Building new bot id %s'
		print(output_string % [str(building_parent_id), building_parent_build, str(parent_id) + '_' + str(total_bots_built)])
		return true
	return false
	# should return bots construction template?


func add_mutation():
	pass
	# rolls for a small chance to apply a modification to the template before starting to build a new bot
	# if modification occurs, saves the template (and conditions) to a log/database (should there be outside variables affecting this? for particular desired mutations. Otherwise, will be reliant on natura selection)


func act():
	if collision_object_nearby():
		return Objectives.AVOID_COLLISION
	if resource_visible() > 1:
		return Objectives.GATHER_RESOURCE
	if can_build():
		return Objectives.BUILD_NEW_BOT
	#if parent_visible():
	#	return Objectives.FOLLOW_PARENT
	if spread_out():
		return Objectives.SPREAD_OUT
	explore()
	return Objectives.EXPLORE


func collision_object_nearby():
	var closest_object
	var closest_object_distance
	var nearby_resource_count = 0
	var nearby_resource
	for nearby_object in close_objects:
		if not "Resource" in nearby_object.name:
			if not closest_object:
				closest_object = nearby_object
				closest_object_distance = self.global_position.distance_to(nearby_object.global_position)
			else:
				if self.global_position.distance_to(nearby_object.global_position) < closest_object_distance:
					closest_object = nearby_object
					closest_object_distance = self.global_position.distance_to(nearby_object.global_position)
		else:
			nearby_resource_count += 1
			nearby_resource = nearby_object
	if not closest_object:
		if (nearby_resource_count == 1) and (resource_visible() == 1): # this is getting messy, seems to introduce a stutter
			self.move_and_slide((-speed)*(nearby_resource.global_position - self.global_position).normalized()) 
			return true
		else:
			return false
	else:
		self.move_and_slide((-speed)*(closest_object.global_position - self.global_position).normalized()) # try global position differences - seems to be working?
		# normalize give you direction with minimum speed?
		
		# actually learn how move and slide works - might need it for other movements, we will see
		# learn by experimenting with it
		return true


func resource_visible():
	var closest_resource
	var closest_resource_distance
	var visible_resource_count = 0 
	# later upgrade to counting in clusters/quadrants/directions(degrees)?
	# if more than 1 in direction of closest one +- 10 degrees
	for visible_resource in visible_objects:
		if "Resource" in visible_resource.name:
			visible_resource_count += 1
			if not closest_resource:
				closest_resource = visible_resource
				closest_resource_distance = self.global_position.distance_to(visible_resource.global_position)
			else:
				if self.global_position.distance_to(visible_resource.global_position) < closest_resource_distance:
					closest_resource = visible_resource
					closest_resource_distance = self.global_position.distance_to(visible_resource.global_position)
	if not closest_resource:
		return visible_resource_count
	elif visible_resource_count > 1:
		self.move_and_slide(speed*(closest_resource.global_position - self.global_position).normalized()) 
		return visible_resource_count
	else:
		return visible_resource_count


func can_build():
	if $BuildCooldownTimer.time_left <= 0.1:
		$BuildCooldownTimer.start()
		return build_new_bot(id, current_version, current_template)
	return false


func parent_visible():
	# discarded for now
	var moved = false
	for visible_object in visible_objects:
		if "Bot" in visible_object.name:
			if self.parent_id == visible_object.id:
				#print("Bot %s sees parent bot %s" % [self.id, visible_object.id])
				self.move_and_slide(speed*(visible_object.global_position - self.global_position).normalized())
				moved = true
				# messy, one always follows parent, making parent run from it
				# ditch parent following for now?
			else:
				self.move_and_slide(-speed*(visible_object.global_position - self.global_position).normalized())
				moved = true
	return moved


func spread_out():
	var closest_bot
	var closest_bot_distance
	if $SpreadOutTimer.time_left <= 0.1:
		$SpreadOutTimer.start()
		for visible_object in visible_objects:
			if "Bot" in visible_object.name:
				if not closest_bot:
					closest_bot = visible_object
					closest_bot_distance = self.global_position.distance_to(visible_object.global_position)
				elif self.global_position.distance_to(visible_object.global_position) < closest_bot_distance:
					closest_bot = visible_object
					closest_bot_distance = self.global_position.distance_to(visible_object.global_position)
			
		if closest_bot:
			direction = -(closest_bot.global_position - self.global_position).normalized()
	#self.move_and_slide(speed*direction)
	return false


func explore():
	if $DirectionChangeTimer.time_left <= 0.1:
		$DirectionChangeTimer.start()
		rng.randomize()
		direction = Vector2(rng.randf_range(-1, 1),rng.randf_range(-1, 1))
	self.move_and_slide(speed * direction)


func _on_KinematicBody2D_mouse_entered():
	if not $Stats.visible:
		$Stats.visible = true
	


func _on_KinematicBody2D_mouse_exited():
	if $Stats.visible:
		$Stats.visible = false
	


func _on_PersonalSpace_body_entered(body):
	if body != self:
		#print("adding object to personal space: ", str(body))
		close_objects.append(body)
		#print("body name: ", str(body.name))


func _on_PersonalSpace_body_exited(body):
	if body != self:
		#print("removing object from personal space: ", str(body))
		close_objects.erase(body)


func _on_Vision_body_entered(body):
	if body != self:
		#print("adding object to vision: ", str(body))
		visible_objects.append(body)


func _on_Vision_body_exited(body):
	if body != self:
		#print("removing object from vision: ", str(body))
		visible_objects.erase(body)
