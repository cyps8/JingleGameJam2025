extends ProgressBar

func _ready():
    var monkeometerTween: Tween = create_tween()
    monkeometerTween.tween_property(self, "value", 1.0, 2.5).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT)