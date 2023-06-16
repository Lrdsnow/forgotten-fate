extends Control

# Variable Declaration
var focusedButton: Button = null
var save_select_scene = false
var difficultys = ["Walk In The Park (Easy)", "Hell On Earth (Medium)", "The Devils Nightmare (Hard)"]
signal any_button

# On Start
func _ready():
	await any_button
	save_select()
	update_saves()

# Tranisition to Save Select Screen
func save_select():
	$anim.play("save")
	focusedButton = %save_container.get_children()[0]
	focusedButton.grab_focus()
	save_select_scene=true

# UI Input handling
func _input(event):
	if save_select_scene:
		if event.is_action_pressed("ui_accept"):
			focusedButton.pressed.emit()
	else:
		if Input.is_anything_pressed():
			any_button.emit()

# Save Handler
func update_saves():
	var saves = Saves.get_saves()
	for save in saves:
		var save_button = Button.new()
		save_button.text = save["name"]+"\nDifficulty: "+difficultys[save["difficulty"]]+"\nCurrent Quest:\n"+Global.get_quest_name(save["quest"])[0]+"\nCurrent Objective:\n"+Global.get_quest_name(save["quest"])[1]
		save_button.custom_minimum_size = Vector2(460,432)
		save_button.pressed.connect(save_pressed.bind(save))
		%save_container.add_child(save_button)
	%save_container.move_child(%new_save, %save_container.get_child_count()-1)


# Transition to Start Screen
func save_pressed(save):
	for obj in get_tree().get_nodes_in_group("new_game"):
		obj.hide()
	%save_data.text = "{0}\nDifficulty: {1}\nHealth: {2}\nStamina: {3}\nBattery/Flashlight Power: {4}\nCurrent Quest:\n{5}\nCurrent Objective:\n{6}".format([save["name"], difficultys[save["difficulty"]], str(save.stats.health), str(save.stats.stamina), str(save.stats.power), Global.get_quest_name(save["quest"])[0], Global.get_quest_name(save["quest"])[1]])
	$anim.play("start")
	focusedButton = %start_container.get_children()[0]
	focusedButton.grab_focus()

# Go Back to Save Select From Start Screen
func _on_start_back_pressed():
	$anim.play_backwards("start")

# Transition To Start Screen But for a new game
func _on_new_save_pressed():
	%save_data.text = "Name:"
	for obj in get_tree().get_nodes_in_group("new_game"):
		obj.show()
	$anim.play("start")

# Start Game
func _on_singleplayer_pressed(save={}):
	if not ProjectSettings.get_setting("rendering/renderer/rendering_method") == "mobile":
		get_tree().change_scene_to_file("res://src/world.tscn")
	else:
		get_tree().change_scene_to_file("res://src/mobile_world_all.tscn")
	if save == {}:
		Global.player.name = "Jack Campbell"
		Global.difficulty = 0
		Saves.save_game(Saves.get_global_save())
	Saves.load_save(save)
