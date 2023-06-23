extends CharacterBody3D

var SPEED = 5.0
var JUMP_VELOCITY = 4.5

#debug lol
@onready var flashlight = %flashlight

# Get the gravity from the project settings to be synced with RigidDynamicBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var bars = false # tells if start anim for bars are finished

var movement:Dictionary = {
	"can_aim":true,
	"shooting":false,
	"aiming":false,
	"croutching":false,
	"runnin":false
}

var held_item:Dictionary = {
	"name":Global.player.held_item.name,
	"obj":Global.player.held_item.obj,
	"type":Global.player.held_item.name
}

var last_interaction:Dictionary = {
	"is_hovering":false,
	"can_interact":false,
	"type":"",
	"item":null
}
var interaction:Dictionary = {
	"is_hovering":false,
	"can_interact":false,
	"type":"",
	"item":null
}


func _ready():
	Game.emit_signal("on_game_started")
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	update_held()
	$nametag.text = Global.player.name
	Global.load_complete.connect(self._load)
	Global.debuglog.connect(self.debug_log)
	get_node(self.get_meta("quest")).check_quest()
	Global.instakill.connect(die)
	%pause.hide()

func _load():
	position = Global.pos
	rotation = Global.rot
	#Global.update_item.connect(self.update_held())

func _physics_process(delta):
	#%ui/gui/info.text = "Self: "+str(rotation)+"\nCam: "+str($collision/neck/head/player_camera.rotation)+"\nHead: "+str($collision/neck/head.rotation)+"\nRot: "+str(rotation+$collision/neck.rotation+$collision/neck/head.rotation)
	if Global.player.can_move and not Global.paused:
		if bars:
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
		if Global.player.can_move:
			if not movement.shooting and not Global.shooting:
				if movement.aiming:
					if Global.player.stats.ammo_clip != 0:
						movement.shooting=true
						var plr_rot = Vector3($collision/neck/head.rotation.x, self.rotation.y, $collision/neck.rotation.z)
						var plr_pos = $collision/neck/head/Marker3d.global_position
						if Global.player.held_item.obj != null:
							Global.player.held_item.obj.shoot(plr_rot, plr_pos)
						call("shot_delay")
						$anim.play("shoot+aim")
						Global.player.stats.ammo_clip = Global.player.stats.ammo_clip - 1
					else:
						$anim.play("no_ammo")
				else:
					if Global.player.stats.ammo_clip != 0:
						movement.shooting=false
						var plr_rot = Vector3($collision/neck/head.rotation.x, self.rotation.y, $collision/neck.rotation.z)
						var plr_pos = $collision/neck/head/Marker3d.global_position
						if Global.player.held_item.obj != null:
							Global.player.held_item.obj.shoot(plr_rot, plr_pos)
						call("shot_delay")
						$anim.play("shoot")
						Global.player.stats.ammo_clip = Global.player.stats.ammo_clip - 1
					else:
						$anim.play("no_ammo")
	if Input.is_action_just_pressed("pause"):
		if ! Global.paused:
			%pause.show()
			%gui/gui_anim.play("pause")
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			Global.paused=true
			Global.player.can_move=false
		else:
			%gui/gui_anim.play_backwards("pause")
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			Global.paused=false
			Global.player.can_move=true
			%pause.hide()
	if Input.is_action_pressed("runnin"):
		if Global.player.stats.stamina != 0:
			movement.runnin = true
			SPEED = 10
			Global.player.stats.stamina = Global.player.stats.stamina - 0.001
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
					if Global.quests[Global.quest[0]].segments[Global.quest[1]].has("complete"):
						get_node("/root/World/map/"+Global.quests[Global.quest[0]].map).init_animation(interaction.item.name)
				elif interaction.type == "hide":
					get_node("/root/World/map/"+Global.quests[Global.quest[0]].map).init_animation(interaction.item.name)
				get_node(self.get_meta("quest")).check_quest(interaction.item)
			else:
				%gui/gui_anim.play("cant_interact")
	if Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_right") or Input.is_action_pressed("ui_up") or Input.is_action_pressed("ui_down"):
		if not movement.runnin:
			$movement.play("walkin")
		else:
			$movement.play("runnin")
	if Input.is_action_just_released("ui_left") or Input.is_action_just_released("ui_right") or Input.is_action_just_released("ui_up") or Input.is_action_just_released("ui_down"):
		$movement.stop()
		$collision/neck/head/player_camera.position = Vector3(0,0.7,0)
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	move_and_slide()

