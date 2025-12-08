extends CanvasLayer

func _ready():
	Globals.lossCount = 0
	Globals.randomInt = [0,1,2,3,4,5]
	Globals.currentOpponent = Enemy.EnemyType.SLOTH
	Globals.biteUnlocked = false
	Globals.screechUnlocked = false
	Globals.beatUnlocked = false
	Globals.furUnlocked = false
	Globals.muscleUnlocked = false
	Globals.tailUnlocked = false

func StartPressed():
	Root.ins.ChangeScene(Root.Scene.INTRO)

func OptionsPressed():
	Root.ins.OpenOptionsMenu()

func QuitPressed():
	get_tree().quit()
