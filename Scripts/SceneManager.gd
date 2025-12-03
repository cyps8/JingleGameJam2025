class_name Root extends Node

static var ins: Root

@export var skipMenu: bool = false

@export var gameScene: PackedScene
@export var menuScene: PackedScene

enum Scene{
	MAINMENU,
	GAME
}

var optionsRef: Options
var optionsOpen: bool = false

var loadingScreenRef: CanvasLayer

var currentSceneNode: Node = null
var currentPackedScene: PackedScene
var currentScene: Scene = Scene.GAME

var loading = false
var loadingDelay: float = 0

func _ready():
	randomize()

	optionsRef = $OptionsMenu
	optionsRef.visible = true
	remove_child(optionsRef)

	loadingScreenRef = $LoadingScreen
	loadingScreenRef.visible = true
	remove_child(loadingScreenRef)

	ins = self
	if !skipMenu:
		ChangeScene(Scene.MAINMENU)
	else:
		ChangeScene(Scene.GAME)

func ChangeScene(newScene: Scene):
	SFXPlayer.ins.KillSounds()
	if currentSceneNode != null:
		currentSceneNode.queue_free()

	if newScene == Scene.MAINMENU:
		currentPackedScene = menuScene
	elif newScene == Scene.GAME:
		currentPackedScene = gameScene

	add_child(loadingScreenRef)

	loadingDelay = 0.0

	var delayTween: Tween = create_tween()
	delayTween.tween_callback(ResourceLoader.load_threaded_request.bind(currentPackedScene.resource_path)).set_delay(0.05)
	
	loading = true

	currentScene = newScene

func OpenOptionsMenu():
	add_child(optionsRef)
	optionsOpen = true

func CloseOptionsMenu():
	remove_child(optionsRef)
	optionsOpen = false

func _process(_delta):
	loadingDelay -= _delta
	if !loading || loadingDelay > 0:
		return
	
	if ResourceLoader.load_threaded_get_status(currentPackedScene.resource_path) == ResourceLoader.THREAD_LOAD_LOADED:
		loading = false
		currentSceneNode = currentPackedScene.instantiate()
		add_child(currentSceneNode)
		if currentScene != Scene.GAME:
			HideLoadingScreen()

func HideLoadingScreen():
	remove_child(loadingScreenRef)
