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
var running = false
var norm_speed = 20
var run_speed = 30
var dgsr = 1

func _ready():
	pglobal.active = true
	dif()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	$CollisionShape/Neck/Head/Camera/Position3D.hide()
	$CollisionShape/Neck/Head/Camera/cent/crosshair/interaction.text = ""
	head_raycast.add_exception($".")
	var mn = 0
	while true:
		if mn != pglobal.mods.size():
			var success = ProjectSettings.load_resource_pack(pglobal.mods[mn])
			if success:
				print("Loaded Mod")
				var mod = load(pglobal.modss[mn]).instance()
				get_node("/root").add_child(mod)
			else:
				print("Failed To Load Mod")
			mn = mn + 1
		else:
			break
	if "flashlight" in pglobal.inv:
		$CollisionShape/Neck/Head/Camera/flashlight.show()
	else:
		$CollisionShape/Neck/Head/Camera/flashlight.hide()

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
	$gui/health.max_value = pglobal.max_health
	$gui/health.value = pglobal.health
	#$gui/health/noh.text = str(str(pglobal.health) + "/" + str(pglobal.max_health))
	$gui/stamina.value = pglobal.stamina
	#$gui/stamina/nos.text = str(str(pglobal.stamina) + "/100")
	$gui/ammo.text = str(pglobal.ammo)
	if running:
		pglobal.stamina = pglobal.stamina - dgsr
		if pglobal.stamina <= 0:
			pglobal.stamina = 0
	if head_raycast.is_colliding():
		var obj = head_raycast.get_collider()
		if obj.get_name() in pglobal.objects:
			$CollisionShape/Neck/Head/Camera/cent/crosshair/interaction.text = "E - Interact"
			intobj = obj.get_name()
			interact = true
		else:
			if long_raycast.is_colliding():
				obj = long_raycast.get_collider()
				if "door" in obj.get_name():
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
		else:
			$CollisionShape/Neck/Head/Camera/cent/crosshair/interaction.text = ""
			interact = false
	
	if Input.is_action_just_pressed("fullscreen"):
		OS.window_fullscreen = !OS.window_fullscreen
	
	
	if Input.is_action_just_pressed("toggle_mouse_capture"):
		pause()
	
	if Input.is_action_pressed("run"):
		if not pglobal.stamina == 0:
			speed = run_speed
			running = true
	else:
		speed = norm_speed
		running = false
	
	if Input.is_action_just_pressed("interact"):
		if interact:
			emit_signal("interact")
	if movement:
		var forward_back = Input.get_action_strength("move_forwards") - Input.get_action_strength("move_backwards")
		var left_right = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
		if forward_back==0 and left_right==0:
			$CollisionShape/jack/RootNode/AnimationPlayer.stop()
			$CollisionShape/jack/RootNode/AnimationPlayer.play("idle2")
		else:
			if Input.is_action_pressed("move_forwards"):
				$CollisionShape/jack/RootNode/AnimationPlayer.play("walking")
			elif Input.is_action_pressed("move_backwards"):
				$CollisionShape/jack/RootNode/AnimationPlayer.play_backwards("walking")
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

func dif():
	if pglobal.difficulty == 0:
		dgsr = 0.015
		run_speed = 35
	elif pglobal.difficulty == 1:
		dgsr = 0.055
		run_speed = 30
	elif pglobal.difficulty == 2:
		dgsr = 0.200
		run_speed = 30
	elif pglobal.difficulty == 3:
		dgsr = 0.500 # Your Cant run whatsoever without losing all your stamina
		run_speed = 25 # its also almost pointless to run
	elif pglobal.difficulty == -1:
		dgsr = 0.001 # Detroit Mode Near Infinite Running
		run_speed = 75 # Detroit SPEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEED
