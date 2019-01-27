extends Sprite

signal play_explosion

var elapsed = 0
var screensize

func _ready():
	screensize = get_viewport().size
	position = Vector2(screensize.x/2, screensize.y/2)
	show()

func _process(delta):
	var mod = cos(4*TAU*elapsed)*.5 + .5
	set("modulate",Color(1,mod,mod,1))
	
	position = Vector2(screensize.x/2 + (randi() % 6 - 3), screensize.y/2 + (randi() % 6 - 3))	
	
	if Input.is_mouse_button_pressed(BUTTON_LEFT):
		emit_signal("play_explosion")
		get_parent().remove_child(self)
	
	elapsed += delta