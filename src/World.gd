extends Node3D

func _ready():
	load_unloaded_mods()
	if not Global.mod_env_override:
		Global.env = $WorldEnvironment.environment

func load_unloaded_mods():
	for mod in Global.unloaded_mods:
		var mod_data = Global.unloaded_mods[mod]
		if true:
			var file = File.new()
			var mod_pck = Global.mods_folder + "/" + Global.mod_folders[Global.lower(mod_data.mod)] + "/" + mod_data.pck
			if ! file.file_exists(mod_pck):
				mod_pck = Global.int_mods_folder + "/" + Global.mod_folders[Global.lower(mod_data.mod)] + "/" + mod_data.pck # Quick Fix
			var mod_package = ProjectSettings.load_resource_pack(mod_pck)
			if mod_package:
				if file.file_exists(mod_data.scene):
					var mod_inst = load(mod_data.scene).instantiate()
					get_node("/root").call_deferred("add_child", mod_inst)
				else:
					print(str('ModLoader: Broken Mod Scenes on "'+mod_data.mod+'"'))
			else:
				print(str('ModLoader: Broken Mod pck on "'+mod_data.mod+'"'))
