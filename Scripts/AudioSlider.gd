extends HSlider


@export var busName: String = "Master"

var holdR: bool = false
var holdL: bool = false
var holdCD: float = 0

func _ready():
	if !OS.has_feature("editor"):
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index(busName), linear_to_db(0.8))
	value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index(busName)))
	value_changed.connect(Callable(OnChanged))

	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

func OnChanged(_value: float):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(busName), linear_to_db(_value))

func _process(_dt):
	if !has_focus():
		return

	if Input.is_action_just_pressed("ui_left") && !holdR:
		holdL = true
		holdCD = 0.5
	elif Input.is_action_just_pressed("ui_right") && !holdL:
		holdR = true
		holdCD = 0.5
	else:
		holdCD -= _dt

	if !holdL && !holdR:
		return

	if holdL && Input.is_action_just_released("ui_left"):
		holdL = false

	if holdR && Input.is_action_just_released("ui_right"):
		holdR = false

	if holdCD < 0:
		holdCD += 0.075
		if holdL:
			value -= 0.05
		elif holdR:
			value += 0.05
