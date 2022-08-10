extends Control

var default_save_info = {
	"name":"Jack Campbell",
	"difficulty":0
}

var loaded_save:Dictionary

func _ready():
	Global.ingame = false
	reset()
	save_scanner()
	mod_scanner()
	menu_update()
	call_deferred("fx")
	call_deferred("resize")
	get_tree().root.size_changed.connect(self.resize)

func fx():
	if not Global.efficiency_mode:
		var background = load("res://src/extras/menu.tscn").instantiate()
		add_child(background)
		move_child(background, get_child_count())
		var overlay = load("res://src/extras/overlay.tscn").instantiate()
		get_node("/root").add_child(overlay)

func _on_new_game_pressed():
	$anim.play("open_play")


func _on_continue_pressed():
	pass # Replace with function body.


func _on_mods_pressed():
	$anim.play("open_mods")


func _on_settings_pressed():
	pass # Replace with function body.


func _on_exit_pressed():
	get_tree().quit()

func resize():
	#get_node("/root").mode = 3
	
	$main/title/shad.size.x = get_viewport_rect().size.x / 3.65714286
	$main/title/shad.size.y = get_viewport_rect().size.y / 2.4
	$main/buttons.size = get_viewport_rect().size
	$main/title.size.x = get_viewport_rect().size.x
	

func reset():
	$anim.play("RESET")
	$mods.hide()

func menu_update():
	var nc:int = 0
	while nc != $main/buttons/vbox.get_child_count():
		var buttons = $main/buttons/vbox.get_children()
		if str(buttons[nc].name) in Global.buttons:
			buttons[nc].show()
		else:
			buttons[nc].hide()
		nc=nc+1

# Mods:

func _on_mods_exit_pressed():
	$anim.play_backwards("open_mods")

func mod_scanner():
	var docs = ""
	var dmodslist:VBoxContainer = $mods/menu/panel/dmodslist
	var dfn = 0
	var dfnd = true
	while dfnd:
		if "Documents" in OS.get_system_dir(dfn):
			docs = OS.get_system_dir(dfn)
			dfnd = false
		else:
			dfn = dfn + 1
	var dir = Directory.new()
	while ! dir.dir_exists(docs + "/My Games/ForgottenFate/Mods"):
		if dir.dir_exists(docs + "/My Games"):
			if dir.dir_exists(docs + "/My Games/ForgottenFate"):
				if dir.dir_exists(docs + "/My Games/ForgottenFate/Mods"):
					pass
				else:
					dir.make_dir(docs + "/My Games/ForgottenFate/Mods")
			else:
				dir.make_dir(docs + "/My Games/ForgottenFate")
		else:
			dir.make_dir(docs + "/My Games")
	var folder = docs + "/My Games/ForgottenFate/Mods"
	var modsfolder = folder
	Global.mods_folder = folder
	var files = []
	dir.open(folder)
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
			var file = File.new()
			var json = JSON.new()
			var config = modsfolder + "/" + files[finm] + "/mod.config"
			if ! file.file_exists(config):
				config = int_mods_folder + "/" + files[finm] + "/mod.config" # Quick Fix
				if ! file.file_exists(config):
					config = modsfolder + "/" + files[finm] + "/mod.json"
					if ! file.file_exists(config):
						config = int_mods_folder + "/" + files[finm] + "/mod.json"
			if file.file_exists(config):
				file.open(config, File.READ)
				@warning_ignore(unused_variable)
				var data = json.parse(file.get_as_text())
				var mod_data = json.get_data()
				var outdated = false
				if mod_data.has("min_ver"):
					if ! mod_data.min_ver >= Global.version:
						outdated=true
					elif mod_data.has("min_sub_ver"):
						if ! mod_data.min_sub_ver >= Global.sub_version:
							outdated=true
				if not outdated:
					var mod_button = load("res://src/resources/ui/mod_button.tscn").instantiate()
					print("Found Mod")
					Global.mods.append(files[finm])
					Global.unused_mods.append(files[finm])
					Global.mod_datas[Global.lower(mod_data.mod)] = mod_data
					Global.mod_folders[Global.lower(mod_data.mod)] = files[finm]
					dmodslist.get_node("temp").hide()
					mod_button.name=Global.lower(mod_data.mod)
					mod_button.text = mod_data.mod
					mod_button.pressed.connect(self.mod_pressed.bind(mod_button))
					dmodslist.add_child(mod_button)
					if mod_data.has("autoload"):
						if mod_data.autoload:
							mod_pressed(mod_button)
				else:
					print("Outdated Client")
			else:
				print("Broken Mod")
		finm = finm + 1

func mod_pressed(button):
	var modslist:VBoxContainer = $mods/menu/panel/modslist
	var dmodslist:VBoxContainer = $mods/menu/panel/dmodslist
	print("Load Mod")
	var mod_button = load("res://src/resources/ui/mod_button.tscn").instantiate()
	var mod_name = button.name
	Global.used_mods.append(button.name)
	Global.unused_mods.erase(button.name)
	mod_button.name=Global.lower(button.name)
	mod_button.text =button.text
	modslist.add_child(mod_button)
	modslist.move_child(modslist.get_node("add_mod"), Global.used_mods.size())
	button.hide()
	button.queue_free()
	print(dmodslist.get_child_count())
	if dmodslist.get_child_count() == 2:
		dmodslist.get_node("temp").show()
	else:
		dmodslist.get_node("temp").hide()
	var mod_data = Global.mod_datas[Global.lower(mod_name)]
	modslist.get_node(Global.lower(mod_data.mod)).pressed.connect(self.disable_mod.bind(mod_button))
	if mod_data.has("full_game"):
		if mod_data.full_game:
			var file = File.new()
			var mod_pck = Global.mods_folder + "/" + Global.mod_folders[Global.lower(mod_data.mod)] + "/" + mod_data.pck
			print(mod_pck)
			if ! file.file_exists(mod_pck):
				mod_pck = Global.int_mods_folder + "/" + Global.mod_folders[Global.lower(mod_data.mod)] + "/" + mod_data.pck # Quick Fix
			var mod_package = ProjectSettings.load_resource_pack(mod_pck)
			if mod_package:
				if file.file_exists(mod_data.scene):
					var mod_inst = load(mod_data.scene).instantiate()
					get_node("/root").call_deferred("add_child", mod_inst)
				else:
					print("Broken Mod Scenes")
			else:
				print("Broken Mod pck")
	$anim.play_backwards("add_mods")

