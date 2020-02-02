extends WindowDialog

onready var cpu1 = $ComponentSelectorNinePatch/CPUButton1
onready var cpu2 = $ComponentSelectorNinePatch/CPUButton2



# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_CPUButton1_button_down():
	print("CPU 1 clicked")
	cpu1.get_node("RichTextLabel").add_color_override("default_color", Globals.red)
	cpu2.get_node("RichTextLabel").add_color_override("default_color", Globals.white)


func _on_CPUButton2_button_down():
	print("CPU 2 clicked")
	cpu1.get_node("RichTextLabel").add_color_override("default_color", Globals.white)
	cpu2.get_node("RichTextLabel").add_color_override("default_color", Globals.red)
