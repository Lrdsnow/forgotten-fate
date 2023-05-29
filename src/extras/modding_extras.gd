extends Node

var modded_save = {}

signal on_game_started # Emited When Game Is Started

func add_item(item_name:String, item_type:String, item_obj:Node): # Adds an item to the game
	if Global.ingame:
		Global.all_items.append(item_name)
		if Global.get(item_type) != null:
			Global.get(item_type).append(item_name)
		var item_container = get_node("/root/World/Player").get_node(get_node("/root/World/Player").get_meta("item_container"))
		item_container.call_deferred("add_child", item_obj)
		print("Extras: add_item: Added Item")
	else:
		print("Extras: add_item: Cannot add item!, Not In Game!")

func add_save_menu_opt(value_name:String, type:String) -> Node: # (Requires full_game:true in mod config) (Enables Modded Save!, May Break Other Mods!) Adds a option to save. Supported types: bool
	if ! Global.ingame:
		Global.modded_save = true
		if type == "bool":
			var button = CheckBox.new()
			button.text = value_name
			var menu = self.get_node("/root/menu")
			menu = menu.get_node(menu.get_meta("mod_values"))
			menu.show()
			menu.add_child(button)
			return button
			print("Extras: add_save_menu_opt: Added New Checkbox To Save Menu")
		else:
			print("Extras: add_save_menu_opt: unsupported type: "+type)
			return null
	else:
		print("Extras: add_save_menu_opt: Cannot add Option to Save Menu!, In game!")
		return null

func add_save_dict_to_save(save_extras:Dictionary): # (full_game:true Recomended in mod config) (Enables Modded Save! May Break Other Mods!)
	Global.modded_save = true
	modded_save=save_extras
	print("Extras: add_save_dict_to_save: Added Extras To Save")

func add_quest(quest:Dictionary): # Adds a quest
	Global.quests.append(quest)
	print("Extras: add_quest: Added New Quest")

func replace_questline(questline:Array): # Replaces questline
	Global.quests = questline
	print("Extras: replace_questline: Set New Questline")

func set_env(enviorment:Environment, permanent:bool=true): # Replaces questline
	Global.mod_env_override = permanent
	Global.env = enviorment
	print("Extras: set_env: Set Custom Enviorment")

func set_efficency(enabled:bool): # Sets Efficency Mode
	Global.efficiency_mode = enabled
	print("Extras: set_efficency: Set Efficency Mode To "+str(enabled))

func set_held_item(item_name:String): # Sets Held Item
	Global.player_held_item = item_name
	print('Extras: set_held_item: Set Current Held Item To "'+str(item_name)+'"')

func add_object(object:Node, position:Vector3, rotation:Vector3): # Loads an item into the world
	if Global.ingame:
		get_node("/root/World").add_child(object)
		print("Extras: add_object: Loaded Object")
		#object.position = position
		#object.rotation = rotation
	else:
		print("Extras: add_object: Cannot load object!, Not In Game!")

func setup_discord():
	# Main:
	discord_sdk.app_id = 1003060749695983616 # Application ID
	print("Discord working: " + str(discord_sdk.get_is_discord_working())) # A boolean if everything worked
	discord_sdk.details = "Main Menu"
	discord_sdk.state = "Main Menu"
	
	discord_sdk.large_image = "chapter-2" # Image key from "Art Assets"
	discord_sdk.large_image_text = "Main Menu"
	#discord_sdk.small_image = "chapter-1" # Image key from "Art Assets"
	#discord_sdk.small_image_text = "Test"

	discord_sdk.start_timestamp = int(Time.get_unix_time_from_system()) # "02:46 elapsed"
	# discord_sdk.end_timestamp = int(Time.get_unix_time_from_system()) + 3600 # +1 hour in unix time / "01:00 remaining"
	
	# Party:
	#discord_sdk.current_party_size = 1
	#discord_sdk.max_party_size = 2
	#discord_sdk.is_public_party = true
	#discord_sdk.party_id = "PARTY"
	#discord_sdk.instanced = true

	# Refresh:
	discord_sdk.refresh() # Always refresh after changing the values!

func update_discordrp():
	var rp = Global.get_quest_rpdata()
	discord_sdk.details = rp[0]
	discord_sdk.state = rp[1]
	discord_sdk.large_image = rp[2]
	discord_sdk.large_image_text = rp[3]
	discord_sdk.refresh()
