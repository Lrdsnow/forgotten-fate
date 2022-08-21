extends CharacterBody3D

var SPEED = 5.0
var JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidDynamicBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var movement:Dictionary = {
	"can_aim":true,
	"shooting":false,
	"aiming":false,
	"croutching":false,
	"runnin":false
}

var interaction:Dictionary = {
	"is_hovering":false,
	"can_interact":false,
	"type":"",
	"item":null
}


func _ready():
	Global.ingame = true
	Game.emit_signal("on_game_started")
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	update_held()
	$nametag.text = Global.player_name
	Global.load_complete.connect(self._load)
	get_node(self.get_meta("quest")).check_quest()

func _load():
	position = Global.pos
	rotation = Global.rot
	#Global.update_item.connect(self.update_held())

func _physics_process(delta):
	if Global.can_move and not Global.paused:
		update_held()
		check_look()
		handle_stats()
	if not is_on_floor():
		velocity.y -= gravity * delta
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	if Input.is_action_just_pressed("croutch"):
		if movement.croutching:
			$anim.play_backwards("croutch")
			SPEED=SPEED+3.5
			movement.croutching = false
		else:
			$anim.play("croutch")
			SPEED=SPEED-3.5
			movement.croutching = true
	if Input.is_action_pressed("aim"):
		if movement.can_aim:
			if ! movement.aiming:
				$anim.play("aim")
				movement.aiming = true
	else:
		if movement.aiming:
			$anim.play_backwards("aim")
			movement.aiming = false
	if Input.is_action_pressed("shoot"): # This is stupid code :|
		if Global.can_move:
			if not movement.shooting:
				if movement.aiming:
					if Global.ammo_clip != 0:
						movement.shooting=true
						$anim.play("shoot+aim")
						Global.ammo_clip = Global.ammo_clip - 1
					else:
						$anim.play("no_ammo")
				else:
					if Global.ammo_clip != 0:
						movement.shooting=false
						$anim.play("shoot")
						Global.ammo_clip = Global.ammo_clip - 1
					else:
						$anim.play("no_ammo")
	if Input.is_action_just_pressed("pause"):
		if ! Global.paused:
			$ui/cc/ui/gui/gui_anim.play("pause")
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			Global.paused=true
			Global.can_move=false
		else:
			$ui/cc/ui/gui/gui_anim.play_backwards("pause")
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			Global.paused=false
			Global.can_move=true
	if Input.is_action_pressed("runnin"):
		if Global.stamina != 0:
			movement.runnin = true
			SPEED = 10
			Global.stamina = Global.stamina - 0.001
	if Input.is_action_just_released("runnin"):
		movement.runnin = false
		SPEED = 5
	if Input.is_action_just_pressed("interact"):
		if interaction.is_hovering:
			if interaction.can_interact:
				if interaction.type == "item":
					Global.interact.connect(Global.item_objs[interaction.item.name].interact.bind(interaction.item))
					Global.emit_signal("interact")
				elif interaction.type == "door":
					interaction.item.set_meta("status", "open")
					interaction.item.get_node(interaction.item.get_meta("anim")).play("open_fast")
					interaction.item.get_node(interaction.item.get_meta("col")).disabled = true
					#interaction.item.call_deferred("queue_free")
					if Global.current_quest().has("anim"):
						if interaction.has("floor"):
							interaction.floor.init_animation(interaction.item.name)
				elif interaction.type == "hide":
					interaction.floor.init_animation(interaction.item.name)
				get_node(self.get_meta("quest")).check_quest(interaction.item)
			else:
				$ui/cc/ui/gui/gui_anim.play("cant_interact")
	if Input.is_action_pressed("left") or Input.is_action_pressed("right") or Input.is_action_pressed("forwards") or Input.is_action_pressed("backwards"):
		if not movement.runnin:
			$movement.play("walkin")
		else:
			$movement.play("runnin")
	if Input.is_action_just_released("left") or Input.is_action_just_released("right") or Input.is_action_just_released("forwards") or Input.is_action_just_released("backwards"):
		$movement.stop()
		$collision/neck/head/player_camera.position = Vector3(0,0.7,0)
	var input_dir = Input.get_vector("left", "right", "forwards", "backwards")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	move_and_slide()

func handle_stats():
	if Global.health == 0:
		Global.can_move = false
		movement.can_aim = false
		$ui/cc/ui/transition.play("death")
		print("Game: Player Has Died")
		await InputEventKey
		Global.load_checkpoint(Global.checkpoint)
		if not Global.efficiency_mode:
			get_tree().change_scene("res://src/world.tscn")
		else:
			get_tree().change_scene("res://src/extras/efficent_world.tscn")

func refresh_info():
	SPEED = 5.0
	JUMP_VELOCITY = 4.5
	gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
	movement = {
		"can_aim":true,
		"shooting":false,
		"aiming":false,
		"croutching":false,
		"runnin":false
	}
	interaction = {
		"is_hovering":false,
		"can_interact":false,
		"type":"",
		"item":null
	}
	$ui/cc/ui/gui/bars.hide()
	$"ui/cc/ui/gui/cc/cross/int-text".text = ""

