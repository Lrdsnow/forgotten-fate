extends Control

var default_save_info = {
	"name":"Jack Campbell",
	"difficulty":0
}

var loaded_save:Dictionary
@export_enum("itch", "trifate-studios") var release
var releases = ["itch", "trifate-studios", "steam"]

func _ready():
	if OS.get_name() == "Web" or OS.get_name() == "Android" or OS.get_name() == "iOS":
		Global.efficiency_mode = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	Global.ingame = false
	reset()
	save_scanner()
	Mods.mod_scanner()
	call_deferred("fx")
	call_deferred("resize")
	get_tree().root.size_changed.connect(self.resize)
	Global.release = releases[release]
	Global.call_deferred("GameChecker")
	Global.update_graphics.connect(self.fx)

func debug():
	if Global.debug_ext:
		$main/buttons/vbox/debug.show()
	else:
		$main/buttons/vbox/debug.hide()

func _on_new_game_pressed():
	$anim.play("open_play")


func _on_continue_pressed():
	pass # Replace with function body.


func _on_mods_pressed():
	$anim.play("open_mods")

func _on_exit_pressed():
	Global.quit_game()

func reset():
	$anim.play("RESET")
	$mods.hide()

# Mods:

func _on_mods_exit_pressed():
	$anim.play_backwards("open_mods")

func _on_add_mod_pressed():
	$anim.play("add_mods")


func _on_add_mods_back_pressed():
	$anim.play_backwards("add_mods")

# Play:

func _on_play_exit_pressed():
	$anim.play_backwards("open_play")

func _on_new_save_pressed():
	var default = default_save_info
	update_ui("save", true, [default.name, default.difficulty])
	$anim.play("new_game")
	loaded_save = {}


func _on_new_save_back_pressed():
	$anim.play_backwards("new_game")

func _on_single_pressed():
	if not Global.efficiency_mode:
		get_tree().change_scene_to_file("res://src/world.tscn")
	else:
		get_tree().change_scene_to_file("res://src/extras/efficent_world.tscn")
	if loaded_save == {}:
		Global.player_name = $play/menu/panel/new_game/playerinput/fillout/name.text
		Global.difficulty = $play/menu/panel/new_game/playerinput/fillout/difficulty.selected
		loaded_save = Global.resave()
		Global.save_game()
	Global.load_save(loaded_save)

func _on_multi_pressed():
	pass # Replace with function body.

# Save & Loader:

func save_scanner():
	var dmodslist:VBoxContainer = $mods/menu/panel/dmodslist
	var folder = Global.get_home() + "/Saves"
	var modsfolder = folder
	Global.saves_folder = modsfolder
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
	var finm = 0
	while finm != files.size():
		if ".save" in files[finm] or ".json" in files[finm]:
			var json = JSON.new()
			var config = modsfolder + "/" + files[finm]
			if FileAccess.file_exists(config):
				var file = FileAccess.open(config, FileAccess.READ)
				var data = json.parse(file.get_as_text())
				var save_data = json.get_data()
				print(json.get_error_message())
				var mod_button = load("res://src/resources/ui/mod_button.tscn").instantiate()
				Global.saves[Global.lower(save_data.player_name)] = save_data
				mod_button.name = Global.lower(save_data.player_name)
				mod_button.text = save_data.player_name
				mod_button.pressed.connect(self.load_save.bind(mod_button))
				$play/menu/panel/save_list.add_child(mod_button)
				$play/menu/panel/save_list.move_child($play/menu/panel/save_list/new_save, $play/menu/panel/save_list.get_child_count())
			else:
				print("SaveLoader: Corrupted Save")
		finm = finm + 1

func load_save(button):
	var save_name = button.name
	var save_data = Global.saves[save_name]
	update_ui("save", false, [save_data.player_name, save_data.difficulty])
	$anim.play("continue")
	loaded_save = save_data


func _on_debug_pressed():
	get_tree().change_scene("res://src/testing/debug_scenes.tscn")

# Graphics:

func update_ui(what:String, active:bool, extra_data=[]):
	if what == "save":
		$play/menu/panel/new_game/playerinput/fillout/name.editable = active
		$play/menu/panel/new_game/playerinput/fillout/name.text = extra_data[0]
		$play/menu/panel/new_game/playerinput/fillout/difficulty.selected = extra_data[1]
		$play/menu/panel/new_game/playerinput/fillout/difficulty.disabled = not(active)
		if not Global.debug_ui:
			$play/menu/panel/new_game/playerinput/skins.hide()
			$play/menu/panel/new_game/HBoxContainer/multi.hide()

func resize():
	get_node("/root").mode = 3
	$main/title/shad.size.x = get_viewport_rect().size.x / 3.65714286
	$main/title/shad.size.y = get_viewport_rect().size.y / 2.4
	$main/buttons.size = get_viewport_rect().size
	$main/title.size.x = get_viewport_rect().size.x

# Settings:

var setv = {
	"sm":"rendering/scaling_3d/mode",
	"lpm":"application/run/low_processor_mode",
	"msaa":"rendering/anti_aliasing/quality/msaa",
	"ssaa":"rendering/anti_aliasing/quality/screen_space_aa",
	"taa":"rendering/anti_aliasing/quality/use_taa"
}

func fx():
	if not Global.efficiency_mode:
		ProjectSettings.set_setting(setv.sm, 1)
		ProjectSettings.set_setting(setv.lpm, false)
		ProjectSettings.set_setting(setv.msaa, 3)
		ProjectSettings.set_setting(setv.ssaa, 1)
		ProjectSettings.set_setting(setv.taa, true)
		$settings.set_overlay(true)
	else:
		ProjectSettings.set_setting(setv.sm, 0)
		ProjectSettings.set_setting(setv.lpm, true)
		ProjectSettings.set_setting(setv.msaa, 0)
		ProjectSettings.set_setting(setv.ssaa, 0)
		ProjectSettings.set_setting(setv.taa, false)
		$settings.set_overlay(false)
