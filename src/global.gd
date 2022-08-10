extends Node

func _ready():
	pass

# Base:
var version = 0.3
var sub_version = 2
var save:Dictionary
var ingame:bool = false
var efficiency_mode:bool = false

# Game:
var difficulty:int = 0
var player_name:String = "Jack Campbell"
var skin:MeshInstance3D = null
var mod_env_override = false
var env

# Generation:
var rooms:Array = ["res://src/rooms/gen/hall0.tscn","res://src/rooms/gen/room0.tscn","res://src/rooms/gen/hall1.tscn"]
var door_count:int = 0
var doors:Dictionary = {}
var doors_lock_status:Dictionary = {}

# Player:
signal interact
var interact_obj:Array = []
var player_held_item:String = "N/A"
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
		"orb":true,
		"type":"hide",
		"room":"hall1",
		"hiding_spots":[]
	}]
}]

# Items:
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

# Menu:
var buttons:Array = ["play", "mods", "exit"] # Whats the point in this?

# Mods:
var mods_folder:String = ""
var int_mods_folder:String = ""
var mods:Array = []
var used_mods:Array = []
var unused_mods:Array = []
var mod_datas:Dictionary = {}
var mod_folders:Dictionary = {}
var player_item_node

# Save:
var saves:Dictionary = {}
var saves_folder:String = ""

var modded_save = false

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
		"efficiency_mode":efficiency_mode,
		"player_name":player_name,
		"skin":skin,
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

signal load_complete
func load_save(insave):
	for i in insave:
		if i != "x" or i != "y" or i != "z" or i != "rx" or i != "ry" or i != "rz":
			self.set(i, insave[i])
		elif i == "x":
			pos.x
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
	var file = File.new()
	var save_file = saves_folder + "/" + lower(save.player_name) + ".save"
	file.open(save_file, File.WRITE)
	file.store_string(str(save))
	self.call_deferred("emit_signal", "save_complete")

#UngodlyLongDictonarys

var achivents = {
	# Chapter 1
	"so_it_begins":false, # After escaping room
	"escape_nurse":false, # After hiding under bed
	"well_shit":false, # After Claires Cutsene
	"muffin_for_your_troubles":false, # death by muffin man
	"the_stairs":false, # After esaping muffin man
	# Others
	"nurse_murderer":false, 
	"banana":false,
	"oh_hello_there":false,
	"just_gotta_smile":false,
	"the_eye":false,
	"vent_inspector":false, # VENT INSPECTAAAAAAAAAAAAAARRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRR
	"meet_the_devil":false
}

var anims = {
	"anim0":false
}

# Lazy Commands:

func lower(string:String):
	string=string.to_lower().replace(":", "").replace("/", "").replace("-", "").replace("+", "").replace("=", "").replace("$", "").replace("%", "").replace("^", "").replace("&", "").replace("*", "").replace("(", "").replace(")", "").replace("~", "").replace("`", "").replace("?", "").replace("!", "").replace("@", "").replace("#", "").replace(">", "").replace("<", "").replace(",", "").replace(".", "").replace(";", "").replace(":", "").replace(" ", "_")
	return string

# Extras:

var story_script = "https://docs.google.com/document/d/1zfnBpAsTVQWNBl88SlSjXF9jTU_cpu-_s6pEArXSDHY/edit?usp=sharing"
