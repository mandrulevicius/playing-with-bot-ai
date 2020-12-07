extends ItemList

var i = 0

func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	i += delta
	if i > 1:
		self.clear()
		for object in Global.bot_list:
			self.add_item(object.id)


func _on_ItemList_item_selected(index):
	print("ITEM SELECTED:  ", Global.bot_list[index].id)
