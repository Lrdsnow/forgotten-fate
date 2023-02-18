extends Control

var default_save_info = {
	"name":"Jack Campbell",
	"difficulty":0
}

var loaded_save:Dictionary
@export_enum("itch", "trifate-studios", "gamejolt") var release
var releases = ["itch", "trifate-studios", "gamejolt","steam"]

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	Global.ingame = false
	reset()
	save_scanner()
	Mods.mod_scanner()
	menu_update()
	call_deferred("fx")
	call_deferred("resize")
	get_tree().root.size_changed.connect(self.resize)
	Global.release = releases[release]
	Global.call_deferred("GameChecker")

func debug():
	if Global.debug_ext:
		$main/buttons/vbox/debug.show()
	else:
		$main/buttons/vbox/debug.hide()

func fx():
	if not Global.efficiency_mode:
		ProjectSettings.set_setting("rendering/scaling_3d/mode", 1)
		ProjectSettings.set_setting("application/run/low_processor_mode", false)
		ProjectSettings.set_setting("rendering/anti_aliasing/screen_space_roughness_limiter/enabled", true)
		ProjectSettings.set_setting("rendering/anti_aliasing/quality/msaa", 3)
		ProjectSettings.set_setting("rendering/anti_aliasing/quality/screen_space_aa", 1)
		ProjectSettings.set_setting("rendering/anti_aliasing/quality/use_taa", true)
		var background = load("res://src/extras/menu.tscn").instantiate()
		add_child(background)
		move_child(background, get_child_count())
		var overlay = load("res://src/extras/overlay.tscn").instantiate()
		get_node("/root").add_child(overlay)
	else:
		ProjectSettings.set_setting("rendering/scaling_3d/mode", 0)
		ProjectSettings.set_setting("application/run/low_processor_mode", true)
		ProjectSettings.set_setting("rendering/anti_aliasing/screen_space_roughness_limiter/enabled", false)
		ProjectSettings.set_setting("rendering/anti_aliasing/quality/msaa", 0)
		ProjectSettings.set_setting("rendering/anti_aliasing/quality/screen_space_aa", 0)
		ProjectSettings.set_setting("rendering/anti_aliasing/quality/use_taa", false)
		

func _on_new_game_pressed():
	$anim.play("open_play")


func _on_continue_pressed():
	pass # Replace with function body.


func _on_mods_pressed():
	$anim.play("open_mods")


func _on_settings_pressed():
	pass # Replace with function body.


func _on_exit_pressed():
	Global.quit_game()

func resize():
	get_node("/root").mode = 3
	
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
	if Global.gamejolt:
		Gamejolt.api().open_session()
	if not Global.efficiency_mode:
		get_tree().change_scene_to_file("res://src/world.tscn")
	else:
		get_tree().change_scene_to_file("res://src/extras/efficent_world.tscn")
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
	var dmodslist:VBoxContainer = $mods/menu/panel/dmodslist
	var dfn = 0
	var dfnd = true
	while dfnd:
		if "Documents" in OS.get_system_dir(dfn):
			docs = OS.get_system_dir(dfn)
			dfnd = false
		else:
			dfn = dfn + 1
	var dir = DirAccess.open(docs)
	while ! dir.dir_exists("My Games/ForgottenFate/Saves"):
		if dir.dir_exists("My Games"):
			if dir.dir_exists("My Games/ForgottenFate"):
				if dir.dir_exists("My Games/ForgottenFate/Saves"):
					pass
				else:
					dir.make_dir("My Games/ForgottenFate/Saves")
			else:
				dir.make_dir("My Games/ForgottenFate")
		else:
			dir.make_dir("My Games")
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
			var json = JSON.new()
			var config = modsfolder + "/" + files[finm]
			if FileAccess.file_exists(config):
				var file = FileAccess.open(config, FileAccess.READ)
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
				print("SaveLoader: Corrupted Save")
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


func _on_debug_pressed():
	get_tree().change_scene("res://src/testing/debug_scenes.tscn")
