extends Sprite3D

func _ready():

    var cheerSpeed: float = (randf() * 0.1) + 0.15
    var cheerTween: Tween = create_tween().set_loops()
    cheerTween.tween_property(self, "position:y", position.y + 0.1, cheerSpeed).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
    cheerTween.tween_property(self, "position:y", position.y, cheerSpeed).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)