func disable_mod(button):
	var modslist:VBoxContainer = $mods/menu/panel/modslist
	var dmodslist:VBoxContainer = $mods/menu/panel/dmodslist
	print("Load Mod")
	var mod_button = load("res://src/resources/ui/mod_button.tscn").instantiate()
	var mod_name = button.name
	Global.used_mods.append(button.name)
	Global.unused_mods.erase(button.name)
	mod_button.name=Global.lower(button.name)
	mod_button.text=button.text
	dmodslist.add_child(mod_button)
	modslist.move_child(modslist.get_node("add_mod"), Global.used_mods.size())
	button.hide()
	button.queue_free()
	print(modslist.get_child_count())
	var mod_data = Global.mod_datas[Global.lower(mod_name)]
	dmodslist.get_node(Global.lower(mod_data.mod)).pressed.connect(self.mod_pressed.bind(mod_button))
	if mod_data.full_game:
		var dir = Directory.new()
		var mod_folder = "res://mods/" + Global.lower(mod_data.mod)
		dir.remove(mod_folder)

func _on_add_mod_pressed():
	$anim.play("add_mods")


func _on_add_mods_back_pressed():
	$anim.play_backwards("add_mods")

# Play:

func _on_play_exit_pressed():
	$anim.play_backwards("open_play")

func _on_new_save_pressed():
	var default = default_save_info
	$play/menu/panel/new_game/fillout/name.editable = true
	$play/menu/panel/new_game/fillout/name.text = default.name
	$play/menu/panel/new_game/fillout/difficulty.selected = default.difficulty
	$play/menu/panel/new_game/fillout/difficulty.disabled = false
	$anim.play("new_game")
	loaded_save = {}


func _on_new_save_back_pressed():
	$anim.play_backwards("new_game")

func _on_single_pressed():
	if not Global.efficiency_mode:
		get_tree().change_scene("res://src/world.tscn")
	else:
		get_tree().change_scene("res://src/extras/efficent_world.tscn")
	if loaded_save == {}:
		Global.player_name = $play/menu/panel/new_game/fillout/name.text
		Global.difficulty = $play/menu/panel/new_game/fillout/difficulty.selected
		loaded_save = Global.resave()
		Global.save_game()
	Global.load_save(loaded_save)

func _on_multi_pressed():
	pass # Replace with function body.

# Save & Loader:

func save_scanner():
	var docs = ""
	@warning_ignore(unused_variable)
	var dmodslist:VBoxContainer = $mods/menu/panel/dmodslist
	var dfn = 0
	var dfnd = true
	while dfnd:
		if "Documents" in OS.get_system_dir(dfn):
			docs = OS.get_system_dir(dfn)
			dfnd = false
		else:
			dfn = dfn + 1
	var dir = Directory.new()
	while ! dir.dir_exists(docs + "/My Games/ForgottenFate/Saves"):
		if dir.dir_exists(docs + "/My Games"):
			if dir.dir_exists(docs + "/My Games/ForgottenFate"):
				if dir.dir_exists(docs + "/My Games/ForgottenFate/Saves"):
					pass
				else:
					dir.make_dir(docs + "/My Games/ForgottenFate/Saves")
			else:
				dir.make_dir(docs + "/My Games/ForgottenFate")
		else:
			dir.make_dir(docs + "/My Games")
	var folder = docs + "/My Games/ForgottenFate/Saves"
	var modsfolder = folder
	Global.saves_folder = modsfolder
	Global.mods_folder = folder
	var files = []
	dir.open(folder)
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
		if ".save" in files[finm] or ".json" in files[finm]:
			var file = File.new()
			var json = JSON.new()
			var config = modsfolder + "/" + files[finm]
			if file.file_exists(config):
				file.open(config, File.READ)
				@warning_ignore(unused_variable)
				var data = json.parse(file.get_as_text())
				var save_data = json.get_data()
				var mod_button = load("res://src/resources/ui/mod_button.tscn").instantiate()
				Global.saves[Global.lower(save_data.player_name)] = save_data
				mod_button.name = Global.lower(save_data.player_name)
				mod_button.text = save_data.player_name
				mod_button.pressed.connect(self.load_save.bind(mod_button))
				$play/menu/panel/save_list.add_child(mod_button)
				$play/menu/panel/save_list.move_child($play/menu/panel/save_list/new_save, $play/menu/panel/save_list.get_child_count())
			else:
				print("Corrupted Save")
		finm = finm + 1

func load_save(button):
	var save_name = button.name
	var save_data = Global.saves[save_name]
	$play/menu/panel/new_game/fillout/name.editable = false
	$play/menu/panel/new_game/fillout/name.text = save_data.player_name
	$play/menu/panel/new_game/fillout/difficulty.selected = save_data.difficulty
	$play/menu/panel/new_game/fillout/difficulty.disabled = true
	$anim.play("continue")
	loaded_save = save_data


func _on_set_exit_pressed():
	pass # Replace with function body.
