extends Spatial

var fdlc = false
var fcon = false
var mods = []
var modsfolder = ""
var mod_exec = ""
var modscene = ""
var game_mod = false
var mod_exit = false
var set_exit = false
var ext_exit = false
var exdif = false
var FGMod = false
var truefateanim = false

func _ready():
	$difficulty/AnimationPlayer.play_backwards("truefate")
	get_node("difficulty/cc/menu/true").hide()
	scale()
	save_finder()
	dlc()
	mods()
	$mod_menu.hide()
	if fdlc and fcon:
		pass
	elif fdlc:
		$cc/vc/Continue.hide()
	elif fcon:
		$cc/vc/Multiplayer.hide()
	else:
		$cc/vc/Continue.hide()
		$cc/vc/Multiplayer.hide()

var pos = {"ng":Vector2(0,670),"con":false,"mp":false,"mod":Vector2(0,715),"st":Vector2(0,760),"ext":Vector2(0,805),"ex":Vector2(0,850)}
var pos_wContinue = {"ng":Vector2(0,715),"con":Vector2(0,670),"mp":false,"mod":Vector2(0,760),"st":Vector2(0,805),"ext":Vector2(0,850),"ex":Vector2(0,895)}
var pos_wMultiplayer = {"ng":Vector2(0,670),"con":false,"mp":Vector2(0,715),"mod":Vector2(0,760),"st":Vector2(0,805),"ext":Vector2(0,850),"ex":Vector2(0,895)}
var pos_wMultiplayer_wContinue = {"ng":Vector2(0,715),"con":Vector2(0,670),"mp":Vector2(0,760),"mod":Vector2(0,805),"st":Vector2(0,850),"ext":Vector2(0,895),"ex":Vector2(0,940)}


func _on_Button_pressed():
	$difficulty.show()
	$difficulty/AnimationPlayer.play("in")

func dlc():
	var file = File.new()
	if file.file_exists(ProjectSettings.globalize_path("res://") + "../twistedfate 2/mdlc.pck"):
		dlc_loader(ProjectSettings.globalize_path("res://") + "../twistedfate 2/mdlc.pck")
	elif file.file_exists(ProjectSettings.globalize_path("res://") + "../twistedfate/mdlc.pck"):
		dlc_loader(ProjectSettings.globalize_path("res://") + "../twistedfate/mdlc.pck")
	else:
		print("NO DLC")

func save_finder():
	var file = File.new()
	if file.file_exists("user://user.save"):
		fcon = true
		print("SAVE FOUND")
		Playerglobal.load_game()
	else:
		print("NO SAVE")

func dlc_loader(dlc: String):
	print("DLC FOUND")
	var success = ProjectSettings.load_resource_pack(dlc)
	if success:
		print("succsess")
		$cc/vc/Multiplayer.show()
		fdlc = true

func mods():
	$mod_menu/cc/modmenu/selmod.add_item("   Select a Mod")
	var dnf = true
	var dfn = 0
	var docs = ""
	while dnf == true:
		if "Documents" in OS.get_system_dir(dfn):
			print("Documents is number: " + str(dfn))
			docs = OS.get_system_dir(dfn)
			dnf = false
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
	if dir.dir_exists(docs + "/My Games/ForgottenFate/Mods"):
		var folder = docs + "/My Games/ForgottenFate/Mods"
		modsfolder = folder
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
		while true:
			if finm == files.size():
				break
			elif ".pck" in files[finm]:
					print("Single File Mod found on number: " + str(finm))
					mods.append(files[finm])
					var s := ""
					s = files[finm]
					s.erase(s.length() - 4, 4)
					s = "   " + s.capitalize()
					$mod_menu/cc/modmenu/selmod.add_item(s)
			elif ".mod" in files[finm]:
					print("Folder Mod found on number: " + str(finm))
					mods.append(files[finm])
					var s := ""
					s = files[finm]
					s.erase(s.length() - 4, 4)
					s = "   " + s.capitalize()
					$mod_menu/cc/modmenu/selmod.add_item(s)
			finm = finm + 1

