extends WindowDialog

onready var _10k = get_node("ComponentSelectorNinePatch/10kResistorButton")
onready var _1k = get_node("ComponentSelectorNinePatch/1kResistorButton2")
onready var _500 = get_node("ComponentSelectorNinePatch/500ResistorButton3")


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_10kResistorButton_button_down():
	print("Resistor 10k clicked")
	_10k.get_node("RichTextLabel").add_color_override("default_color", Globals.black)
	_1k.get_node("RichTextLabel").add_color_override("default_color", Globals.white)
	_500.get_node("RichTextLabel").add_color_override("default_color", Globals.white)


func _on_1kResistorButton2_button_down():
	_10k.get_node("RichTextLabel").add_color_override("default_color", Globals.white)
	_1k.get_node("RichTextLabel").add_color_override("default_color", Globals.black)
	_500.get_node("RichTextLabel").add_color_override("default_color", Globals.white)


func _on_500ResistorButton3_button_down():
	_10k.get_node("RichTextLabel").add_color_override("default_color", Globals.white)
	_1k.get_node("RichTextLabel").add_color_override("default_color", Globals.white)
	_500.get_node("RichTextLabel").add_color_override("default_color", Globals.black)
