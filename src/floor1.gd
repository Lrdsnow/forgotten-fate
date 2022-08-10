extends Node3D

# Called when the node enters the scene tree for the first time.
func _ready():
	scandoors()
	Global.call_deferred("emit_signal", "update_quest_info")
	call_deferred("init_quests")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

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
		if quest.map == self.name:
			for subquest in quest.segments:
				if subquest.type == "grab":
					for item in subquest.item_names:
						subquest.item_paths[item] = Global.item_objs[item].get_path()
						subquest.items[item] = Global.item_objs[item]
				elif subquest.type == "door":
					for door in Global.doors_lock_status:
						if Global.doors_lock_status[door] == subquest.door_status:
							subquest.door = Global.doors[door]
							break
				elif subquest.type == "hide":
					for spot in get_node(subquest.room).get_meta("spots"):
						subquest.hiding_spots.append(spot)
				else:
					print("unrecognized subquest type: " + subquest.type)