func _on_play_dlc_pressed():
	get_tree().change_scene("res://dlc/multiplayerdlc/main.tscn")

func _on_selmod_item_selected(index):
	var mod = $mod_menu/cc/modmenu/selmod.get_item_text(index)
	if "Select a Mod" in mod:
		$mod_menu/cc/modmenu/info/title.text = "Select A Mod"
		$mod_menu/cc/modmenu/info.text = "\n\nWarning: Mod's Are Expirimental And May Crash Your Game At ANY Moment."
		$mod_menu/cc/modmenu/info/Play.hide()
	else:
		modselect(index)

func modselect(index):
	$mod_menu/cc/modmenu/info/Play.disabled = false
	var mod = $mod_menu/cc/modmenu/selmod.get_item_text(index)
	mod.erase(0, 3)
	mod = mod.to_lower().replace(" ", "_")
	var modtype = 0
	var nor = 0
	var modtitle = $mod_menu/cc/modmenu/selmod.get_item_text(index)
	modtitle.erase(0, 3)
	while true:
		if nor == mods.size():
			break
		if mod+".pck" in mods[nor]:
			modtype = 0
			break
		elif mod+".mod" in mods[nor]:
			modtype = 1
			break
		else:
			nor=nor+1
	if modtype == 0:
		$mod_menu/cc/modmenu/info/title.text = modtitle
		$mod_menu/cc/modmenu/info.text = ""
		mod_exec = modsfolder + "/" + mods[nor]
		var mod_name = mods[nor]
		mod_name.erase(mod_name.length() - 4, 4)
		modscene = "res://mods/" + mod_name + "/main.tscn"
		$mod_menu/cc/modmenu/info/Play.show()
	elif modtype == 1:
		var mod_data
		var config = modsfolder + "/" + mods[nor] + "/mod.config"
		var file = File.new()
		if file.file_exists(config):
			file.open(config, File.READ)
			var data = parse_json(file.get_as_text())
			mod_data = data
			$mod_menu/cc/modmenu/info/title.text = mod_data.mod
			$mod_menu/cc/modmenu/info.text = "\nBy: " + mod_data.author
			mod_exec = modsfolder + "/" + mods[nor] + "/" + mod_data.exec
			modscene = mod_data.scene
			if mod_data.game == true:
				game_mod=true
				$mod_menu/cc/modmenu/info/Play.text = "Enable"
			else:
				$mod_menu/cc/modmenu/info/Play.text = "Play"
				game_mod = false
			if mod_data.full == true:
				FGMod = true
			else:
				FGMod = false
			$mod_menu/cc/modmenu/info/Play.show()
		else:
			printerr("Config Does Not Exist!: " + config )


func _on_Play_pressed():
	if ! game_mod:
		print(mod_exec)
		var success = ProjectSettings.load_resource_pack(mod_exec)
		if success:
			get_tree().change_scene(modscene)
		else:
			printerr("Mod Failed To Load!")
	else:
		if ! FGMod:
			Playerglobal.mods.append(mod_exec)
			Playerglobal.modss.append(modscene)
			$mod_menu/cc/modmenu/info/Play.text = "Enabled"
		else:
			var success = ProjectSettings.load_resource_pack(mod_exec)
			if success:
				var fgmodinst = load(modscene).instance()
				get_node("/root").add_child(fgmodinst)
				$mod_menu/cc/modmenu/info/Play.text = "Enabled"
			else:
				printerr("Failed To Load Mod.")
				$mod_menu/cc/modmenu/info/Play.disabled = true
				$mod_menu/cc/modmenu/info/Play.text = "Broken"


func _on_Mods_pressed():
	$mod_menu/AnimationPlayer.play("in")
	$mod_menu.show()


func _on_exit_pressed():
	$mod_menu/AnimationPlayer.play_backwards("in")
	mod_exit = true


