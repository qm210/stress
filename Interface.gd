extends Control

var elapsed = 0

func _ready():
	_on_Bert_updateStress(0)
	_on_Bert_updateFatigue(0)
	_on_Bert_updateHunger(0)
	_on_Bert_updateDamage(0)
	_on_Bert_updateUnpopularity(0)
	_on_Bert_updateCarDamage(0)
	_on_Bert_updateManhunt(0)
	
	_on_Bert_updateCash(0)
	_on_Bert_updateFood(0)

func _on_Bert_updateStress(val):
	$BarUpper1.set("self_modulate", Color(.01*val,0,0,1))
	$BarUpper1/HBoxContainer/Label.text = str(int(val)) + '% Stress'
	$BarUpper1.visible = (val >= 1)

func _on_Bert_updateFatigue(val):
	$BarUpper2.set("self_modulate", Color(.01*val,0,0,1))
	$BarUpper2/HBoxContainer/Label.text = str(int(val)) + '% Fatigue'
	$BarUpper2.visible = (val >= 1)

func _on_Bert_updateHunger(val):
	$BarUpper3.set("self_modulate", Color(.01*val,0,0,1))
	$BarUpper3/HBoxContainer/Label.text = str(int(val)) + '% Hunger'
	$BarUpper3.visible = (val >= 1)

func _on_Bert_updateDamage(val):
	$BarLower1.set("self_modulate", Color(.01*val,0,0,1))
	$BarLower1/HBoxContainer/Label.text = str(int(val)) + '% Damage'
	$BarLower1.visible = (val >= 1)

func _on_Bert_updateUnpopularity(val):
	$BarLower2.set("self_modulate", Color(.01*val,0,0,1))
	$BarLower2/HBoxContainer/Label.text = str(int(val)) + '% Unpopularity'
	$BarLower2.visible = (val >= 1)

func _on_Bert_updateCarDamage(val):
	$BarLower3.set("self_modulate", Color(.01*val,0,0,1))
	$BarLower3/HBoxContainer/Label.text = str(int(val)) + '% Car Damage'
	$BarLower3.visible = (val >= 1)

func _on_Bert_updateManhunt(val):
	$BarLower4.set("self_modulate", Color(.01*val,0,0,1))
	$BarLower4/HBoxContainer/Label.text = str(int(val)) + '% Manhunt'
	$BarLower4.visible = (val >= 1)

func _on_Bert_updateCash(val):
	$CashAndFood/CashLabel/.text = str(int(val)) + ' Cash'

func _on_Bert_updateFood(val):
	$CashAndFood/FoodLabel/.text = str(int(val)) + ' Food'

func _on_Main_updateTime(gameTimeMinutes, gameDay):
	$Clock.text = " %d.Tag %02d:%02d" % [gameDay+1, floor(gameTimeMinutes/60),fmod(gameTimeMinutes,60)]
			
func _process(delta):
	$UDEAD.rotate((PI/180)*(.5 * sin(TAU * elapsed * .9)))
	$UDEAD.scale = (1.3 + .3 * sin(TAU * elapsed * 1.3)) * Vector2(1,1)
	elapsed += delta

func _on_Bert_gameOver():
	$UDEAD.show()
