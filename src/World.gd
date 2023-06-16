extends Node3D

# World Script:
# Allow's Mods to change the player or the first loaded floor easily and anything else that can be changed before the game starts loading things

@onready var floor1 = preload("res://src/floor1.tscn")
@onready var player = preload("res://src/player/player.tscn")

func _ready():
	load_unloaded_mods()
	$map.add_child(floor1.instantiate())
	$spawn.add_child(player.instantiate())

func load_unloaded_mods():
	for mod in Global.mods.unloaded:
		var mod_data = Global.mods.unloaded[mod]
		if true:
			var mod_pck = Global.get_home() + "Mods/" + Global.mods.folders[Global.lower(mod_data.mod)] + "/" + mod_data.pck
			var mod_package = ProjectSettings.load_resource_pack(mod_pck)
			if mod_package:
				if FileAccess.file_exists(mod_data.scene):
					var mod_inst = load(mod_data.scene).instantiate()
					get_node("/root").call_deferred("add_child", mod_inst)
				else:
					print(str('ModLoader: Broken Mod Scenes on "'+mod_data.mod+'"'))
			else:
				print(str('ModLoader: Broken Mod pck on "'+mod_data.mod+'"'))
