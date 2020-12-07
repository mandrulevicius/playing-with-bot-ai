extends Camera2D

var i = 0
var zoomScale = 0.005
var cameraMoveSpeed = 1

var zoomVector=Vector2(2, 2) 


func _ready():
	self.zoom = zoomVector
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_key_pressed(KEY_N):
	#if Input.is_action_pressed("ui_middlemouseup"):
		print('Size: ',self.zoom)  
		zoomVector = self.zoom + Vector2(zoomScale, zoomScale)
		self.zoom = zoomVector
	if Input.is_key_pressed(KEY_Y):
	#if Input.is_action_pressed("ui_middlemousedown"): # why doesnt register action?
		print('Size: ',self.zoom)  
		zoomVector = self.zoom - Vector2(zoomScale, zoomScale)
		self.zoom = zoomVector
		
	if Input.is_key_pressed(KEY_A):
		print('Camera Position: ',self.position)  
		self.position = self.position + Vector2(-cameraMoveSpeed*zoomScale*100,0)
	if Input.is_key_pressed(KEY_D):
		print('Camera Position: ',self.position)  
		self.position = self.position + Vector2(cameraMoveSpeed*zoomScale*100,0)
	if Input.is_key_pressed(KEY_W):
		print('Camera Position: ',self.position)  
		self.position = self.position + Vector2(0,-cameraMoveSpeed*100*zoomScale)
	if Input.is_key_pressed(KEY_S):
		print('Camera Position: ',self.position)  
		self.position = self.position + Vector2(0,cameraMoveSpeed*100*zoomScale)
		
		
	#------------- Scaling Zoom
	if zoomVector.x/zoomScale < 10:
		zoomScale = zoomScale / 10
		print('zoomVector: ',zoomVector.x)  
		print('zoomScale decreased: ',zoomScale)  
	elif zoomVector.x/zoomScale > 100:
		zoomScale = zoomScale * 10
		print('zoomVector: ',zoomVector.x)  
		print('zoomScale increased: ',zoomScale)  
