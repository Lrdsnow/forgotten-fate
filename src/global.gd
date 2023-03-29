extends Node

func _ready():
	get_tree().set_auto_accept_quit(false)
	debugstart.connect(debug_setup)
	emit_signal("debugstart")
	#TGlobal.set_main()

# Base:
var version = 0.3
var sub_version = 6
var save:Dictionary
var checkpoint:Dictionary
var ingame:bool = false
var efficiency_mode:bool = false
var overlays:bool = true
var itch_info
var trifate_info
var release = "itch"
var skip_checks = false
var cinematic_mode = false
var home = ""

# Game:
var difficulty:int = 0
var player_name:String = "Jack Campbell"
var mod_env_override = false
var env

# Generation:
var rooms:Array = ["res://src/rooms/gen/hall0.tscn","res://src/rooms/gen/room0.tscn","res://src/rooms/gen/hall1.tscn"]
var door_count:int = 0
var doors:Dictionary = {}
var doors_lock_status:Dictionary = {}

# Player:
signal interact
signal debuglog
var interact_obj:Array = []
var player_held_item:String = "N/A"
var player_held_item_obj = null
var power:int = 100
var health:int = 100
var stamina:int = 100
var ammo_clip:int = 0
var max_ammo:int = 32
var ammo:int = 0
var paused:bool = false
var can_move:bool = true
var guide:bool = false
var pos = Vector3(-3.276,1.803,-0.348)
var rot = Vector3(0,0,0)


# Settings:
var mouse_sensitivity:int = 1
var joystick_sensitivity:int = 1

# Debug:
signal debug
signal debugstart
signal update_graphics
var debug_mode = false
var debug_ext = false
var debug_ui = false

func debug_setup():
	debug_mode = true
	var debug_scene = load("res://src/extras/debug/debug.tscn").instantiate()
	get_node("/root").add_child.call_deferred(debug_scene)

func logger(logg):
	debuglog.emit(logg)

# Quests:
signal update_quest_info
var quest = [0,0]
var quests = [{
	"name":"Esacape the room",
	"map":"floor1",
	"segments":[{
		"name":"Grab The Key",
		"color":"white",
		"orb":false,
		"type":"grab",
		"item_names":["key0"],
		"item_paths":{},
		"items":{}
	}, {
		"name":"Open The Door",
		"color":"white",
		"orb":false,
		"trophy":"so_it_begins",
		"type":"door",
		"door_status":"key0",
		"door":null
	}]
}, {
	"name":"HIDE",
	"map":"floor1",
	"segments":[{
		"name":"HIDE",
		"color":"red",
		"orb":false,
		"anim":"bed0",
		"type":"hide",
		"complete":false,
		"room":"hall1",
		"hiding_spots":[]
	}]
},{
	"name":"Escape",
	"map":"floor1",
	"segments":[{
		"name":"Continue Through the door",
		"color":"white",
		"orb":false,
		"anim":"anim1",
		"type":"door",
		"door_status":"anim0",
		"door":null
	}]
}]

# Item Variables:

signal update_item
var all_items:Array = ["AK", "45", "basic_flashlight", "N/A"] # Debug
var guns:Array = ["AK", "45"]
var lights:Array = ["basic_flashlight"]
var quest_items:Array = []
var misc_items:Array = []
func update_items():
	emit_signal("update_item")
var guns_max_ammo:Dictionary = {
	"AK":32,
	"45":16
}
var int_items = []
var grab_items = ["key0"]
var inv = []
var item_objs = {}

var shooting = false

var items = {
	"AK":{
		"type":"debug_gun",
		"reload":0,
		"max_ammo":32
	},
	"45":{
		"type":"placeholder",
		"reload":0,
		"max_ammo":16
	},
	"basic_flashlight":{
		"type":"placeholder"
	},
	"N/A":{
		"type":"N/A"
	}
}

# Mods:
var mods_folder:String = ""
var int_mods_folder:String = ""
var mods:Array = []
var used_mods:Array = [] # This Is Broken?
var unused_mods:Array = [] # This one too
var mod_datas:Dictionary = {}
var mod_folders:Dictionary = {}
var player_item_node
var loaded_mods:Dictionary = {}
var unloaded_mods:Dictionary = {}


# Save:
var saves:Dictionary = {}
var saves_folder:String = ""

var modded_save = false

