extends Node3D

var rooms = {
	"pos":{"story_hall3":Vector3(1.739, 0, -11.116),"story_hall2":Vector3(-14.97,0,-23.991),"story_hall5":Vector3(-41.49,-0.031,-11.201)}
}

func _ready():
	scandoors()
	call_deferred("init_quests")

func scandoors():
	for child in get_children():
		for c_child in child.get_children():
			if c_child.name in ["room_doors", "room_ex_doors"]:
				for c_c_child in c_child.get_children():
					Global.doors.count += 1
					c_c_child.name = "door" + str("%02d" % Global.doors.count)
					Global.doors.obj[c_c_child.name] = c_c_child
					if c_c_child.has_meta("status"):
						Global.doors.lock_status[c_c_child.name] = c_c_child.get_meta("status")
					else:
						Global.doors.lock_status[c_c_child.name] = "locked"
		if child.has_meta("items"):
			for item in child.get_meta("items"):
				var node = child.get_node_or_null(item)
				if node:
					Global.item_objs[node.name] = node

func init_quests():
	for quest in Global.quests:
		if quest.map == self.name:
			for subquest in quest.segments:
				if subquest.type == "grab":
					for item in subquest.item_names:
						var item_obj = Global.item_objs[item]
						subquest.item_paths[item] = item_obj.get_path()
						subquest.items[item] = item_obj
				elif subquest.type == "door":
					subquest.floor = self
					for door in Global.doors.lock_status.keys():
						if Global.doors.lock_status[door] == subquest.door_status:
							subquest.door = Global.doors.obj[door]
							break
				elif subquest.type == "hide":
					subquest.floor = self
					for spot in get_node(subquest.room).get_meta("spots"):
						subquest.floor = self
						subquest.hiding_spots.append(get_node(subquest.room).get_node(spot))
				else:
					Global.debug_log("unrecognized subquest type: " + subquest.type)

func init_animation(anim: String, death=false):
	if anim == "bed0":
		if not death:
			Global.debug_log("init_animation: Starting Nurse Chase (bed0) Animation (Without Death)")
			var cam = load("res://src/extras/cutscene_camera.tscn").instantiate()
			Global.get_player_camera().current = false
			Global.can_move = false
			Global.get_player().hide()
			Global.get_player().refresh_info()
			Global.current_quest().hiding_spots[0].add_child(cam)
			cam.current = true
		else:
			Global.debug_log("init_animation: Starting Nurse Chase (bed0) Animation (With Death)")
		get_node(Global.current_quest().room).get_node("animations/animation_player").animation_finished.connect(animation_handler.bind(death))
		get_node(Global.current_quest().room).get_node("animations/animation_player").play("nurse_chase")
	elif anim == "door16":
		Global.debug_log("init_animation: Starting Claire (door16) Animation")
	else:
		Global.debug_log('init_animation: Animation "' + anim + '" Is Not Declared!')

func animation_handler(anim: String, death=false):
	if anim == "nurse_chase":
		if not death:
			var hiding_spots = Global.current_quest().hiding_spots
			var room = get_node_or_null(Global.current_quest().room)
			if hiding_spots.size() > 0 and hiding_spots[0].has_node("cam"):
				hiding_spots[0].get_node("cam").queue_free()
			else:
				Global.debug_log("init_animation: Failed to delete animation camera")
			Global.get_player_camera().current = true
			Global.can_move = true
			Global.get_player().show()
			Global.get_player().refresh_info()
			Global.current_quest().complete = true
			Global.anims.anim0 = true
			if room != null and room.has_node("animations/nurse_chase/nurse"):
				room.get_node("animations/nurse_chase/nurse").queue_free()
		Global.debug_log("init_animation: Animation Nurse Chase (bed0) Finished")
		Global.get_player().get_node(Global.get_player().get_meta("quest")).check_quest()
	elif anim == "claire_anim":
		pass
	else:
		Global.debug_log("init_animation: Animation Failed To Close!")
