extends KinematicBody
class_name Player

var movement_vector:Vector3
var speed:float = 20
var mouse_sensitivity:float = 0.3

signal unpause
signal pause
signal interact
signal door

onready var neck:MeshInstance = $CollisionShape/Neck
onready var head:MeshInstance = $CollisionShape/Neck/Head
onready var body:MeshInstance = $CollisionShape/Body
onready var head_raycast:RayCast = $CollisionShape/Neck/Head/HeadRayCast
onready var long_raycast:RayCast = $CollisionShape/Neck/Head/longrange
onready var pglobal = get_node("/root/Playerglobal")
var interact = false
var intobj = ""
var doorname = ""
var movement = true
var pause = false

func _ready():
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	$CollisionShape/Neck/Head/Camera/Position3D.hide()
	$CollisionShape/Neck/Head/Camera/cent/crosshair/interaction.text = ""
	head_raycast.add_exception($".")

func _on_root_resize():
	$CollisionShape/Neck/Head/Camera/cent.rect_size =  get_tree().root.size;

func _input(event):
	if movement:
		if event is InputEventMouseMotion:
			var left_right = deg2rad(event.relative.x * mouse_sensitivity)
			var up_down = deg2rad(event.relative.y * mouse_sensitivity)
		
			head.rotate_x(up_down)
			#neck.rotate_z(left_right)
		
			#if neck.rotation.z <= deg2rad(-75) or neck.rotation.z >= deg2rad(75):
			self.rotate_y(-left_right)
		
			head.rotation.x = clamp(head.rotation.x, deg2rad(-75), deg2rad(75))
			neck.rotation.z = clamp(neck.rotation.z, deg2rad(-75), deg2rad(75))


func _process(delta):
	if head_raycast.is_colliding():
		var obj = head_raycast.get_collider()
		if obj.get_name() in pglobal.objects:
			$CollisionShape/Neck/Head/Camera/cent/crosshair/interaction.text = "E - Interact"
			intobj = obj.get_name()
			interact = true
		else:
			if long_raycast.is_colliding():
				obj = long_raycast.get_collider()
				if obj.get_name() == "door":
					emit_signal("door")
				else:
					$CollisionShape/Neck/Head/Camera/cent/crosshair/interaction.text = ""
					interact = false
			else:
				$CollisionShape/Neck/Head/Camera/cent/crosshair/interaction.text = ""
				interact = false
	else:
		if long_raycast.is_colliding():
			var obj = long_raycast.get_collider()
			if "door" in obj.get_name():
				doorname = obj.get_name()
				emit_signal("door")
			else:
				$CollisionShape/Neck/Head/Camera/cent/crosshair/interaction.text = ""
				interact = false
		else:
			$CollisionShape/Neck/Head/Camera/cent/crosshair/interaction.text = ""
			interact = false
	
	if Input.is_action_just_pressed("fullscreen"):
		OS.window_fullscreen = !OS.window_fullscreen
	
	
	if Input.is_action_just_pressed("toggle_mouse_capture"):
		pause()
	
	if Input.is_action_pressed("run"):
		speed = 30
	else:
		speed = 20
	
	if Input.is_action_just_pressed("interact"):
		if interact:
			emit_signal("interact")
	if movement:
		var forward_back = Input.get_action_strength("move_forwards") - Input.get_action_strength("move_backwards")
		var left_right = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
							
		var direction = (self.transform.basis.z * forward_back - self.transform.basis.x * left_right).normalized()
	
		var new_movement_vector = lerp(movement_vector, direction * speed, 0.25)

		new_movement_vector.y = -9.8

		movement_vector = self.move_and_slide(new_movement_vector, Vector3.UP)
	
	
func pause():
	if pause == true:
		emit_signal("unpause")
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		movement = true
		pause = false
	elif pause == false:
		emit_signal("pause")
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		movement = false
		pause = true
	else:
		printerr("No Pause?")


func _on_menus_unpause():
	pause()
