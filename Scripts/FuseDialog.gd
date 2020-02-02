extends WindowDialog


onready var fuse1a = $ComponentSelectorNinePatch/Fuse1A
onready var fuse5a = $ComponentSelectorNinePatch/Fuse5A


func _on_Fuse1A_button_down():
	fuse1a.get_node("RichTextLabel").add_color_override("default_color", Globals.black)
	fuse5a.get_node("RichTextLabel").add_color_override("default_color", Globals.white)


func _on_Fuse5A_button_down():
	fuse1a.get_node("RichTextLabel").add_color_override("default_color", Globals.white)
	fuse5a.get_node("RichTextLabel").add_color_override("default_color", Globals.black)
