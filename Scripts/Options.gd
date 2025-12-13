class_name Options extends CanvasLayer

func BackPressed():
	Root.ins.CloseOptionsMenu()

func ChristmasToggled(mode: bool):
	Globals.christmasMode = mode