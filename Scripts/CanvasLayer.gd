extends CanvasLayer

onready var resistor_selector_box = $ResistorDialog/ComponentSelectorNinePatch
onready var cpu_selector_box = $CPUDialog/ComponentSelectorNinePatch
onready var cmos_selector_box = $CMOSDialog/ComponentSelectorNinePatch
onready var regulator_selector_box = $RegulatorDialog/ComponentSelectorNinePatch
onready var fuse_selector_box = $FuseDialog/ComponentSelectorNinePatch
onready var robot_anim = $Diagnostics/RobotAnim
onready var power_on_sfx = $RobotOn
onready var robot_crunch_sfx = $RobotCrunch
onready var robot_say_hello = $RobotSpeechHello
onready var robot_confused_spech = $RobotSpeechConfused
onready var bulb_on = preload("res://Images/bulb-on.png")
onready var bulb_off = preload("res://Images/bulb-off.png")
onready var bulb1 = $Diagnostics/BulbContainer/Bulb1
onready var bulb2 = $Diagnostics/BulbContainer/Bulb2
onready var bulb3 = $Diagnostics/BulbContainer/Bulb3
onready var bulb4 = $Diagnostics/BulbContainer/Bulb4
onready var bulb5 = $Diagnostics/BulbContainer/Bulb5
onready var bulb6 = $Diagnostics/BulbContainer/Bulb6
onready var bulbs = [bulb1, bulb2, bulb3, bulb4, bulb5, bulb6]

var resistor_box_colour = Color("#ffec13")
var cpu_box_colour = Color("#629fe2")
var cmos_box_colour = Color("#4cef46")
var regulator_box_colour = Color("#34e4b7")
var fuse_box_colour = Color("#d13edc")


# Called when the node enters the scene tree for the first time.
func _ready():
	resistor_selector_box.modulate = resistor_box_colour
	cpu_selector_box.modulate = cpu_box_colour
	cmos_selector_box.modulate = cmos_box_colour
	regulator_selector_box.modulate = regulator_box_colour
	fuse_selector_box.modulate = fuse_box_colour
	

func set_robot_frame(frame_id):
	if frame_id == 0 or frame_id == 1 or frame_id == 2:
		robot_anim.frame = frame_id

func set_power_level(level):
	for i in range(0, level):
		bulbs[i].texture = bulb_on
	for i in range(level, 6):
		bulbs[i].texture = bulb_off

func set_error_code(error_code):
	$Diagnostics/Control/ErrorCodeLabel.text = "Error code: " + error_code
	

func _on_ResistorsButton_button_down():
	print("Resistor clicked")
	$ResistorDialog.popup()
	$CPUDialog.hide()
	$CMOSDialog.hide()
	$RegulatorDialog.hide()
	$FuseDialog.hide()

func _on_CPUButton_button_down():
	$CPUDialog.popup()
	$ResistorDialog.hide()
	$CMOSDialog.hide()
	$RegulatorDialog.hide()
	$FuseDialog.hide()

func _on_CMOSButton_button_down():
	$CMOSDialog.popup()
	$ResistorDialog.hide()
	$CPUDialog.hide()
	$RegulatorDialog.hide()
	$FuseDialog.hide()

func _on_RegulatorButton_button_down():
	$RegulatorDialog.popup()
	$ResistorDialog.hide()
	$CPUDialog.hide()
	$CMOSDialog.hide()
	$FuseDialog.hide()

func _on_FuseButton_button_down():
	$FuseDialog.popup()
	$ResistorDialog.hide()
	$CPUDialog.hide()
	$CMOSDialog.hide()
	$RegulatorDialog.hide()

func _on_PowerButton_button_down():
	power_on_sfx.play()
