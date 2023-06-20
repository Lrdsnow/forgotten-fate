extends Node
#Main:
var version = 0.4
#Graphics:
signal update_graphics
var efficiency_mode = false
var overlays = true
#Patches:
func _ready():
	debugstart.connect(debug_setup)
#Debug:
signal debuglog
signal debugstart
var debug_mode = false
var speedrunner = true
func debug_log(logg):
	if get_node_or_null("/root/World") != null:
		debuglog.emit(logg)
	print(logg)
func debug_setup():
	debug_mode = true
	if get_node_or_null("/root/debug") == null:
		var debug_scene = load("res://src/extras/debug/debug.tscn").instantiate()
		get_node("/root").add_child.call_deferred(debug_scene)
#Files:
var sensitive_filesystem = false
var home = ""
var saves = {}
func get_home():
	if home != "":
		return home
	home = "user://" if sensitive_filesystem else find_documents_dir() + "/My Games/ForgottenFate"
	create_recursive_dirs(["My Games/ForgottenFate/Saves", "My Games/ForgottenFate/Mods"])
	return home
func find_documents_dir():
	var dfn = 0
	while true:
		var system_dir = OS.get_system_dir(dfn)
		if "Documents" in system_dir:
			return system_dir
		dfn += 1
func create_recursive_dirs(paths:Array):
	var dir = DirAccess.open(find_documents_dir())
	for path in paths:
		var dirs = path.split("/")
		var current_path = ""
		for dir_name in dirs:
			current_path += dir_name + "/"
			if !dir.dir_exists(current_path):
				dir.make_dir(current_path)
#Mods:
var mods = {"all":[],"used":[],"unused":[],"loaded":{}, "unloaded":{},"autoload":[],"data":{},"folders":{}}
#Quests:
var quest = [0,0]
var quests = [{
	"name":"Esacape the room",
	"map":"floor1",
	"segments":[{
		"name":"Grab The Key",
		"color":"white",
		"type":"grab",
		"item_names":["key0"],
		"item_paths":{},
		"items":{}
	}, {
		"name":"Open The Door",
		"color":"white",
		"trophy":"so_it_begins",
		"type":"door",
		"door_status":"key0",
		"door":null
	}]
}, {
	"name":"Hide",
	"map":"floor1",
	#"rooms":["room1", "hall4"],
	"segments":[{
		"name":"Hide",
		"color":"red",
		"type":"hide",
		"complete":false,
		"door_status":"anim0",
		"door":null
	}]
}, {
	"name":"Continue",
	"map":"floor1",
	#"rooms":["room1", "hall5"],
	"segments":[{
		"name":"Continue Through The Hall",
		"color":"white",
		"type":"other",
		"complete":false,
		"door_status":"anim1",
		"door":null
	}]
}, {
	"name":"Run",
	"map":"floor1",
	#"rooms":["room1", "hall5"],
	"segments":[{
		"name":"Get Away from the shadow figure",
		"color":"red",
		"type":"other",
		"complete":false,
		"door_status":"anim2",
		"door":null
	}]
},{
	"name":"Continue",
	"map":"floor1",
	#"rooms":["room1", "hall5"],
	"segments":[{
		"name":"Continue down the stairs",
		"color":"white",
		"type":"other",
		"complete":false,
		"door_status":"",
		"door":null
	}]
}, {
	"name":"Escape",
	"map":"floor1",
	#"rooms":["room1", "hall4"],
	"segments":[{
		"name":"Make your way through the hospital",
		"color":"white",
		"anim":"anim1",
		"type":"door",
		"door_status":"anim0",
		"door":null
	}]
}]
#Functions that only exist because im lazy:
func lower(string:String): string=string.to_lower().replace(":", "").replace("/", "").replace("-", "").replace("+", "").replace("=", "").replace("$", "").replace("%", "").replace("^", "").replace("&", "").replace("*", "").replace("(", "").replace(")", "").replace("~", "").replace("`", "").replace("?", "").replace("!", "").replace("@", "").replace("#", "").replace(">", "").replace("<", "").replace(",", "").replace(".", "").replace(";", "").replace(":", "").replace(" ", "_"); return string
func get_quest_name(input): var quest_name = [Global.quests[input[0]]["name"],Global.quests[input[0]].segments[input[1]]["name"]]; return quest_name
# Items:
# Please note that all Guns are like unused so yeah
signal update_item
var all_items:Array = ["AK", "basic_flashlight", "N/A"] # Debug
var guns:Array = ["AK"]
var lights:Array = ["basic_flashlight"]
var quest_items:Array = []
var misc_items:Array = []
func update_items():
	emit_signal("update_item")
var guns_max_ammo:Dictionary = {"AK":32}
var int_items = []
var grab_items = ["key0"]
var inv = []
var item_objs = {}
var shooting = false # Whyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy
var items = {"AK":{"type":"debug_gun","reload":0,"max_ammo":32},"basic_flashlight":{"type":"placeholder"},"N/A":{"type":"N/A"}}
# Player:
signal interact
signal instakill
var paused:bool = false
var difficulty = 1
var player = {
	"name":"Jack Campbell",
	"interact_obj":[],
	"held_item":{
		"name":"N/A",
		"obj":null},
	"stats":{
		"health":100,
		"stamina":100,
		"power":100,
		"ammo_clip":0, #Unused TwT
		"max_ammo":32, #Also Left Unused TwT
		"ammo":0 # TwT
	},
	"can_move":true
}
# Settings:
var mouse_sensitivity:int = 1
var joystick_sensitivity:int = 1
#Others:
signal load_complete #idek why this exists
# Doors:
var doors = {
	"count":0,
	"obj":{},
	"lock_status":{},
	"unlock_all":true
}
