extends KinematicBody2D

signal updateStress
signal updateFatigue
signal updateHunger
signal updateDamage
signal updateUnpopularity
signal updateCarDamage
signal updateManhunt
signal updateCash
signal updateFood
# bad conscience? not for hitting fat kids with an ax

const MAXSPEED_X = 800
const ACCEL_X = 400
const GRAVITY = 200

var touch_ground = false

var elapsed = 0

var velocity = Vector2()
onready var goalPos
onready var goalDir

var stat = PoolIntArray([0,0,0,0,0,0,0])

enum PLACES { AT_HOME, DRIVING, AT_WORK, WALKING_OUTSIDE, AT_THE_STORE}
enum STATS { STRESS, FATIGUE, HUNGER, DAMAGE, UNPOPULARITY, CARDAMAGE, MANHUNT }

func _ready():
	goalPos = position
	goalDir = 0
	
	randomize()

func _physics_process(delta):

	if Input.is_mouse_button_pressed(BUTTON_LEFT) and touch_ground:
		goalPos = get_global_mouse_position()
		goalDir = sign(goalPos.x - position.x)
		print(goalPos.x, ' ', position.x, ' ', $Camera2D.get_camera_position().x, ' ', self.get_global_mouse_position().x)
		
	# should do first : complete whatever action has to be finished until goal can be aimed at
	var distance_x = goalPos.x - position.x
	var veldelta_x = delta * ACCEL_X * goalDir
	if distance_x * goalDir > 0:
		velocity.x = clamp(velocity.x + veldelta_x, -MAXSPEED_X, MAXSPEED_X)

		# do some funny deceleration
		if distance_x * goalDir < velocity.x * velocity.x / (2*ACCEL_X):
			velocity.x -= 2*veldelta_x

		print(distance_x * goalDir, ' ', velocity.x, ' ', veldelta_x, ' ', goalDir, ' ', velocity.x * velocity.x * .5 / ACCEL_X)
	else:
		velocity.x = 0
		goalDir = 0
		
	if abs(velocity.x) > 0:
		$AnimatedSprite.frames.set_animation_speed("walking", 5 + 40 * abs(velocity.x)/MAXSPEED_X)
		$AnimatedSprite.flip_h = (goalDir < 0)
		$AnimatedSprite.play() #short for get_node("AnimatedSprite").play()
	else:
		$AnimatedSprite.set_frame(0)
		$AnimatedSprite.stop()
	
	velocity.y = velocity.y + GRAVITY;

	position += velocity * delta

	var stopslide_x = position.x	
	if move_and_collide(velocity*delta): velocity.y = 0
	position.x = stopslide_x
	
	#touch_ground = is_on_floor()
	touch_ground = true
		
	# the below is tmp stuff
	if elapsed > 1:
		elapsed = 0

		for i in stat.size():
			stat[i] = randi() % 101
			print(i, ' ',stat[i])

	emit_signal("updateStress", stat[STRESS])
	emit_signal("updateFatigue", stat[FATIGUE])
	emit_signal("updateHunger", stat[HUNGER])
	emit_signal("updateDamage", stat[DAMAGE])
	emit_signal("updateUnpopularity", stat[UNPOPULARITY])
	emit_signal("updateCarDamage", stat[CARDAMAGE])
	emit_signal("updateManhunt", stat[MANHUNT])
		
	var stat_avg = 0
	for i in stat.size():
		stat_avg += stat[i]/stat.size()

	var mod_r = clamp(2 * 0.01 * stat_avg, 0, 1)
	var mod_g = clamp(2 - 2 * 0.01 * stat_avg, 0, 1) * .7
	set("modulate", Color(mod_r,mod_g,1))
	
	elapsed += delta

func _on_Player_body_entered(body):
	hide()
	emit_signal("hit")
	$CollisionShape2D.disabled = true
	
	
func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false
