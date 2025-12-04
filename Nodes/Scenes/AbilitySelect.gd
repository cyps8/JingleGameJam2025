extends CanvasLayer

func _ready():
	$Ability1.pressed.connect(_on_ability1_pressed)
	$Ability2.pressed.connect(_on_ability2_pressed)
	$Ability3.pressed.connect(_on_ability3_pressed)



func _on_ability1_pressed():
	ApplyAbility("Ability1") #PLACEHOLDER FOR NOW
	ReturnToGame()
	
func _on_ability2_pressed():
	ApplyAbility("Ability2") #PLACEHOLDER FOR NOW
	ReturnToGame()
	
func _on_ability3_pressed():
	ApplyAbility("Ability2") #PLACEHOLDER FOR NOW
	ReturnToGame()
	
func ApplyAbility(ability_name: String):
	print("Selected ability: ", ability_name)
	
func ReturnToGame():
	Root.ins.ChangeScene(Root.Scene.GAME)
