extends StaticBody2D

export (String) var ID
signal exclamation_clicked
signal take_focus

const TOUCH_PROXIMITY = 160

onready var pos_x
onready var pos_y

onready var elapsed = 0

func _ready():
	pos_x = position.x
	pos_y = position.y
	
func _process(delta):
	
	if (position - $"../Bert".position).length() <= TOUCH_PROXIMITY:
		$AnimatedSprite.set_frame(1)
		scale = Vector2(.9, .9)
		position = Vector2(pos_x + (randi() % 5 - 2), pos_y + (randi() % 5 - 2))
	
		if Input.is_mouse_button_pressed(BUTTON_LEFT) and visible:
			var mousePos = get_global_mouse_position()
			var mouseRel = mousePos - position
			if mouseRel.length() < TOUCH_PROXIMITY:
				emit_signal("exclamation_clicked", ID)
				emit_signal("take_focus")

	else:
		$AnimatedSprite.set_frame(0)
		scale = Vector2(0.65, 0.65)
		position = Vector2(pos_x + 2*sin(TAU*elapsed*.5), pos_y + 2*sin(TAU*elapsed*.5))
		$AnimatedSprite.rotation_degrees = 12*sin(0.167*TAU*elapsed)
		
			
	elapsed += delta


