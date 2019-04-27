extends ScrollContainer

func _ready():
    connect("minimum_size_changed", self, "_on_minimum_size_changed")
    connect("resized", self, "_resized")

func _on_minimum_size_changed():
    print("minimum_size_changed: " + str(get_minimum_size()))

func _resized():
    print("resized: " + str(rect_size))