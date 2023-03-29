extends CharacterBody3D

var health = 100

@export var enemy_number = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	var viewport = $Health/viewport
	var sprite = $Health
	var rtt = viewport.get_texture()
	sprite.texture = rtt
	$Health/e.text = "Enemy "+str(enemy_number)
	$Health/viewport/health.value = health


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$Health.look_at(Global.get_player().position)

func shot(damage):
	health = health - damage
	$Health/viewport/health.value = health
	if health == 0:
		queue_free()
