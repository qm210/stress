extends TextureRect

func _on_Main_updateTime(gameTimeMinutes):
	# background position: top at 2 pm, bottom at 2 am
	rect_position.y = -800 * (1-cos(TAU*(gameTimeMinutes-14*60)/1440))
	
