extends Node3D

# Called when the node enters the scene tree for the first time.
func _ready():
	scandoors()
	Global.call_deferred("emit_signal", "update_quest_info")
	call_deferred("init_quests")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func update_floor():
	var current_rooms = []
	var current_rooms_data = {}
	var req_rooms = Global.CurrentlyRequiredRooms
	for child in get_children():
		if child.name != "labels":
			current_rooms.append(child.name)
			current_rooms_data[child.name] = child
	var old_rooms = current_rooms
	for room in req_rooms:
		print(room)
		if room in current_rooms:
			old_rooms.remove_at(old_rooms.find(room))
		else:
			print("FloorUpdater: Adding room "+room)
			var new_room = load(Global.RoomsData[room].mobile).instantiate()
			add_child(new_room)
			new_room.position = Global.RoomsData[room].pos
	for room in old_rooms:
		print("FloorUpdater: Removing room "+room)
		current_rooms_data[room].queue_free()

func scandoors():
	for child in get_children():
		for c_child in child.get_children():
			if c_child.name == "room_doors":
				for c_c_child in c_child.get_children():
					Global.door_count=Global.door_count+1
					c_c_child.name = "door" + str("%02d" % Global.door_count)
					Global.doors[c_c_child.name] = c_c_child
					if c_c_child.has_meta("status"):
						Global.doors_lock_status[c_c_child.name] = c_c_child.get_meta("status")
					else:
						Global.doors_lock_status[c_c_child.name] = "locked"
			if c_child.name == "room_ex_doors":
				for c_c_child in c_child.get_children():
					Global.door_count=Global.door_count+1
					c_c_child.name = "door" + str("%02d" % Global.door_count)
					Global.doors[c_c_child.name] = c_c_child
					if c_c_child.has_meta("status"):
						Global.doors_lock_status[c_c_child.name] = c_c_child.get_meta("status")
					else:
						Global.doors_lock_status[c_c_child.name] = "locked"
		if child.has_meta("items"):
			for item in child.get_meta("items"):
				if child.get_node_or_null(item) != null:
					Global.item_objs[child.get_node(item).name] = child.get_node(item)

func init_quests():
	for quest in Global.quests:
		Global.CurrentlyRequiredRooms=quest.rooms
		update_floor()
		if quest.map == self.name:
			for subquest in quest.segments:
				if subquest.type == "grab":
					for item in subquest.item_names:
						subquest.item_paths[item] = Global.item_objs[item].get_path()
						subquest.items[item] = Global.item_objs[item]
				elif subquest.type == "door":
					subquest["floor"] = self
					for door in Global.doors_lock_status:
						if Global.doors_lock_status[door] == subquest.door_status:
							subquest.door = Global.doors[door]
							break
				elif subquest.type == "hide":
					subquest["floor"] = self
					if get_node_or_null(subquest.room) != null:
						for spot in get_node(subquest.room).get_meta("spots"):
							subquest["floor"] = self
							subquest.hiding_spots.append(get_node(subquest.room).get_node(spot))
				else:
					print("unrecognized subquest type: " + subquest.type)

func init_animation(anim:String, death=false):
	if anim == "bed0":
		if not death:
			print("init_animation: Starting Nurse Chase (bed0) Animation (Without Death)")
			var cam = load("res://src/extras/cutscene_camera.tscn").instantiate()
			Global.get_player_camera().current = false
			Global.can_move = false
			Global.get_player().hide()
			Global.get_player().refresh_info()
			Global.current_quest().hiding_spots[0].add_child(cam)
			cam.current = true
		else:
			print("init_animation: Starting Nurse Chase (bed0) Animation (With Death)")
		if get_node_or_null(Global.current_quest().room) != null:
			get_node(Global.current_quest().room).get_node("animations/animation_player").animation_finished.connect(self.animation_handler.bind(death))
			get_node(Global.current_quest().room).get_node("animations/animation_player").play("nurse_chase")
	elif anim == "door16":
		print("init_animation: Starting Claire (door16) Animation")
	else:
		print('init_animation: Animation "'+anim+'" Is Not Declared!')

func animation_handler(anim:String, death=false):
	if anim == "nurse_chase":
		if not death:
			if Global.current_quest().hiding_spots[0].get_node_or_null("cam") != null:
				Global.current_quest().hiding_spots[0].get_node_or_null("cam").queue_free()
			else:
				print("init_animation: Failed to delete animation camera")
			Global.get_player_camera().current = true
			Global.can_move = true
			Global.get_player().show()
			Global.get_player().refresh_info()
			Global.current_quest().complete = true
			Global.anims.anim0 = true
		if get_node_or_null(Global.current_quest().room) != null:
			if get_node(Global.current_quest().room).get_node("animations/nurse_chase/nurse") != null:
				get_node(Global.current_quest().room).get_node("animations/nurse_chase/nurse").queue_free()
		print("init_animation: Animation Nurse Chase (bed0) Finished")
		Global.get_player().get_node(Global.get_player().get_meta("quest")).check_quest()
	elif anim == "claire_anim":
		pass
	else:
		print("init_animation: Animation Failed To Close!")