# warning-ignore:unused_argument
func _on_AnimationPlayer_animation_finished(anim_name):
	if mod_exit == true:
		$mod_menu.hide()
		mod_exit=false


func _on_settings_exit_pressed():
	$cc/vc/Settings_menu/setan.play_backwards("in")
	set_exit = true


func _on_Settings_pressed():
	$cc/vc/Settings_menu.show()
	$cc/vc/Settings_menu/setan.play("in")

func _on_setan_animation_finished(anim_name):
	if set_exit == true:
		$cc/vc/Settings_menu.hide()
		set_exit=false


func _on_Extras_pressed():
	$cc/vc/Extras_menu.show()
	$cc/vc/Extras_menu/extan.play("in")

func _on_extan_animation_finished(anim_name):
	if ext_exit == true:
		$cc/vc/Extras_menu.hide()
		ext_exit=false


func _on_extras_exit_pressed():
	$cc/vc/Extras_menu/extan.play_backwards("in")
	ext_exit = true


func _on_Exit_pressed():
	get_tree().quit()

func scale():
	$title.rect_size.x = get_viewport().size.x
	$cc.rect_size = get_viewport().size
	$mod_menu/cc.rect_size = get_viewport().size
	$mod_menu/blur.rect_size = get_viewport().size
	$difficulty/cc.rect_size = get_viewport().size
	$difficulty/blur.rect_size = get_viewport().size
	$vhs/VHS.rect_size = get_viewport().size

func lightloop():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var rt = rng.randf_range(0.5, 1.5)
	var t = Timer.new()
	t.set_wait_time(rt)
	t.set_one_shot(true)
	self.add_child(t)
	t.start()
	$light.hide()
	yield(t, "timeout")
	$light.show()
	t.queue_free()


# warning-ignore:unused_argument
func _on_flicker_animation_finished(anim_name):
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var rt = rng.randf_range(0.5, 1.5)
	var t = Timer.new()
	t.set_wait_time(rt)
	t.set_one_shot(true)
	self.add_child(t)
	t.start()
	yield(t, "timeout")
	t.queue_free()
	$flicker.play("flicker")
	


func _on_medium_pressed():
	Playerglobal.difficulty = 1
	$cc.hide()
	$title.hide()
	$mod_menu.hide()
	$settings_menu.hide()
	$extras_menu.hide()
	$difficulty.hide()
	loader.load_scene("res://Scenes/World.tscn")


func _on_easy_pressed():
	Playerglobal.difficulty = 0
	$cc.hide()
	$title.hide()
	$mod_menu.hide()
	$settings_menu.hide()
	$extras_menu.hide()
	$difficulty.hide()
	loader.load_scene("res://Scenes/World.tscn")


func _on_hard_pressed():
	Playerglobal.difficulty = 2
	$cc.hide()
	$title.hide()
	$mod_menu.hide()
	$settings_menu.hide()
	$extras_menu.hide()
	$difficulty.hide()
	loader.load_scene("res://Scenes/World.tscn")


func _on_dif_exit_pressed():
	exdif = true
	if Playerglobal.achivements.yourtruefate:
		$difficulty/AnimationPlayer.play_backwards("truefate")
	$difficulty/AnimationPlayer.play_backwards("in")

func _on_dif_animation_finished(anim_name):
	if exdif:
		$difficulty.hide()
		exdif = false
		truefateanim = false
	elif Playerglobal.achivements.yourtruefate:
		if ! truefateanim:
			get_node("difficulty/cc/menu/true").show()
			$difficulty/AnimationPlayer.play("truefate")
			truefateanim = true


func _on_true_pressed():
	Playerglobal.difficulty = 3
	$cc.hide()
	$title.hide()
	$mod_menu.hide()
	$settings_menu.hide()
	$extras_menu.hide()
	$difficulty.hide()
	loader.load_scene("res://Scenes/World.tscn")


func _on_Continue_pressed():
	var file = File.new()
	if file.file_exists("user://user.save"):
		Playerglobal.load_game()
		Playerglobal.continue_game()