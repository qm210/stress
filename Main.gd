extends Node

signal updateTime

const GAME_DAY_IN_REAL_MINUTES = .5

onready var gameTimeMinutes

func _ready():
	var realTime = OS.get_time()
	gameTimeMinutes = realTime.hour*60 + realTime.minute + realTime.second/60

	emit_signal("updateTime", gameTimeMinutes)

func _process(delta):
	
	if Input.is_key_pressed(KEY_ESCAPE):
		get_tree().quit()
		
	gameTimeMinutes = wrapf(gameTimeMinutes + delta/60 * 1440/GAME_DAY_IN_REAL_MINUTES, 0, 1440)
	emit_signal("updateTime", gameTimeMinutes)