func handle_stats():
	if Global.player.stats.health == 0:
		die()

func die():
		Global.player.stats.health = 0
		Global.player.can_move = false
		movement.can_aim = false
		%death_info.text = "Patient:\n"+Global.player.name+"\nDeath:\nAcidental\nTime of death:\n2/2/2003 "+Time.get_time_string_from_system()
		%ui/transition.play("death")
		Global.debug_log("Game: Player Has Died")
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		#await InputEventKey
		#Global.load_checkpoint(Global.checkpoint)
		#if not Global.efficiency_mode:
		#	get_tree().change_scene_to_file("res://src/world.tscn")
		#else:
		#	get_tree().change_scene_to_file("res://src/mobile_world_all.tscn")

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
	%ui/gui/bars.hide()
	%interact_text.text = ""

func _input(event):
	if Global.player.can_move and not Global.paused:
		if event is InputEventMouseMotion:
			var left_ui_right = deg_to_rad(event.relative.x * Global.mouse_sensitivity)
			var up_down = deg_to_rad(event.relative.y * Global.mouse_sensitivity)
		
			$collision/neck/head.rotate_x(-up_down)
			#neck.rotate_z(left_ui_right)
		
			#if neck.rotation.z <= deg2rad(-75) or neck.rotation.z >= deg2rad(75):
			self.rotate_y(-left_ui_right)
		
			$collision/neck/head.rotation.x = clamp($collision/neck/head.rotation.x, deg_to_rad(-90), deg_to_rad(90))
			$collision/neck.rotation.z = clamp($collision/neck.rotation.z, deg_to_rad(-75), deg_to_rad(75))
		elif event is InputEventJoypadMotion:
			@warning_ignore("int_as_enum_without_cast")
			var left_ui_right = deg_to_rad(Input.get_joy_axis(0, 2) * Global.mouse_sensitivity)
			@warning_ignore("int_as_enum_without_cast")
			var up_down = deg_to_rad(Input.get_joy_axis(0, 3) * Global.mouse_sensitivity)
		
			$collision/neck/head.rotate_x(-up_down)
			#neck.rotate_z(left_ui_right)
		
			#if neck.rotation.z <= deg2rad(-75) or neck.rotation.z >= deg2rad(75):
			self.rotate_y(-left_ui_right)
		
			$collision/neck/head.rotation.x = clamp($collision/neck/head.rotation.x, deg_to_rad(-75), deg_to_rad(75))
			$collision/neck.rotation.z = clamp($collision/neck.rotation.z, deg_to_rad(-75), deg_to_rad(75))

func update_held():
	var item = "collision/neck/head/items/" + Global.player.held_item.name
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
		Global.player.held_item.obj = item_obj
		for child in item_obj.get_children():
			child.show()
		var gui_anim = get_node(get_meta("gui_anim"))
		if Global.player.held_item.name in Global.guns:
			if og_item != null:
				if str(og_item.get_node("..").name) in Global.lights:
					gui_anim.play_backwards("switch_power_ammo")
				elif str(og_item.get_node("..").name) in Global.guns:
					pass
				else:
					gui_anim.play("open_ammo")
			else:
				gui_anim.play("open_ammo")
		elif Global.player.held_item.name in Global.lights:
			if og_item != null:
				if str(og_item.get_node("..").name) in Global.guns:
					gui_anim.play("switch_power_ammo")
				elif str(og_item.get_node("..").name) in Global.lights:
					pass
				else:
					gui_anim.play("open_power")
			else:
				gui_anim.play("open_power")
	else:
		Global.player.held_item.obj = null

