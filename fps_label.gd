# Copyright © 2020 Hugo Locurcio and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.
extends Label


func _process(_delta: float) -> void:
	text = "%d FPS" % Engine.get_frames_per_second()