func _input(event):
	if Global.can_move:
		if event is InputEventMouseMotion:
			var left_right = deg2rad(event.relative.x * Global.mouse_sensitivity)
			var up_down = deg2rad(event.relative.y * Global.mouse_sensitivity)
		
			$collision/neck/head.rotate_x(-up_down)
			#neck.rotate_z(left_right)
		
			#if neck.rotation.z <= deg2rad(-75) or neck.rotation.z >= deg2rad(75):
			self.rotate_y(-left_right)
		
			$collision/neck/head.rotation.x = clamp($collision/neck/head.rotation.x, deg2rad(-75), deg2rad(75))
			$collision/neck.rotation.z = clamp($collision/neck.rotation.z, deg2rad(-75), deg2rad(75))
		elif event is InputEventJoypadMotion:
			var left_right = deg2rad(Input.get_joy_axis(0, 2) * Global.mouse_sensitivity)
			var up_down = deg2rad(Input.get_joy_axis(0, 3) * Global.mouse_sensitivity)
		
			$collision/neck/head.rotate_x(-up_down)
			#neck.rotate_z(left_right)
		
			#if neck.rotation.z <= deg2rad(-75) or neck.rotation.z >= deg2rad(75):
			self.rotate_y(-left_right)
		
			$collision/neck/head.rotation.x = clamp($collision/neck/head.rotation.x, deg2rad(-75), deg2rad(75))
			$collision/neck.rotation.z = clamp($collision/neck.rotation.z, deg2rad(-75), deg2rad(75))

func update_held():
	var item = "collision/neck/head/items/" + Global.player_held_item
	var item_obj = get_node_or_null(item)
	var og_item = null
	for i in $collision/neck/head/items.get_child_count():
		$collision/neck/head/items.get_child(i).hide()
		for child in $collision/neck/head/items.get_child(i).get_children():
			if child.visible:
				og_item = child
			child.hide()
	if item_obj != null:
		item_obj.show()
		for child in item_obj.get_children():
			child.show()
		var gui_anim = get_node(get_meta("gui_anim"))
		if item in Global.guns:
			if og_item.name in Global.lights:
				gui_anim.play_backwards("switch_power_ammo")
			else:
				gui_anim.play("open_ammo")
		elif item in Global.lights:
			if og_item.name in Global.guns:
				gui_anim.play("switch_power_ammo")
			else:
				gui_anim.play("open_power")
	else:
		pass

func check_look():
	var main_raycast = get_node("collision/neck/head/main_raycast")
	var alt_raycast = get_node("collision/neck/head/alt_raycast")
	if main_raycast.is_colliding():
		if str(main_raycast.get_collider().name) in Global.int_items:
			$"ui/cc/ui/gui/cc/cross/int-text".text = "E - Interact"
			interaction["item"] = main_raycast.get_collider()
			interaction.is_hovering = true
			interaction.can_interact = true
			interaction.type = "item"
		elif str(main_raycast.get_collider().name) in Global.grab_items:
			$"ui/cc/ui/gui/cc/cross/int-text".text = "E - Pick Up"
			interaction["item"] = main_raycast.get_collider()
			interaction.is_hovering = true
			interaction.can_interact = true
			interaction.type = "item"
		elif Global.current_quest().type == "hide":
			if main_raycast.get_collider() in Global.current_quest().hiding_spots:
				$"ui/cc/ui/gui/cc/cross/int-text".text = "E - HIDE!!!!"
				interaction["item"] = main_raycast.get_collider()
				interaction.is_hovering = true
				interaction.can_interact = true
				interaction.type = "hide"
				interaction["floor"] = Global.current_quest().floor
	if alt_raycast.is_colliding():
		if "door" in str(alt_raycast.get_collider().name):
			if "key" in str(Global.doors_lock_status[alt_raycast.get_collider().name]):
				if str(Global.doors_lock_status[alt_raycast.get_collider().name]) in Global.inv:
					$"ui/cc/ui/gui/cc/cross/int-text".text = "E - Unlock"
					interaction["item"] = alt_raycast.get_collider()
					interaction.is_hovering = true
					interaction.can_interact = true
					interaction.type = "door"
				else:
					$"ui/cc/ui/gui/cc/cross/int-text".text = "Requires Key"
					interaction["item"] = null
					interaction.is_hovering = true
					interaction.can_interact = false
					interaction.type = ""
			elif "anim" in str(Global.doors_lock_status[alt_raycast.get_collider().name]):
				if Global.anims[Global.doors_lock_status[alt_raycast.get_collider().name]]:
					$"ui/cc/ui/gui/cc/cross/int-text".text = "E - Open"
					interaction["item"] = alt_raycast.get_collider()
					interaction.is_hovering = true
					interaction.can_interact = true
					interaction.type = "door"
					if Global.current_quest().has("floor"):
						interaction["floor"] = Global.current_quest().floor
				else:
					$"ui/cc/ui/gui/cc/cross/int-text".text = "The door is locked from the otherside"
					interaction["item"] = null
					interaction.is_hovering = true
					interaction.can_interact = false
					interaction.type = ""
			elif str(Global.doors_lock_status[alt_raycast.get_collider().name]) == "unlocked":
				$"ui/cc/ui/gui/cc/cross/int-text".text = "E - Open"
				interaction["item"] = alt_raycast.get_collider()
				interaction.is_hovering = true
				interaction.can_interact = true
				interaction.type = "door"
			else:
				$"ui/cc/ui/gui/cc/cross/int-text".text = "Locked"
				interaction.is_hovering = true
				interaction.can_interact = false
				interaction.type = ""
	else:
		$"ui/cc/ui/gui/cc/cross/int-text".text = ""
		interaction["item"] = null
		interaction.is_hovering = false
		interaction.can_interact = false
		interaction.type = ""

func _on_quit_pressed():
	Global.save_game()
	get_tree().quit()


func _on_save_pressed():
	Global.pos = position
	Global.rot = rotation
	Global.call_deferred("save_game")


func _on_continue_pressed():
	$ui/cc/ui/gui/gui_anim.play_backwards("pause")
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	Global.paused=false
	Global.can_move=true


func _on_shootin_animation_finished(anim_name):
	if anim_name == "shoot" or anim_name == "shoot+aim":
		movement.shooting = false