func check_look():
	var main_raycast = get_node("collision/neck/head/main_raycast")
	var alt_raycast = get_node("collision/neck/head/alt_raycast")
	if main_raycast.is_colliding() and main_raycast.get_collider() != null:
		if str(main_raycast.get_collider().name) in Global.int_items:
			%interact_text.text = "E - Interact"
			interaction["item"] = main_raycast.get_collider()
			interaction.is_hovering = true
			interaction.can_interact = true
			interaction.type = "item"
		elif str(main_raycast.get_collider().name) in Global.grab_items:
			%interact_text.text = "E - Pick Up"
			interaction["item"] = main_raycast.get_collider()
			interaction.is_hovering = true
			interaction.can_interact = true
			interaction.type = "item"
		elif main_raycast.get_collider().has_meta("hide") and Global.quests[Global.quest[0]].segments[Global.quest[1]].type == "hide":
			%interact_text.text = "E - Hide"
			interaction["item"] = main_raycast.get_collider()
			interaction.is_hovering = true
			interaction.can_interact = true
			interaction.type = "hide"
			#interaction["floor"] = Global.quests[Global.quest[0]].segments[Global.quest[1]].floor
		last_interaction=interaction
	if alt_raycast.is_colliding() and main_raycast.get_collider() != null:
		if "door" in str(alt_raycast.get_collider().name):
			if "key" in str(Global.doors.lock_status[alt_raycast.get_collider().name]):
				if str(Global.doors.lock_status[alt_raycast.get_collider().name]) in Global.inv:
					%interact_text.text = "E - Unlock"
					interaction["item"] = alt_raycast.get_collider()
					interaction.is_hovering = true
					interaction.can_interact = true
					interaction.type = "door"
				else:
					%interact_text.text = "Requires Key"
					interaction["item"] = null
					interaction.is_hovering = true
					interaction.can_interact = false
					interaction.type = ""
			elif "quest" in str(Global.doors.lock_status[alt_raycast.get_collider().name]):
				if Global.doors.lock_status[alt_raycast.get_collider().name] == "quest"+str(Global.quest[0])+str(Global.quest[1]):
					%interact_text.text = "E - Open"
					interaction["item"] = alt_raycast.get_collider()
					interaction.is_hovering = true
					interaction.can_interact = true
					interaction.type = "door"
					if Global.quests[Global.quest[0]].segments[Global.quest[1]].has("floor"):
						interaction["floor"] = Global.quests[Global.quest[0]].segments[Global.quest[1]].floor
				else:
					%interact_text.text = "The door is locked from the otherside"
					interaction["item"] = null
					interaction.is_hovering = true
					interaction.can_interact = false
					interaction.type = ""
			elif str(Global.doors.lock_status[alt_raycast.get_collider().name]) == "unlocked":
				%interact_text.text = "E - Open"
				interaction["item"] = alt_raycast.get_collider()
				interaction.is_hovering = true
				interaction.can_interact = true
				interaction.type = "door"
			else:
				%interact_text.text = "Locked"
				interaction.is_hovering = true
				interaction.can_interact = false
				interaction.type = ""
			# Unlock All After the if tree so it'll just override everything
			if Global.doors.unlock_all:
				%interact_text.text = "E - Open"
				interaction["item"] = alt_raycast.get_collider()
				interaction.is_hovering = true
				interaction.can_interact = true
				interaction.type = "door"
			last_interaction=interaction
	else:
		%interact_text.text = ""
		interaction["item"] = null
		interaction.is_hovering = false
		interaction.can_interact = false
		interaction.type = ""

func _on_quit_pressed():
	Saves.save_game(Saves.get_global_save())
	get_tree().quit()


func _on_save_pressed():
	Saves.save_game(Saves.get_global_save())


func _on_continue_pressed():
	pass # Replaced by _on_resume_pressed()


func _on_shootin_animation_finished(anim_name):
	#Global.debug_log("PlayerAnimation: Finished "+str(anim_name))
	if anim_name == "shoot" or anim_name == "shoot+aim":
		movement.shooting = false


func _on_resume_pressed():
	if Global.paused:
		%ui/gui/gui_anim.play_backwards("pause")
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		Global.paused=false
		Global.player.can_move=true


func _on_debug_pressed():
	Global.emit_signal("debug")


func _on_gui_anim_animation_finished(_anim_name):
	bars = true

func shot_delay():
	var t = Timer.new()
	t.set_wait_time(0.1)
	t.set_one_shot(true)
	self.add_child(t)
	Global.shooting = true
	t.start()
	await t.timeout
	Global.shooting = false

@warning_ignore("shadowed_global_identifier")
func debug_log(log):
	var fulllog = Array($ui/debuglog.text.split("\n"))
	if not len(fulllog) >= 50:
		$ui/debuglog.text = $ui/debuglog.text + "\n" + log
	else:
		fulllog.remove_at(0)
		$ui/debuglog.text = "\n".join(PackedStringArray(fulllog)) + "\n" + log


func _on_respawn_pressed():
	Global.load_checkpoint(Global.checkpoint)
	get_tree().change_scene_to_file("res://src/world.tscn")


func _on_mainmenu_pressed():
	get_tree().change_scene_to_file("res://start.tscn")


func _on_exit_pressed():
	get_tree().quit()


func _on_button_0_pressed():
	Input.action_press("ui_accept")


func _on_button_1_pressed():
	Input.action_press("interact")
