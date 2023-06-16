extends Control
var default_save_info = {
	"name":"Jack Campbell",
	"difficulty":0
}
var difficultys = ["Walk In The Park (Easy)", "Hell On Earth (Medium)", "The Devils Nightmare (Hard)"]
signal any_button
var menu = false
var loaded_save:Dictionary
var new_game = false
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	#Global.ingame = false
	reset()
	save_scanner()
	Mods.mod_scanner()
	call_deferred("fx")
	Global.update_graphics.connect(self.fx)
	await any_button
	menu=true
	$anim.play("menu")
func _input(_event):
	if not menu:
		if Input.is_anything_pressed():
			any_button.emit()
func debug():
	if Global.debug_ext:
		$main/buttons/vbox/debug.show()
	else:
		$main/buttons/vbox/debug.hide()
func _on_mods_pressed():
	$anim.play("mods")
func _on_exit_pressed():
	get_tree().quit()
func reset():
	$anim.play("RESET")
	$mods.hide()
# Mods:
func _on_mods_exit_pressed():
	$anim.play_backwards("mods")
func _on_add_mod_pressed():
	$anim_old.play("add_mods")
func _on_add_mods_back_pressed():
	$anim_old.play_backwards("add_mods")
# Play:
func _on_play_exit_pressed():
	$anim.play_backwards("play")
func _on_new_save_pressed():
	new_game = true
	var default = default_save_info
	update_ui("save", true, [default.name, default.difficulty])
	$anim_old.play("new_game")
	loaded_save = {}
func _on_new_save_back_pressed():
	if new_game:
		$anim_old.play_backwards("new_game")
		new_game=false
	else:
		$anim_old.play_backwards("continue")
func _on_single_pressed():
	get_tree().change_scene_to_file("res://src/world.tscn")
	if loaded_save == {}:
		Global.player.name = %playerinput/fillout/name.text
		Global.difficulty = %playerinput/fillout/difficulty.selected
		loaded_save = Saves.get_global_save()
		Saves.save_game(loaded_save)
	Saves.load_save(loaded_save)
# Save & Loader:
func save_scanner():
	var folder = Global.get_home() + "/Saves"
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
	var finm = 0
	while finm != files.size():
		if ".save" in files[finm] or ".json" in files[finm]:
			var json = JSON.new()
			var config = modsfolder + "/" + files[finm]
			if FileAccess.file_exists(config):
				var file = FileAccess.open(config, FileAccess.READ)
				json.parse(file.get_as_text())
				var save_data = json.get_data()
				Global.debug_log(json.get_error_message())
				var mod_button = load("res://src/resources/ui/mod_button.tscn").instantiate()
				Global.saves[save_data.name.to_lower().replace(":", "").replace("/", "").replace("-", "").replace("+", "").replace("=", "").replace("$", "").replace("%", "").replace("^", "").replace("&", "").replace("*", "").replace("(", "").replace(")", "").replace("~", "").replace("`", "").replace("?", "").replace("!", "").replace("@", "").replace("#", "").replace(">", "").replace("<", "").replace(",", "").replace(".", "").replace(";", "").replace(":", "").replace(" ", "_")] = save_data
				mod_button.name = save_data.name.to_lower().replace(":", "").replace("/", "").replace("-", "").replace("+", "").replace("=", "").replace("$", "").replace("%", "").replace("^", "").replace("&", "").replace("*", "").replace("(", "").replace(")", "").replace("~", "").replace("`", "").replace("?", "").replace("!", "").replace("@", "").replace("#", "").replace(">", "").replace("<", "").replace(",", "").replace(".", "").replace(";", "").replace(":", "").replace(" ", "_")
				mod_button.text = save_data.name
				mod_button.pressed.connect(self.load_save.bind(mod_button))
				%save_list.add_child(mod_button)
				%save_list.move_child(%save_list/new_save, %save_list.get_child_count())
			else:
				Global.debug_log("SaveLoader: Corrupted Save")
		finm = finm + 1
func load_save(button):
	var save_name = button.name
	var save = Global.saves[save_name]
	%save_info_name.text = save["name"]
	%save_info.text = "Difficulty: {1}\nHealth: {2}\nStamina: {3}\nBattery/Flashlight Power: {4}\nCurrent Quest:\n{5}\nCurrent Objective:\n{6}".format([save["name"], difficultys[save["difficulty"]], str(save["stats"].health), str(save["stats"].stamina), str(save["stats"].power), Global.get_quest_name(save["quest"])[0], Global.get_quest_name(save["quest"])[1]])
	$anim_old.play("continue")
	loaded_save = save
func _on_debug_pressed():
	get_tree().change_scene("res://src/testing/debug_scenes.tscn")
# Graphics:
func update_ui(what:String, active:bool, extra_data=[]):
	if what == "save":
		%playerinput/fillout/name.editable = active
		%playerinput/fillout/name.text = extra_data[0]
		%playerinput/fillout/difficulty.selected = extra_data[1]
		%playerinput/fillout/difficulty.disabled = not(active)
# Settings:
var setv = {"sm":"rendering/scaling_3d/mode","lpm":"application/run/low_processor_mode","msaa":"rendering/anti_aliasing/quality/msaa","ssaa":"rendering/anti_aliasing/quality/screen_space_aa","taa":"rendering/anti_aliasing/quality/use_taa"}
func fx():
	if not Global.efficiency_mode:
		ProjectSettings.set_setting(setv.sm, 1)
		ProjectSettings.set_setting(setv.lpm, false)
		ProjectSettings.set_setting(setv.msaa, 3)
		ProjectSettings.set_setting(setv.ssaa, 1)
		ProjectSettings.set_setting(setv.taa, true)
		$settings_menu.set_overlay(true)
	else:
		ProjectSettings.set_setting(setv.sm, 0)
		ProjectSettings.set_setting(setv.lpm, true)
		ProjectSettings.set_setting(setv.msaa, 0)
		ProjectSettings.set_setting(setv.ssaa, 0)
		ProjectSettings.set_setting(setv.taa, false)
		$settings_menu.set_overlay(false)
func _on_play_pressed():
	$anim.play("play")
