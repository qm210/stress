extends Area2D

var ID

const DEADTIME_UPON_SHOWING = .3
var deadtime

signal button1
signal button2
signal cancel
signal reset_focus

var option
var option_offset_for_this_ID

func _ready():
	var screensize = get_viewport().size
	position = Vector2(screensize.x/2, screensize.y/2)
	hide()
	option = 0
	option_offset_for_this_ID = 0
	deadtime = 0
	
func _process(delta):
	var mousePos = get_viewport().get_mouse_position()
	var mouseRel = mousePos - position
	
	if mouseRel.y > 165 - 200 and mouseRel.y < 345 - 200:
		if mouseRel.x > 200 - 480 and mouseRel.x < 380 - 480:
			option = 1
		elif mouseRel.x > 440 - 480 and mouseRel.x < 620 - 480:
			option = 2
		elif mouseRel.x > 680 - 480 and mouseRel.x < 860 - 480:
			option = 3
		else:
			option = 0
	else:
		option = 0
		
	$AnimatedSprite.set_frame(option_offset_for_this_ID + option)
	if Input.is_mouse_button_pressed(BUTTON_LEFT) and visible and option > 0 and deadtime == 0:
		hide()			
		emit_signal("reset_focus")
		if option == 1:
			emit_signal("button1", ID)
		elif option == 2:
			emit_signal("button2", ID)
		elif option == 3:
			emit_signal("cancel")

	deadtime = max(deadtime - delta, 0)

func _on_ExclHome_exclamation_clicked(cID):
	ID = "Home"
	option_offset_for_this_ID = 0
	var screensize = get_viewport().size
	position = Vector2(screensize.x/2, screensize.y/2)
	deadtime = DEADTIME_UPON_SHOWING
	show()

func _on_ExclWork_exclamation_clicked(cID):
	ID = "Work"
	option_offset_for_this_ID = 8
	var screensize = get_viewport().size
	position = Vector2(screensize.x/2, screensize.y/2)
	deadtime = DEADTIME_UPON_SHOWING
	show()

func _on_ExclStore_exclamation_clicked(cID):
	ID = "Store"
	option_offset_for_this_ID = 4
	var screensize = get_viewport().size
	position = Vector2(screensize.x/2, screensize.y/2)
	deadtime = DEADTIME_UPON_SHOWING
	show()

