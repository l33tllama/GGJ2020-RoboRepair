extends WindowDialog

onready var CMOS1 = $ComponentSelectorNinePatch/CMOS1
onready var CMOS2 = $ComponentSelectorNinePatch/CMOS2
onready var CMOS3 = $ComponentSelectorNinePatch/CMOS3
onready var CMOS4 = $ComponentSelectorNinePatch/CMOS4


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_CMOS1_button_down():
	CMOS1.get_node("RichTextLabel").add_color_override("default_color", Globals.red)
	CMOS2.get_node("RichTextLabel").add_color_override("default_color", Globals.white)
	CMOS3.get_node("RichTextLabel").add_color_override("default_color", Globals.white)
	CMOS4.get_node("RichTextLabel").add_color_override("default_color", Globals.white)


func _on_CMOS2_button_down():
	CMOS1.get_node("RichTextLabel").add_color_override("default_color", Globals.white)
	CMOS2.get_node("RichTextLabel").add_color_override("default_color", Globals.red)
	CMOS3.get_node("RichTextLabel").add_color_override("default_color", Globals.white)
	CMOS4.get_node("RichTextLabel").add_color_override("default_color", Globals.white)


func _on_CMOS3_button_down():
	CMOS1.get_node("RichTextLabel").add_color_override("default_color", Globals.white)
	CMOS2.get_node("RichTextLabel").add_color_override("default_color", Globals.white)
	CMOS3.get_node("RichTextLabel").add_color_override("default_color", Globals.red)
	CMOS4.get_node("RichTextLabel").add_color_override("default_color", Globals.white)


func _on_CMOS4_button_down():
	CMOS1.get_node("RichTextLabel").add_color_override("default_color", Globals.white)
	CMOS2.get_node("RichTextLabel").add_color_override("default_color", Globals.white)
	CMOS3.get_node("RichTextLabel").add_color_override("default_color", Globals.white)
	CMOS4.get_node("RichTextLabel").add_color_override("default_color", Globals.red)
