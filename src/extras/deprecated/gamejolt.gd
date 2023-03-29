extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

var result

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func load_api():
	var GameJoltAPI = load("res://src/extras/GameJoltAPI.tscn").instantiate()
	add_child(GameJoltAPI)
	api().auth_user(Global.gamejolt_info[1], Global.gamejolt_info[2])
	print("GameJolt: Loaded Gamejolt API")
	GameJoltAPI.api_authenticated.connect(self.api_authenticated)
	GameJoltAPI.api_user_fetched.connect(self.api_user_fetched)
	GameJoltAPI.api_session_opened.connect(self.api_session_opened)
	GameJoltAPI.api_session_closed.connect(self.api_session_closed)
	GameJoltAPI.api_session_pinged.connect(self.api_session_pinged)

func api() -> Node:
	var api_node=get_child(0)
	return api_node

func trophy(trophy):
	api().set_trophy_achieved(trophy_ids[trophy])

func api_authenticated(data):
	if data.success == "true":
		api().fetch_user(Global.gamejolt_info[1], Global.gamejolt_info[2])
	else:
		print("GameJolt: Failed To authenticate user")

func api_user_fetched(data):
	print("GameJolt: Authenticated User, "+data.users[0].username+" ("+data.users[0].id+")")

func api_session_opened(data):
	if data.success == "true":
		print("GameJolt: Session Opened")
	else:
		print("GameJolt: Session Failed To Open!, Message: "+str(data.message))

func api_session_closed(data):
	print("GameJolt: Closed Session")
	get_tree().quit()

func api_trophy_set_achieved(data):
	if data.success == "true":
		print("GameJolt: Trophy Gotten")
	else:
		print("GameJolt: Failed To Get Trophy!, Message: "+str(data.message))

func api_session_pinged(data):
	if data.success == "true":
		print("GameJolt: Pinged Session")
	else:
		print("GameJolt: Failed To Ping Session!, Message: "+str(data.message))

var trophy_ids = {
	"so_it_begins":171784,
	"muffin_for_your_troubles":171785,
	"the_eye":171787,
	"vent_inspector":171788,
	"banana":171786
}
