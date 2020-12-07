extends Node
# Global Class

var total_bots

var bot_list = []

func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func create_new_bot():
	# emit signal?
	pass


func add_bot_to_list(bot):
	bot_list.append(bot)
