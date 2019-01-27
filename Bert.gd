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

signal bert_ist_in_der_geilen_karre
signal bert_hat_heute_geil_geratzt

const MAXSPEED_X = 800
const ACCEL_X = 400
const CAR_ACCEL_X = 1200
const CAR_MAXSPEED_X = 2000
const GRAVITY = 200

var accel_x
var maxspeed_x

const touch_focus = true
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
const RATE_DAMAGE_WHILE_TIRED = .4
const RATE_CAR_DECAY = .6
const RATE_STRESS_BY_SCHROTTKARRE = .5
# changes at certain times
const DIFF_MONEY_AFTER_WORK = 100
const DIFF_MONEY_PER_FOOD = 5
const DIFF_HUNGER_PER_FOOD = 10

const RENT = 800

# starting values
const INIT_CASH = 3000
const INIT_FOOD = 7

func _ready():
	goalPos = position
	goalDir = 0
	
	randomize()

	# starting values
	cash = INIT_CASH
	food = INIT_FOOD
	
	stat[CARDAMAGE] = 10
	stat[UNPOPULARITY] = 25
	
	maxspeed_x = MAXSPEED_X
	accel_x = ACCEL_X

func continuous_changes_in_stats(delta):
	if velocity.x != 0 and mode != DRIVING:
		stat[FATIGUE] += RATE_FATIGUE_WHILE_WALKING * delta
	if mode == AT_HOME:
		stat[STRESS] += RATE_STRESS_AT_HOME * delta
	stat[HUNGER] += RATE_HUNGER_WHILE_ANYTHING * delta
	stat[MANHUNT] += RATE_MANHUNT_WHILE_ANYTHING * delta

	if stat[FATIGUE] == 100:
		stat[DAMAGE] += RATE_DAMAGE_WHILE_TIRED * delta
		
	if mode == DRIVING:
		stat[CARDAMAGE] += RATE_CAR_DECAY * delta
		
	if stat[CARDAMAGE] > 80:
		stat[STRESS] += RATE_STRESS_BY_SCHROTTKARRE * delta
	
func handle_stats(delta):
	continuous_changes_in_stats(delta)
	if randi() % 10000 == 0: stat[MANHUNT] += 30

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

	if Input.is_mouse_button_pressed(BUTTON_LEFT) and deadtime == 0 and touch_focus:
		goalPos = get_global_mouse_position()
		goalDir = sign(goalPos.x - position.x)
		deadtime = TOUCH_DEADTIME
		
	# should do first : complete whatever action has to be finished until goal can be aimed at
	var distance_x = goalPos.x - position.x
	var veldelta_x = delta * ACCEL_X * goalDir
	if distance_x * goalDir > 0 and not is_on_wall():
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
	
	if mode == DRIVING: #FIX THIS
		velocity.y = 0
		velocity.x = CAR_MAXSPEED_X * goalDir
		position += velocity * delta
		position.x = clamp(position.x, -200, 5300) #QUICKFIX
		emit_signal("bert_ist_in_der_geilen_karre", position, velocity)
	else:
		velocity.y = velocity.y + GRAVITY;
		position += velocity * delta
		if position.x < -400:
			position.x = -400
			velocity.x = 0
		elif position.x > 6000:
			position.x = 6000
			velocity.x = 0
			#QUICKFIX
		
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
	mode = DRIVING
	#$CollisionShape2D.disabled = true
	#$Camera2D.current = false

func _on_GeileKarre_get_out_of_car():
	show()
	mode = where_am_I_walking(position.x)
	velocity = Vector2()
	$CollisionShape2D.disabled = false
	$Camera2D.current = true
	
func where_am_I_walking(x):
	if x < 0:
		return AT_HOME
	elif x > 2000 and x < 2500:
		return AT_THE_STORE 
	elif x > 5000:
		return AT_WORK
	else:
		return WALKING_OUTSIDE
	
func _on_ExclHome_take_focus():
	touch_focus = false

func _on_HomeMenu_reset_focus():
	touch_focus = true

func _on_ExclWork_take_focus():
	touch_focus = false

func _on_ExclStore_take_focus():
	touch_focus = false
# QUICKFIX UUUUUGLY

func _on_HomeMenu_button1(ID):
	print("button 1 of ", ID)
	
	if ID == "Home": # ratzen
		stat[FATIGUE] -= 50
		emit_signal("bertSleptToday")
		
	if ID == "Store": # karre flicken
		cash -= 250
		stat[CARDAMAGE] = 0
		
	if ID == "Work": # halbtags
		stat[STRESS] += 8
		cash += 400
		stat[UNPOPULARITY] += 5

func _on_HomeMenu_button2(ID):
	print("button 2 of ", ID)

	if ID == "Home": # essen
		if food > 0:
			if stat[HUNGER] < 15:
				stat[DAMAGE] += 15
			food -= 1
			stat[HUNGER] -= 30

	if ID == "Store": # essen kaufen
		cash -= 50
		food += 1
		
	if ID == "Work": # 8h
		stat[STRESS] += 23
		cash += 850
		stat[UNPOPULARITY] -= 10

func _on_Main_haveToEat():
	if food == 0:
		stat[HUNGER] += 15
	else:
		if stat[HUNGER] < 15:
			stat[DAMAGE] += 15
		food -= 1
		stat[HUNGER] -= 30

func _on_Main_haveToPayRent():
	if cash >= RENT:
		cash -= RENT
	elif cash > 0:
		cash = 0
		stat[STRESS] += 25
		stat[UNPOPULARITY] += 10
	else:
		cash = 0
		stat[STRESS] += 50
		stat[UNPOPULARITY] += 30
		stat[MANHUNT] += 5


func _on_Main_increaseStat(iStat, amt):
	if iStat >= 0 and iStat < stat.size():
		stat[iStat] = clamp(stat[iStat] + amt, 0, 100)
