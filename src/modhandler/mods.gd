extends Node

func mod_scanner():
	var dmodslist:VBoxContainer = get_node_or_null("/root/menu/mods/menu/panel/dmodslist")
	var folder = Global.get_home() + "/Mods"
	var modsfolder = folder
	Global.mods_folder = folder
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
	var int_mods_folder = OS.get_executable_path().get_base_dir() + "/internal_mods"
	Global.int_mods_folder = int_mods_folder
	if dir.dir_exists(int_mods_folder):
		dir.open(int_mods_folder)
		dir.list_dir_begin()
		while true:
			var file = dir.get_next()
			if file == "":
				break
			elif not file.begins_with("."):
				files.append(file)
		dir.list_dir_end()
	var finm = 0
	while finm != files.size():
		if ".mod" in files[finm]:
			var json = JSON.new()
			var config = modsfolder + "/" + files[finm] + "/mod.config"
			if ! FileAccess.file_exists(config):
				config = int_mods_folder + "/" + files[finm] + "/mod.config" # Quick Fix
				if ! FileAccess.file_exists(config):
					config = modsfolder + "/" + files[finm] + "/mod.json"
					if ! FileAccess.file_exists(config):
						config = int_mods_folder + "/" + files[finm] + "/mod.json"
			if FileAccess.file_exists(config):
				var file = FileAccess.open(config, FileAccess.READ)
				var data = json.parse(file.get_as_text())
				var mod_data = json.get_data()
				var outdated = false
				var legacy = false
				if mod_data.has("min_ver"):
					if mod_data.min_ver > Global.version:
						outdated=true
					elif mod_data.has("min_sub_ver"):
						if mod_data.min_sub_ver > Global.sub_version:
							outdated=true
				if not outdated:
					var mod_button = load("res://src/resources/ui/mod_button.tscn").instantiate()
					Global.mods.append(files[finm])
					Global.unused_mods.append(files[finm])
					Global.mod_datas[Global.lower(mod_data.mod)] = mod_data
					Global.mod_folders[Global.lower(mod_data.mod)] = files[finm]
					if dmodslist != null:
						if dmodslist.get_node_or_null("temp") != null:
							dmodslist.get_node_or_null("temp").hide()
					mod_button.name=Global.lower(mod_data.mod)
					mod_button.text = mod_data.mod
					mod_button.pressed.connect(self.mod_pressed.bind(mod_button))
					if dmodslist != null:
						dmodslist.add_child(mod_button)
					if mod_data.has("autoload"):
						if mod_data.autoload:
							mod_pressed(mod_button, true)
						else:
							print('ModLoader: Found Mod "'+str(mod_button.name)+'"')
					else:
						print('ModLoader: Found Mod "'+str(mod_button.name)+'"')
				else:
					if outdated:
						print('ModLoader: Outdated Client For Mod "'+str(files[finm])+'"')
					else:
						print('ModLoader: Something Went Wrong For Mod "'+str(files[finm])+'"')
			else:
				print('ModLoader: Broken Mod "'+str(files[finm])+'"')
		finm = finm + 1

func mod_pressed(button, autoload=false):
	var modslist:VBoxContainer = get_node_or_null("/root/menu/mods/menu/panel/modslist")
	var dmodslist:VBoxContainer = get_node_or_null("/root/menu/mods/menu/panel/dmodslist")
	if not autoload:
		print(str('ModLoader: Loaded Mod "'+str(button.name)+'"'))
	else:
		print(str('ModLoader: Found & Loaded Mod "'+str(button.name)+'"'))
	var mod_button = load("res://src/resources/ui/mod_button.tscn").instantiate()
	var mod_name = button.name
	Global.used_mods.append(button.name)
	Global.unused_mods.erase(button.name)
	mod_button.name=Global.lower(button.name)
	mod_button.text =button.text
	if modslist != null:
		modslist.add_child(mod_button)
		modslist.move_child(modslist.get_node("add_mod"), Global.used_mods.size())
	button.hide()
	button.queue_free()
	if dmodslist != null:
		if dmodslist.get_child_count() == 2:
			dmodslist.get_node("temp").show()
		else:
			dmodslist.get_node("temp").hide()
	var mod_data = Global.mod_datas[Global.lower(mod_name)]
	if modslist != null:
		modslist.get_node(Global.lower(mod_data.mod)).pressed.connect(self.disable_mod.bind(mod_button))
	if mod_data.has("full_game"):
		if mod_data.full_game:
			Global.loaded_mods[mod_name] = mod_data
			var mod_pck = Global.mods_folder + "/" + Global.mod_folders[Global.lower(mod_data.mod)] + "/" + mod_data.pck
			if ! FileAccess.file_exists(mod_pck):
				mod_pck = Global.int_mods_folder + "/" + Global.mod_folders[Global.lower(mod_data.mod)] + "/" + mod_data.pck # Quick Fix
			var mod_package = ProjectSettings.load_resource_pack(mod_pck)
			if mod_package:
				if ResourceLoader.exists(mod_data.scene):
					var mod_inst = load(mod_data.scene).instantiate()
					get_node("/root").call_deferred("add_child", mod_inst)
				else:
					print(str('ModLoader: Broken Mod Scenes on "'+mod_data.mod+'"'))
			else:
				print(str('ModLoader: Broken Mod pck on "'+mod_data.mod+'"'))
		else:
			Global.unloaded_mods[mod_name] = mod_data
	else:
		Global.unloaded_mods[mod_name] = mod_data
	if get_node_or_null("/root/menu/anim") != null:
		get_node("/root/menu/anim").play_backwards("add_mods")

func disable_mod(button):
	var modslist:VBoxContainer = get_node_or_null("/root/menu/mods/menu/panel/modslist")
	var dmodslist:VBoxContainer = get_node_or_null("/root/menu/mods/menu/panel/dmodslist")
	print(str('ModLoader: Loaded Mod "'+button.name+'"'))
	var mod_button = load("res://src/resources/ui/mod_button.tscn").instantiate()
	var mod_name = button.name
	Global.used_mods.append(button.name)
	Global.unused_mods.erase(button.name)
	mod_button.name=Global.lower(button.name)
	mod_button.text=button.text
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
	print('ModLoader: Found Legacy Mod "'+str(files[finm])+'"')
	var mod_button = load("res://src/resources/ui/mod_button.tscn").instantiate()
	Global.mods.append(files[finm])
	Global.unused_mods.append(files[finm])
	Global.mod_datas[Global.lower(mod_data.mod)] = mod_data
	Global.mod_folders[Global.lower(mod_data.mod)] = files[finm]
	if dmodslist != null:
		dmodslist.get_node("temp").hide()
	mod_button.name=Global.lower(mod_data.mod)
	mod_button.text = mod_data.mod
	mod_button.pressed.connect(self.mod_pressed.bind(mod_button))
	if dmodslist != null:
		dmodslist.add_child(mod_button)
