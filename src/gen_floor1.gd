extends Node3D

@export var room_count:int = 1000
var og_room_count = room_count

var player = load("res://src/player/player.tscn").instantiate()

# Called when the node enters the scene tree for the first time.
func _ready():
	generate_world()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func generate_world():
	for i in Global.rooms:
		var room = load(i).instantiate()
		room = null
	while room_count != 0:
		var rng = RandomNumberGenerator.new()
		rng.randomize()
		var rn = rng.randf_range(0, Global.rooms.size())
		var room = load(Global.rooms[rn]).instantiate()
		var room_name = room.name
		var room_size = room.get_meta("room_size")
		var doors_pos = room.get_meta("doors_pos")
		var doors_rotation = room.get_meta("doors_rotation")
		var door_count = doors_pos.size()-1
		while door_count != -1:
			var door = load("res://src/rooms/door.tscn").instantiate()
			door.position = doors_pos[door_count]
			door.rotation = doors_rotation[door_count]
			room.add_child(door)
			door_count=door_count-1
		room.set_meta("room_number", room_count)
		if room.get_meta("room_number") == og_room_count:
			#print(room.get_meta("start_pos"))
			player.position = room.get_meta("start_pos")
			room.add_child(player)
		else:
			var child_pos = []
			for x in self.get_children():
				if x.get_class() == "Node3D":
					child_pos.append(x.position)
			var nrf = true
			while nrf:
				rng.randomize()
				var rcn = rng.randf_range(0, self.get_child_count())
				var children = self.get_children()
				var child = children[rcn]
				#print(child.get_class())
				if child.get_class() == "Node3D":
					rng.randomize()
					var rrd = floor(rng.randf_range(0, 3))
					#print(rrd)
					if rrd == 0:
						room.position.x = child.position.x + room.get_node("room/area").get_shape().size.x
						room.position.z = child.position.z + room.get_node("room/area").get_shape().size.z
					elif rrd == 1:
						room.position.x = child.position.x - room.get_node("room/area").get_shape().size.x
						room.position.z = child.position.z + room.get_node("room/area").get_shape().size.z
					elif rrd == 2:
						room.position.x = child.position.x + room.get_node("room/area").get_shape().size.x
						room.position.z = child.position.z - room.get_node("room/area").get_shape().size.z
					elif rrd == 3:
						room.position.x = child.position.x - room.get_node("room/area").get_shape().size.x
						room.position.z = child.position.z - room.get_node("room/area").get_shape().size.z
					nrf=false
		room.get_node("room").area_entered.connect(self.room_collide)
		#print(room_name)
		#print(room_size)
		#print(doors_pos)
		#print(doors_rotation)
		self.add_child(room)
		print("Room #" + str(og_room_count-room_count) + " Generated")
		room_count=room_count-1

func room_collide(area):
	print("Room Collison Detected - Correcting")
	var room = area.get_node("..")
	var rng = RandomNumberGenerator.new()
	var nrf = true
	while nrf:
		rng.randomize()
		var rcn = rng.randf_range(0, self.get_child_count())
		var children = self.get_children()
		var child = children[rcn]
		#print(child.get_class())
		if child.get_class() == "Node3D" and child != room:
			rng.randomize()
			var rrd = floor(rng.randf_range(0, 3))
			#print(rrd)
			if rrd == 0:
				room.position.x = child.position.x + room.get_node("room/area").get_shape().size.x
				room.position.z = child.position.z + room.get_node("room/area").get_shape().size.z
			elif rrd == 1:
				room.position.x = child.position.x - room.get_node("room/area").get_shape().size.x
				room.position.z = child.position.z + room.get_node("room/area").get_shape().size.z
			elif rrd == 2:
				room.position.x = child.position.x + room.get_node("room/area").get_shape().size.x
				room.position.z = child.position.z - room.get_node("room/area").get_shape().size.z
			elif rrd == 3:
				room.position.x = child.position.x - room.get_node("room/area").get_shape().size.x
				room.position.z = child.position.z - room.get_node("room/area").get_shape().size.z
			nrf=false

func test_generate():
	for i in Global.rooms:
		var room = load(i).instantiate()
		room = null
	while room_count != 0:
		var rng = RandomNumberGenerator.new()
		rng.randomize()
		var rn = rng.randf_range(0, Global.rooms.size())
		var room = load(Global.rooms[rn]).instantiate()
		var room_name = room.name
		var room_size = room.get_meta("room_size")
		var doors_pos = room.get_meta("doors_pos")
		var doors_rotation = room.get_meta("doors_rotation")
		var door_count = doors_pos.size()-1
		var og_door_count = door_count
		rng.randomize()
		var rdu = floor(rng.randf_range(0, og_door_count-1))
		var the_chosen_door:StaticBody3D
		while door_count != -1:
			var door = load("res://src/rooms/door.tscn").instantiate()
			door.position = doors_pos[door_count]
			door.rotation = doors_rotation[door_count]
			room.add_child(door)
			var door_globals:Array = []
			door_globals.append(door.global_position)#.get_position())
			room.set_meta("door_gobal_pos", door_globals)
			door_count=door_count-1
			#print(door_count)
			#print(door_globals)
			if rdu == door_count-1:
				the_chosen_door=door
		room.set_meta("room_number", room_count)
		if room.get_meta("room_number") == og_room_count:
			print(room.get_meta("start_pos"))
			player.position = room.get_meta("start_pos")
			room.add_child(player)
		else:
			var children = []
			for x in self.get_children():
				if x.get_class() == "Node3D":
					children.append(x)
			var nrf = true
			while nrf:
				rng.randomize()
				var rrd = floor(rng.randf_range(0, children.size()))
				rng.randomize()
				var child = children[rrd]
				var doors = []
				for r in room.get_children():
					if r.get_class() == "StaticBody3D":
						doors.append(r)
				var rcd = floor(rng.randf_range(0, doors.size()))
				room.global_position.x = doors[rcd].position.x 
				room.global_position.z = doors[rcd].position.z
				room.global_position.y = doors[rcd].position.y + 2.563
				nrf = false
		print(room_name)
		print(room_size)
		print(doors_pos)
		print(doors_rotation)
		self.add_child(room)
		room_count=room_count-1