func save_checkpoint():
	checkpoint={
		"save_version":version,
		"x":get_node("/root/World/Player").position.x,
		"y":get_node("/root/World/Player").position.y,
		"z":get_node("/root/World/Player").position.z,
		"rx":get_node("/root/World/Player").rotation.x,
		"ry":get_node("/root/World/Player").rotation.y,
		"rz":get_node("/root/World/Player").rotation.z,
		"difficulty":difficulty,
		"player_name":player_name,
		"interact_obj":interact_obj,
		"player_held_item":player_held_item,
		"power":power,
		"can_move":can_move,
		"health":health,
		"stamina":stamina,
		"ammo_clip":ammo_clip,
		"ammo":ammo,
		"mouse_sensitivity":mouse_sensitivity,
		"joystick_sensitivity":joystick_sensitivity,
		#"grab_items":grab_items,
		#"inv":inv,
		#"quest":quest
	}
	#if modded_save:
	#	save=save.merge(Game.modded_save)
	return checkpoint

func resave():
	save={
		"save_version":version,
		"x":pos.x,
		"y":pos.y,
		"z":pos.z,
		"rx":rot.x,
		"ry":rot.y,
		"rz":rot.z,
		"difficulty":difficulty,
		"player_name":player_name,
		"interact_obj":interact_obj,
		"player_held_item":player_held_item,
		"power":power,
		"health":health,
		"stamina":stamina,
		"ammo_clip":ammo_clip,
		"ammo":ammo,
		"mouse_sensitivity":mouse_sensitivity,
		"joystick_sensitivity":joystick_sensitivity,
		"grab_items":grab_items,
		"inv":inv,
		"quest":quest
	}
	#if modded_save:
	#	save=save.merge(Game.modded_save)
	return save

func load_checkpoint(incheckpoint):
	for i in incheckpoint:
		if i != "x" or i != "y" or i != "z" or i != "rx" or i != "ry" or i != "rz":
			self.set(i, incheckpoint[i])
		elif i == "x":
			get_node("/root/World/Player").position.x = i
		elif i == "y":
			get_node("/root/World/Player").position.y = i
		elif i == "z":
			get_node("/root/World/Player").position.z = i
		elif i == "rx":
			get_node("/root/World/Player").rotation.x = i
		elif i == "ry":
			get_node("/root/World/Player").rotation.y = i
		elif i == "rz":
			get_node("/root/World/Player").rotation.z = i

signal load_complete
func load_save(insave):
	for i in insave:
		if i != "x" or i != "y" or i != "z" or i != "rx" or i != "ry" or i != "rz":
			self.set(i, insave[i])
		elif i == "x":
			pos.x = i
		elif i == "y":
			pos.y = i
		elif i == "z":
			pos.z = i
		elif i == "rx":
			rot.x = i
		elif i == "ry":
			rot.y = i
		elif i == "rz":
			rot.z = i
	self.call_deferred("emit_signal", "load_complete")

signal save_complete
func save_game():
	save = resave()
	var save_file = saves_folder + "/" + lower(save.player_name) + ".save"
	var file = FileAccess.open(save_file, FileAccess.WRITE)
	file.store_string(str(save))
	self.call_deferred("emit_signal", "save_complete")

#UngodlyLongDictonarys

var trophys = {
	# Chapter 1
	"so_it_begins":false, # After escaping room
	"escape_nurse":false, # After hiding under bed
	"well_shit":false, # After Claires Cutsene
	"muffin_for_your_troubles":false, # death by muffin man
	"the_stairs":false, # After esaping muffin man
	# Others
	"nurse_murderer":false, # Murder the nurse
	"banana":false, # Praise The Banana
	"oh_hello_there":false, # OH HELLO THERE MATE
	"just_gotta_smile":false, # Smile!
	"the_eye":false, # *shivers*
	"vent_inspector":false, # VENT INSPECTAAAAAAAAAAAAAARRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRR
	"meet_the_devil":false # The devil cant be that bad to deal with!
}

var anims = {
	"anim0":false,
	"anim1":false
}

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		get_tree().quit()

# Lazy Commands:

func lower(string:String):
	string=string.to_lower().replace(":", "").replace("/", "").replace("-", "").replace("+", "").replace("=", "").replace("$", "").replace("%", "").replace("^", "").replace("&", "").replace("*", "").replace("(", "").replace(")", "").replace("~", "").replace("`", "").replace("?", "").replace("!", "").replace("@", "").replace("#", "").replace(">", "").replace("<", "").replace(",", "").replace(".", "").replace(";", "").replace(":", "").replace(" ", "_")
	return string

