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

# wait some time between two registered touch events
const TOUCH_DEADTIME = .25
var deadtime = 0

var elapsed = 0

var velocity = Vector2()
onready var goalPos
onready var goalDir

enum STATS { STRESS, FATIGUE, HUNGER, DAMAGE, UNPOPULARITY, CARDAMAGE, MANHUNT }
var stat = PoolRealArray([0,0,0,0,0,0,0])
var cash
var food

enum MODES { AT_HOME, SLEEP, DRIVING, AT_WORK, WALKING_OUTSIDE, AT_THE_STORE}
var mode = AT_HOME

# continuously changing parameters
const RATE_STRESS_AT_HOME = -.1
const RATE_FATIGUE_WHILE_WALKING = .1
const RATE_HUNGER_WHILE_ANYTHING = .2
const RATE_MANHUNT_WHILE_ANYTHING = -.1
# changes at certain times
const DIFF_MONEY_AFTER_WORK = 100
const DIFF_MONEY_PER_FOOD = 5
const DIFF_HUNGER_PER_FOOD = 10

# starting values
const INIT_CASH = 200
const INIT_FOOD = 100

func _ready():
	goalPos = position
	goalDir = 0
	
	randomize()

	# starting values
	cash = INIT_CASH
	food = INIT_FOOD
	
	stat[CARDAMAGE] = 10
	stat[UNPOPULARITY] = 70
	

func continuous_changes_in_stats(delta):
	if velocity.x != 0 and mode != DRIVING:
		stat[FATIGUE] += RATE_FATIGUE_WHILE_WALKING * delta
	if mode == AT_HOME:
		stat[STRESS] += RATE_STRESS_AT_HOME * delta
	stat[HUNGER] += RATE_HUNGER_WHILE_ANYTHING * delta
	stat[MANHUNT] += RATE_MANHUNT_WHILE_ANYTHING * delta
	
func handle_stats(delta):
	continuous_changes_in_stats(delta)

	var stat_overall = 0
	for i in stat.size():
		stat[i] = clamp(stat[i], 0, 100)
		stat_overall = max(stat_overall, stat[i])

	var mod_r = clamp(2 * 0.01 * stat_overall, 0, 1)
	var mod_g = clamp(2 - 2 * 0.01 * stat_overall, 0, 1) * .7
	set("modulate", Color(mod_r, mod_g, 1))
	
	emit_signal("updateStress", stat[STRESS])
	emit_signal("updateFatigue", stat[FATIGUE])
	emit_signal("updateHunger", stat[HUNGER])
	emit_signal("updateDamage", stat[DAMAGE])
	emit_signal("updateUnpopularity", stat[UNPOPULARITY])
	emit_signal("updateCarDamage", stat[CARDAMAGE])
	emit_signal("updateManhunt", stat[MANHUNT])
	
	emit_signal("updateCash", cash)
	emit_signal("updateFood", food)

func _physics_process(delta):
	deadtime = max(deadtime - delta, 0)

	if Input.is_mouse_button_pressed(BUTTON_LEFT) and deadtime == 0:
		goalPos = get_global_mouse_position()
		goalDir = sign(goalPos.x - position.x)
		deadtime = TOUCH_DEADTIME
		
	# should do first : complete whatever action has to be finished until goal can be aimed at
	var distance_x = goalPos.x - position.x
	var veldelta_x = delta * ACCEL_X * goalDir
	if distance_x * goalDir > 0:
		velocity.x = clamp(velocity.x + veldelta_x, -MAXSPEED_X, MAXSPEED_X)

		# do some funny deceleration
		if distance_x * goalDir < velocity.x * velocity.x / (2*ACCEL_X):
			velocity.x -= 2*veldelta_x

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
	
	handle_stats(delta)

func _on_Player_body_entered(body):
	hide()
	emit_signal("hit")
	$CollisionShape2D.disabled = true


func _on_GeileKarre_get_in_car():
	hide()
	$Camera2D.current = false

func _on_GeileKarre_get_out_of_car():
	show()
	$Camera2D.current = true