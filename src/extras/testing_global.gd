extends Node

# Game:
var game_info = {
	"version":{
		"major":0.4,
		"sub":0
	}
}

var verify = {
	"release":"gamejolt",
	"info":{},
	"gamejolt":false
}

var player_info = {
	"name":"Jack Campbell",
	"skin":null,
	"interactable":[],
	"held_item":"N/A",
	"held_item_obj":null,
	"health":100,
	"stamina":100,
	"power":100,
	"ammo":100,
	"ammo_clip":100,
	"paused":false,
	"can_move":true,
	"position":Vector3(-3.276,1.803,-0.348),
	"rotation":Vector3(0,0,0)
}

var testing = {
	"player":{
		"guide":false
	}
}

# Mods:
var mod_env = {
	"enabled":false,
	"env":null
}

# Items:
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

# Signals:
signal save_complete
signal load_complete
signal interact
signal debug
signal update_quest_info
signal update_items

# DANGER:
func set_main():
	print("TestingGlobal: WARNING: Using Testing Global As Main Global Can Break The Game!")
	get_node("/root/Global").call_deferred("queue_free")
	await get_node("/root/Global").tree_exited
	self.name = "Global"
