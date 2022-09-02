extends RigidBody3D

signal exploded

var velocity = Vector3.ZERO

var damage = 10

func _ready():
	hide()

func _physics_process(delta):
	pass

func shoot(rot, pos):
	show()
	#self.rotation = rot
	#look_at(pos)
	var angle = rot.y 
	var anglex = rot.x
	linear_velocity = Vector3(sin(angle),sin(anglex)-sin(anglex)*2, cos(angle)) * 100
	linear_velocity=linear_velocity-linear_velocity*2
	
	#self.linear_velocity = 
	var t = Timer.new()
	t.set_wait_time(2)
	t.set_one_shot(true)
	self.add_child(t)
	t.start()
	t.timeout.connect(self.end_bullet.bind("timeout"))

func end_bullet(type, body=null):
	if type == "timeout":
		print("Bullet: No Hit")
		queue_free()
	elif type == "hit":
		print("Bullet: Hit "+str(body))
		if body.has_method("shot"):
			body.shot(damage)
		queue_free()

func _on_Shell_body_entered(body):
	emit_signal("exploded", transform.origin)
	queue_free()


func _on_bullet_body_entered(body):
	if body.name != "Player":
		end_bullet("hit", body)


func _on_rigid_dynamic_body_3d_body_entered(body):
	if body.name != "Player" and body != self:
		end_bullet("hit", body)


func _on_area_3d_body_entered(body):
	if body.name != "Player" and body != self:
		end_bullet("hit", body)
