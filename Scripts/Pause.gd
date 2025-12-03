extends CanvasLayer

func ResumePressed():
	GameManager.ins.TogglePause()

func OptionsPressed():
	Root.ins.OpenOptionsMenu()

func MainMenuPressed():
	GameManager.ins.TogglePause()
	Root.ins.ChangeScene(Root.Scene.MAINMENU)
