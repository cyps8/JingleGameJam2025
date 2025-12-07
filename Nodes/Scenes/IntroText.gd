extends Control

@export var intro_text : String = "You awake in a dark and musty room, captive in shackles and chains. Light pours in through a metal cage to the outside where you can hear the cheering and hollering of a large audience. You suddenly remember that after you failed to please the Banana Republic last year, you were sentenced to trial by combat..."
@export var typing_speed :=0.04 #seconds per character

var index := 0

func _ready():
	$RichTextLabel.text = ""
	typing()

func typing():
	var timer := Timer.new()
	timer.wait_time = typing_speed
	timer.one_shot = false
	add_child(timer)
	timer.start()
	
	timer.timeout.connect(func():
		if index < intro_text.length():
			$RichTextLabel.text += intro_text[index]
			index += 1
		else:
			timer.stop()
			timer.queue_free()
			await get_tree().create_timer(1.0).timeout
			finish_intro())
			
func finish_intro():
	Root.ins.ChangeScene(Root.Scene.GAME)
		
