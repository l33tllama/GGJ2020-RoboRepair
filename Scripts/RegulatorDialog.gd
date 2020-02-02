extends WindowDialog


onready var regulator33 = $ComponentSelectorNinePatch/Regulator33
onready var regulator5 = $ComponentSelectorNinePatch/Regulator5


func _on_Regulator33_button_down():
	regulator33.get_node("RichTextLabel").add_color_override("default_color", Globals.yellow)
	regulator5.get_node("RichTextLabel").add_color_override("default_color", Globals.white)


func _on_Regulator5_button_down():
	regulator33.get_node("RichTextLabel").add_color_override("default_color", Globals.white)
	regulator5.get_node("RichTextLabel").add_color_override("default_color", Globals.yellow)
