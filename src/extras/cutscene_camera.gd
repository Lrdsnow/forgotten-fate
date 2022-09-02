extends Camera3D


# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _input(event):
	self.call_deferred("cam", event)


func cam(event):
	if true:
		if event is InputEventMouseMotion:
			var left_right = deg_to_rad(event.relative.x * Global.mouse_sensitivity)
			var up_down = deg_to_rad(event.relative.y * Global.mouse_sensitivity)
		
			self.rotate_x(-up_down)
			#neck.rotate_z(left_right)
		
			#if neck.rotation.z <= deg_to_rad(-75) or neck.rotation.z >= deg_to_rad(75):
			self.rotate_y(-left_right)
			
			
			self.rotation.x = clamp(self.rotation.x, deg_to_rad(0), deg_to_rad(0))
			self.rotation.z = clamp(self.rotation.z, deg_to_rad(0), deg_to_rad(0))
			self.rotation.y = clamp(self.rotation.y, deg_to_rad(-140), deg_to_rad(-50))
		elif event is InputEventJoypadMotion:
			var left_right = deg_to_rad(Input.get_joy_axis(0, 2) * Global.mouse_sensitivity)
			var up_down = deg_to_rad(Input.get_joy_axis(0, 3) * Global.mouse_sensitivity)
		
			self.rotate_x(-up_down)
			#neck.rotate_z(left_right)
		
			#if neck.rotation.z <= deg_to_rad(-75) or neck.rotation.z >= deg_to_rad(75):
			self.rotate_y(-left_right)
		
			self.rotation.x = clamp(self.rotation.x, deg_to_rad(-75), deg_to_rad(75))
			#self.rotation.z = clamp(self.rotation.z, deg_to_rad(-75), deg_to_rad(75))
