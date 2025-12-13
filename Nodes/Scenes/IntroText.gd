extends Control

@export var intro_text : String = "You awake in a dark and musty room, captive in shackles and chains. Light pours in through a metal cage to the outside where you can hear the cheering and hollering of a large audience. You suddenly remember that after you failed to please the Banana Republic last year, you were sentenced to trial by combat..."
@export var typing_speed := 0.04 # seconds per character
@export var sentence_pause := 0.5 # seconds between sentences

var sentences : Array = []
var sentence_index := 0
var char_index := 0

@onready var next_button := $Button
@onready var hard_button := $Button2

func _ready():
	$RichTextLabel.text = ""
	next_button.visible = false
	hard_button.visible = false
	
	# this is probably overcomplicating it 
	var regex = RegEx.new()
	regex.compile(r"[^.!?]+[.!?]")
	var result = regex.search_all(intro_text)
	
	sentences.clear()
	for match in result:
		sentences.append(match.strings[0].strip_edges())
	
	start_typing_sentence()
	next_button.pressed.connect(_on_next_pressed)
	hard_button.pressed.connect(Hard_Mode_Pressed)


func start_typing_sentence():
	char_index = 0
	if sentence_index > 0:
		$RichTextLabel.text += "\n"
	typing()


func typing():
	var timer = Timer.new()
	timer.wait_time = typing_speed
	timer.one_shot = false
	add_child(timer)
	timer.start()

	timer.timeout.connect(func():
		var sentence = sentences[sentence_index]

		if char_index < sentence.length():
			$RichTextLabel.text += sentence[char_index]
			char_index += 1
		else:
			timer.stop()
			timer.queue_free()
			
			sentence_index += 1

			if sentence_index < sentences.size():
				await get_tree().create_timer(sentence_pause).timeout
				start_typing_sentence()
			else:
				await get_tree().create_timer(0.3).timeout
				finish_intro()
	)


func finish_intro():
	next_button.visible = true
	if Globals.hardUnlocked:
		hard_button.visible = true
	
func _on_next_pressed():
	Root.ins.ChangeScene(Root.Scene.GAME)

func Hard_Mode_Pressed():
	Globals.hardMode = true
	_on_next_pressed()