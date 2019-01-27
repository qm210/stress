extends Node

signal updateTime
signal haveToEat
signal haveToPayRent
signal increaseStat

const GAME_DAY_IN_REAL_MINUTES = .1

onready var gameTimeMinutes
onready var gameDay 

var paidRentToday = false
var eaten1Today = false
var eaten2Today = false
var eaten3Today = false
var sleptToday = false

func _ready():
	var realTime = OS.get_time()
	gameTimeMinutes = realTime.hour*60 + realTime.minute + realTime.second/60
	gameDay = 0

	emit_signal("updateTime", gameTimeMinutes, gameDay)

func _process(delta):
	
	if Input.is_key_pressed(KEY_ESCAPE):
		get_tree().quit()
		
	gameTimeMinutes += delta/60 * 1440/GAME_DAY_IN_REAL_MINUTES
	
	if gameTimeMinutes > 8*60 and !eaten1Today:
		eaten1Today = true
		emit_signal("haveToEat")

	if gameTimeMinutes > 13*60 and !eaten2Today:
		eaten2Today = true
		emit_signal("haveToEat")

	if gameTimeMinutes > 19*60 and !eaten3Today:
		eaten3Today = true
		emit_signal("haveToEat")

	if gameTimeMinutes > 10*60 and !paidRentToday:
		paidRentToday = true
		emit_signal("haveToPayRent")

	


	if gameTimeMinutes > 1440:
		
		if gameDay >= 1:
			if !eaten1Today: emit_signal("increaseStat", 2, 20)
			if !eaten2Today: emit_signal("increaseStat", 2, 20)
			if !eaten3Today: emit_signal("increaseStat", 2, 20)
			if !sleptToday: emit_signal("increaseStat", 1, 50)

		gameTimeMinutes -= 1440
		gameDay += 1

		paidRentToday = false
		eaten1Today = false
		eaten2Today = false
		eaten3Today = false
		sleptToday = true
			
	emit_signal("updateTime", gameTimeMinutes, gameDay)


func _on_ExclWork_exclamation_clicked():
	pass # replace with function body


func _on_Bert_bert_hat_heute_geil_geratzt():
	sleptToday = true
