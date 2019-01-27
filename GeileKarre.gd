extends KinematicBody2D

signal get_in_car
signal get_out_of_car

const TOUCH_PROXIMITY = 150
const TOUCH_DEADTIME = .5
var deadtime = 0

enum STATES {STANDING, DRIVING}
var state = STANDING

func updateState():
	if state == STANDING:
		$AnimatedSprite.set_frame(0)
		$CollisionShape2D.scale.x = 11.24 #set_extends(Vector2(11.24, 3.66))
	elif state == DRIVING:
		$AnimatedSprite.set_frame(1)
		$CollisionShape2D.scale.x = 25 #set_extends(Vector2(25.00,3.66))

func changeState():
	if state == STANDING:
		state = DRIVING
		$Camera2D.current = true
		$CollisionShape2D.disabled = false
		emit_signal("get_in_car")
	else:
		state = STANDING
		emit_signal("get_out_of_car")
		$Camera2D.current = false
		$CollisionShape2D.disabled = true
		$AnimatedSprite.flip_h = false

func _physics_process(delta):
	deadtime = max(0, deadtime - delta)
	
	if Input.is_mouse_button_pressed(BUTTON_LEFT) and deadtime == 0:
		deadtime = TOUCH_DEADTIME	
		var distanceToTouch = (position - get_global_mouse_position()).length()
		var distanceToBert = (position - $"../Bert".position).length()
		if distanceToTouch <= TOUCH_PROXIMITY and distanceToBert <= TOUCH_PROXIMITY:
			changeState()
			updateState()

func _on_Bert_bert_ist_in_der_geilen_karre(bert_pos, bert_vel):
	position = bert_pos
	if bert_vel.x != 0: $AnimatedSprite.flip_h = (bert_vel.x < 0)