func endgame():
	pass

func quit_game(why=""):
	if why == "quest":
		if ! debug_mode:
			get_tree().quit()
	else:
		get_tree().quit()

func current_quest() -> Dictionary:
	var subquest = {}
	subquest = Global.quests[Global.quest[0]].segments[Global.quest[1]]
	return subquest

# Extras:

var story_script = "https://docs.google.com/document/d/1zfnBpAsTVQWNBl88SlSjXF9jTU_cpu-_s6pEArXSDHY/edit?usp=sharing"

func get_floor() -> Node3D:
	var floor = get_node("/root/World/map").get_children()[0]
	return floor

func get_player_camera() -> Camera3D:
	return get_node_or_null("/root/World/Player/collision/neck/head/player_camera")

func get_player() -> CharacterBody3D:
	return get_node_or_null("/root/World/Player")

func GameChecker():
	if skip_checks:
		print("GameChecker: Ownership Checks Skipped")
	elif release == "trifate-studios":
		# Checks For Mod Launcher Install Files
		var info = OS.get_executable_path().get_base_dir() + "/.trifate-studios/receipt.json"
		if FileAccess.file_exists(info):
			var file = FileAccess.open(info, FileAccess.READ)
			info = file.get_as_text()
			var json = JSON.new()
			json.parse(info)
			info = json.get_data()
			trifate_info = info
			var info_string = "Game Info:\nName: "+trifate_info.Game+"\nID: "+trifate_info.ID+"\n\nUser Info:\nDisplayName: "+trifate_info["user"].DisplayName+"\nID: "+trifate_info["user"].ID+"\n"
			#print(info_string)
			print("GameChecker: Game Validated, "+trifate_info["user"].DisplayName+' (Trifate Studios)')
	#elif release == "steam":
		# Checks For Steam Install Files
	#	print("GameChecker: Failed To Validate Game! (Steam Verification Selected)")
	else:
		# Checks For Itch App Install Files
		var info = OS.get_executable_path().get_base_dir() + "/.itch/receipt.json.gz"
		if FileAccess.file_exists(info):
			OS.execute("gzip", ["-dk", info])
			info = OS.get_executable_path().get_base_dir() + "/.itch/receipt.json"
			if FileAccess.file_exists(info):
				var file = FileAccess.open(info, FileAccess.READ)
				info = file.get_as_text()
				var json = JSON.new()
				json.parse(info)
				info = json.get_data()
				itch_info = info
				var info_string = "Game Info:\nGame ID: "+str(itch_info["game"].id)+"\nName: "+itch_info["game"].title+"\nDesc: "+itch_info["game"].shortText+"\nInstalled Version: "+itch_info["build"].userVersion+"\n\nUser Info:\nDisplayName: "+itch_info["game"].user.displayName+"\nUser ID: "+str(itch_info["game"].user.id)+"\nDeveloper?: "+str(itch_info["game"].user.developer)+"\n"
				#print(info_string)
				print("GameChecker: Game Validated, "+itch_info["game"].user.displayName+' ('+str(itch_info["game"].user.id)+')')
			else:
				print("GameChecker: Failed To Validate Game! (Error Reading File)")
		else:
			print("GameChecker: Failed To Validate Game! (Error Getting File)")

# Files:

func get_home():
	if home == "":
		var docs = ""
		var dfn = 0
		var dfnd = true
		while dfnd:
			if "Documents" in OS.get_system_dir(dfn):
				docs = OS.get_system_dir(dfn)
				dfnd = false
			else:
				dfn = dfn + 1
		var dir = DirAccess.open(docs)
		while ! dir.dir_exists("My Games/ForgottenFate/Saves"):
			if dir.dir_exists("My Games"):
				if dir.dir_exists("My Games/ForgottenFate"):
					if dir.dir_exists("My Games/ForgottenFate/Saves"):
						pass
					else:
						dir.make_dir("My Games/ForgottenFate/Saves")
					if dir.dir_exists("My Games/ForgottenFate/Mods"):
						pass
					else:
						dir.make_dir("My Games/ForgottenFate/Mods")
				else:
					dir.make_dir("My Games/ForgottenFate")
			else:
				dir.make_dir("My Games")
		home = docs + "/My Games/ForgottenFate"
	return home
