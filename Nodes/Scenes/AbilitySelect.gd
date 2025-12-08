extends CanvasLayer

@export var abilities: Array[Ability]
var randomInt = Globals.randomInt
var index1 = 0
var index2 = 0 
var index3 = 0
func _ready():
	$LossCountBar.value = Globals.lossCount
	_GetAbilities()
	$Ability1.pressed.connect(_on_ability1_pressed)
	$Ability2.pressed.connect(_on_ability2_pressed)
	$Ability3.pressed.connect(_on_ability3_pressed)

func _GetAbilities() -> void: 
	
	Globals.lossCount  += 1
	
	print(randomInt)

	randomInt.shuffle()
	
	index1 = randomInt.pop_front()
	index2 = randomInt.pop_front()
	index3 = randomInt.pop_front()
	
	var ability1 = abilities[index1]
	var ability2 = abilities[index2]
	var ability3 = abilities[index3]
	
	$Ability1/AbilityName1.text = ability1.name
	$Ability2/AbilityName2.text = ability2.name
	$Ability3/AbilityName3.text = ability3.name
	
	$Ability1/Description1.text = ability1.description
	$Ability2/Description2.text = ability2.description
	$Ability3/Description3.text = ability3.description
	
	$Ability1/TextureRect.texture = ability1.icon
	$Ability2/TextureRect.texture = ability2.icon
	$Ability3/TextureRect.texture = ability3.icon
	
func _on_ability1_pressed():
	#Get value from canvas or whatever pass in value
	
	randomInt.push_front(index2)
	randomInt.push_front(index3)
	$LossCountBar.value = Globals.lossCount
	ApplyAbility($Ability1/AbilityName1.text) 
	ReturnToGame()
	
func _on_ability2_pressed():
	randomInt.push_front(index1)
	randomInt.push_front(index3)
	ApplyAbility($Ability2/AbilityName2.text) 
	$LossCountBar.value = Globals.lossCount
	ReturnToGame()
	
func _on_ability3_pressed():
	randomInt.push_front(index1)
	randomInt.push_front(index2)
	$LossCountBar.value = Globals.lossCount
	ApplyAbility($Ability3/AbilityName3.text)
	ReturnToGame()
	
func ApplyAbility(ability_name: String):
	if ability_name == "Bite":
		Globals.biteUnlocked = true
		print("bite unlocked")
	elif ability_name == "Screech":
		Globals.screechUnlocked = true
		print("screech unlocked")
	elif ability_name == "Beat Chest":
		Globals.beatUnlocked = true
		print("beat unlocked")
	elif ability_name == "Fur":
		Globals.furUnlocked = true
		print("fur unlocked")
	elif ability_name == "Muscles":
		Globals.muscleUnlocked = true
		print("muscle unlocked")
	elif ability_name == "Tail":
		Globals.tailUnlocked = true
		print("tail unlocked")
	# Might want to put somethere here to show the bar go up instead of insta going to next scene
	print("Selected ability: ", ability_name)
	
func ReturnToGame():
	Root.ins.ChangeScene(Root.Scene.GAME)
