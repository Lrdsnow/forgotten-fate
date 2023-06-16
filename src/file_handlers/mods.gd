extends Node

func mod_scanner():
	var dmodslist: VBoxContainer = get_node_or_null("/root/menu/mods/menu/panel/dmodslist")
	var folder = Global.get_home() + "/Mods"
	var modsfolder = folder
	var files = []
	var dir = DirAccess.open(folder)
	dir.list_dir_begin()

	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif not file.begins_with("."):
			files.append(file)
	dir.list_dir_end()
	for file in files:
		if ".mod" in file:
			var json = JSON.new()
			var config = modsfolder + "/" + file + "/mod.json"
			print(config)
			if FileAccess.file_exists(config):
				var file_access = FileAccess.open(config, FileAccess.READ)
				var data = json.parse(file_access.get_as_text())
				var mod_data = json.get_data()
				var outdated = false
				@warning_ignore("unused_variable")
				var legacy = false
				
				if mod_data.has("min_ver"):
					if mod_data.min_ver > Global.version:
						outdated = true
				
				if not outdated:
					var mod_button = load("res://src/resources/ui/mod_button.tscn").instantiate()
					Global.mods.all.append(file)
					Global.mods.unused.append(file)
					Global.mods.data[Global.lower(mod_data.mod)] = mod_data
					Global.mods.folders[Global.lower(mod_data.mod)] = file
					
					if dmodslist != null:
						var temp_node = dmodslist.get_node_or_null("temp")
						if temp_node != null:
							temp_node.hide()
					
					mod_button.name = Global.lower(mod_data.mod)
					mod_button.text = mod_data.mod
					mod_button.pressed.connect(self.mod_pressed.bind(mod_button))
					
					if dmodslist != null:
						dmodslist.add_child(mod_button)
					
					if mod_data.has("autoload") and mod_data.autoload:
						mod_pressed(mod_button, true)
					else:
						Global.debug_log('ModLoader: Found Mod "' + str(mod_button.name) + '"')
				else:
					if outdated:
						Global.debug_log('ModLoader: Outdated Client For Mod "' + str(file) + '"')
					else:
						Global.debug_log('ModLoader: Something Went Wrong For Mod "' + str(file) + '"')
			else:
				Global.debug_log('ModLoader: Broken Mod "' + str(file) + '"')

func mod_pressed(button, autoload=false):
	var modslist: VBoxContainer = get_node_or_null("/root/menu/mods/menu/panel/modslist")
	var dmodslist: VBoxContainer = get_node_or_null("/root/menu/mods/menu/panel/dmodslist")
	var mod_name = button.name
	if not autoload:
		Global.debug_log('ModLoader: Loaded Mod "' + str(mod_name) + '"')
	else:
		Global.debug_log('ModLoader: Found & Loaded Mod "' + str(mod_name) + '"')
	
	var mod_button = load("res://src/resources/ui/mod_button.tscn").instantiate()
	Global.mods.used.append(mod_name)
	Global.mods.unused.erase(mod_name)
	mod_button.name = Global.lower(mod_name)
	mod_button.text = button.text
	
	if modslist != null:
		modslist.add_child(mod_button)
		modslist.move_child(modslist.get_node("add_mod"), Global.mods.unused.size())
	
	button.hide()
	button.queue_free()
	
	if dmodslist != null:
		if dmodslist.get_child_count() == 2:
			dmodslist.get_node("temp").show()
		else:
			dmodslist.get_node("temp").hide()
	
	var mod_data = Global.mods.data[Global.lower(mod_name)]
	
	if modslist != null:
		modslist.get_node(Global.lower(mod_data.mod)).pressed.connect(self.disable_mod.bind(mod_button))
	
	if mod_data.has("full_game") and mod_data.full_game:
		Global.mods.loaded[mod_name] = mod_data
		var mod_pck = Global.get_home() + "/Mods" + "/" + Global.mods.folders[Global.lower(mod_data.mod)] + "/" + mod_data.pck
		
		var mod_package = ProjectSettings.load_resource_pack(mod_pck)
		
		if mod_package and ResourceLoader.exists(mod_data.scene):
			var mod_inst = load(mod_data.scene).instantiate()
			get_node("/root").call_deferred("add_child", mod_inst)
		else:
			Global.debug_log('ModLoader: Broken Mod Scenes on "' + mod_data.mod + '"')
	else:
		Global.mods.unloaded[mod_name] = mod_data
	
	if get_node_or_null("/root/menu/anim") != null:
		get_node("/root/menu/anim_old").play_backwards("add_mods")

func disable_mod(button):
	var modslist: VBoxContainer = get_node_or_null("/root/menu/mods/menu/panel/modslist")
	var dmodslist: VBoxContainer = get_node_or_null("/root/menu/mods/menu/panel/dmodslist")
	var mod_name = button.name
	
	Global.debug_log('ModLoader: Loaded Mod "' + mod_name + '"')
	
	var mod_button = load("res://src/resources/ui/mod_button.tscn").instantiate()
	Global.mods.unused.append(mod_name)
	Global.mods.used.erase(mod_name)
	mod_button.name = Global.lower(mod_name)
	mod_button.text = button.text
	
	if dmodslist != null:
		dmodslist.add_child(mod_button)
	
	if modslist != null:
		modslist.move_child(modslist.get_node("add_mod"), Global.used_mods.size())
	
	button.hide()
	button.queue_free()
	
	var mod_data = Global.mod_datas[Global.lower(mod_name)]
	
	if dmodslist != null:
		dmodslist.get_node(Global.lower(mod_data.mod)).pressed.connect(self.mod_pressed.bind(mod_button))
	
	if mod_data.full_game:
		var mod_folder = "res://mods/" + Global.lower(mod_data.mod)
		var dir = DirAccess.open(mod_folder)
		dir.remove(mod_folder)

func load_mod(files, finm, mod_data, dmodslist):
	Global.debug_log('ModLoader: Found Legacy Mod "' + str(files[finm]) + '"')
	
	var mod_button = load("res://src/resources/ui/mod_button.tscn").instantiate()
	Global.mods.append(files[finm])
	Global.unused_mods.append(files[finm])
	Global.mod_datas[Global.lower(mod_data.mod)] = mod_data
	Global.mod_folders[Global.lower(mod_data.mod)] = files[finm]
	
	if dmodslist != null:
		dmodslist.get_node("temp").hide()
	
	mod_button.name = Global.lower(mod_data.mod)
	mod_button.text = mod_data.mod
	mod_button.pressed.connect(self.mod_pressed.bind(mod_button))
	
	if dmodslist != null:
		dmodslist.add_child(mod_button)
