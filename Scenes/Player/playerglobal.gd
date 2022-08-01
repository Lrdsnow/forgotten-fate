extends Node

#player
var stamina = 100
var max_stamina = 100
var health = 100
var max_health = 100
var ammo = 0
var pos_x = 0
var pos_y = 0
var pos_z = 0
var iammo = false
var istam = false
var ihealth = false
var dend = false

#room1
var room2 = false

#room3
var ad = false
var idk = true

#discord
var chapter = "Main Menu"
var room = ""
var discord_image = "chapter-2"


var difficulty = 0
# 0 for easy 1 for medium 2 for hard and 3 for hardest (Also -1 for detroit)
var objects = [0, 0, 0, 0]
var inv = []
var mods = []
var modss = []
var achivements = {
	"smileychecker":false,
	"yourtruefate":false,
	"nursekiller":false,
	"grasstoucher":false
}

var loaded_rooms = []

var active = false

func _ready():
	self.add_to_group("Persist")
	update_activity()

func update_activity() -> void:
	var activity = Discord.Activity.new()
	activity.set_type(Discord.ActivityType.Playing)
	var detail = chapter + " (" + room + ")"
	var state = "Playing Solo"
	if chapter == "Main Menu":
		detail = chapter
		state = ""
	#else:
	#	if difficulty == 0:
	#		pass
	activity.set_state(state)
	activity.set_details(detail)

	var assets = activity.get_assets()
	assets.set_large_image(discord_image)
	assets.set_large_text(chapter)
	
	#var timestamps = activity.get_timestamps()
	#timestamps.set_start(OS.get_unix_time() + 100)
	#timestamps.set_end(OS.get_unix_time() + 500)

	var result = yield(Discord.activity_manager.update_activity(activity), "result").result
	if result != Discord.Result.Ok:
		push_error(str(result))

func save():
	if active:
		var loaded_rooms_ch = get_node("/root/World/Terrains/hospitalfloor1").get_children()
		var n = 0
		while true:
			if not n == loaded_rooms_ch.size():
				if "room" in loaded_rooms_ch[n].name:
					loaded_rooms.append(loaded_rooms_ch[n].name)
				n=n+1
			else:
				break
		var save_dict = {
			#player & global
			"pos_x" : get_node("/root/World/Player").translation.x, # Vector2 is not supported by JSON
			"pos_y" : get_node("/root/World/Player").translation.y,
			"pos_z" : get_node("/root/World/Player").translation.z,
			"achivements" : achivements,
			"inv" : inv,
			"objects" : objects,
			"loaded_rooms" : loaded_rooms,
			"max_health" : max_health,
			"health" : health,
			"max_stamina" : max_stamina,
			"stamina" : stamina,
			#room1
			"room2":room2,
			#room3
			"ad" : ad,
			"idk" : idk
		}
		print(save_dict)
		return save_dict

func save_game():
	var save_game = File.new()
	save_game.open("user://user.save", File.WRITE)
	var save_nodes = get_tree().get_nodes_in_group("Persist")
	for node in save_nodes:
		var node_data = node.call("save")
		save_game.store_line(to_json(node_data))
	save_game.close()

func load_game():
	var save_game = File.new()
	if not save_game.file_exists("user://user.save"):
		return
	save_game.open("user://user.save", File.READ)
	while save_game.get_position() < save_game.get_len():
		var node_data = parse_json(save_game.get_line())
		for i in node_data.keys():
			self.set(i, node_data[i])

	save_game.close()

func continue_game():
	var world = load("res://Scenes/World.tscn").instance()
	get_node("/root/menu").queue_free()
	get_node("/root").add_child(world)
	if "room1" in loaded_rooms:
		pass
	else:
		get_node("/root/World/Terrains/hospitalfloor1/room1").queue_free()
		if "room2" in loaded_rooms:
			pass
		else:
			get_node("/root/World/Terrains/hospitalfloor1/room2").queue_free()
			if ! "room3" in loaded_rooms:
				get_node("/root/World/Terrains/hospitalfloor1/room3").queue_free()
	var cc = 0
	while true:
		if cc != loaded_rooms.size():
			if loaded_rooms[cc] != "room1" and loaded_rooms[cc] != "room2" and loaded_rooms[cc] != "room3":
				var room = "res://Scenes/hospitalfloor1rooms/" + loaded_rooms[cc] + ".tscn"
				var room_inst = load(room).instance()
				get_node("/root/World/Terrains/hospitalfloor1").add_child(room_inst)
			cc = cc+1
		else:
			break
	get_node("/root/World/Player").translation.x = pos_x
	get_node("/root/World/Player").translation.y = pos_y
	get_node("/root/World/Player").translation.z = pos_z
	if room2 == true:
		get_node("/root/World/Terrains/hospitalfloor1/room2")._on_room2()

func reload():
	var cc = 0
	while true:
		if cc != loaded_rooms.size():
			if loaded_rooms[cc] != "room1" and loaded_rooms[cc] != "room2" and loaded_rooms[cc] != "room3":
				var room = "res://Scenes/hospitalfloor1rooms/" + loaded_rooms[cc] + ".tscn"
				var room_load = load(room)
				var room_inst = room_load.instance()
				get_node("/root/World/Terrains/hospitalfloor1").add_child(room_inst)
			cc = cc+1
		else:
			break
