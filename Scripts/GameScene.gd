extends Node2D

var last_pressed_component

var components = []
var component_types = []
var component_nodes = []
var blown_components = []
var replaced_components = []
var replaced_components_types = []
var solution_component_types = []
var selected_component = -1
var selected_resistor_value = -1
var selected_cpu = -1
var selected_cmos = -1
var selected_regulator = -1
var selected_fuse = -1
var cpu_blown = false
var width = 100
var height = 90
var comp_width = 85
var comp_height = 75
var cpu_placed = false
var cmos_placed = false
var wrong_cpu = false
var wrong_cmos = false
var last_timer = ""

var box_hider_timer

onready var ok_resistor_sprite = preload("res://Scenes/ok_resistor.tscn")
onready var blown_resistor_sprite = preload("res://Scenes/blown_resistor.tscn")
onready var ok_fuse_sprite = preload("res://Scenes/ok_fuse.tscn")
onready var blown_fuse_sprite = preload("res://Scenes/blown_fuse.tscn")
onready var ok_regulator_sprite = preload("res://Scenes/ok_regulator.tscn")
onready var blown_regulator_sprite = preload("res://Scenes/blown_regulator.tscn")
onready var cpu_sprite = preload("res://Scenes/cpu.tscn")
onready var cmos_sprite = preload("res://Scenes/cmos.tscn")
onready var resistor_dialog = $CanvasLayer/ResistorDialog
onready var cpu_dialog = $CanvasLayer/CPUDialog
onready var cmos_dialog = $CanvasLayer/CMOSDialog
onready var fuse_dialog = $CanvasLayer/FuseDialog
onready var regulator_dialog = $CanvasLayer/RegulatorDialog
onready var canvas_script = $CanvasLayer

onready var component_grid = $CanvasLayer/RobotComponents/GridContainer

enum COMPONENT {
	OK_RESISTOR, BLOWN_RESISTOR, OK_FUSE, BLOWN_FUSE, OK_REGULATOR, 
	BLOWN_REGULATOR, CPU, CMOS
}

enum RESISTOR_VALUE {
	R10K, R1K, R500
}

enum CPU {
	AVR, STM32
}

enum CMOS {
	AVRAlpha, STM32_2, PIC_2, AVRBeta
}

enum REGULATOR {
	_3_3V, _5V
}

enum FUSE {
	_1A, _5A
}

# Called when the node enters the scene tree for the first time.

func init_arrays():
	components.clear()
	component_types.clear()
	component_nodes.clear()
	replaced_components.clear()
	replaced_components_types.clear()
	blown_components.clear()
	solution_component_types.clear()
	for i in range(0, 17):
		components.append(-1)
		component_types.append(-1)
		component_nodes.append(-1)
		replaced_components.append(-1)
		replaced_components_types.append(-1)
		blown_components.append(-1)
		solution_component_types.append(-1)

func _ready():
	box_hider_timer = Timer.new()
	box_hider_timer.set_one_shot(true)
	box_hider_timer.set_wait_time(1)
	add_child(box_hider_timer)
	init_arrays()
	populate_components()
	
func get_sprite(component):
	match component:
		COMPONENT.OK_RESISTOR:
			return ok_resistor_sprite
		COMPONENT.BLOWN_RESISTOR:
			return blown_resistor_sprite
		COMPONENT.OK_FUSE:
			return ok_fuse_sprite
		COMPONENT.BLOWN_FUSE:
			return blown_fuse_sprite
		COMPONENT.OK_REGULATOR:
			return ok_regulator_sprite
		COMPONENT.BLOWN_REGULATOR:
			return blown_regulator_sprite
		COMPONENT.CPU:
			return cpu_sprite
		COMPONENT.CMOS:
			return cmos_sprite
			
func get_dims(component):
	match component:
		COMPONENT.OK_RESISTOR:
			return Vector2(256, 118)
		COMPONENT.BLOWN_RESISTOR:
			return Vector2(291, 133)
		COMPONENT.CPU:
			return Vector2(360, 362)
		COMPONENT.OK_FUSE:
			return Vector2(203, 565)
		COMPONENT.BLOWN_FUSE:
			return Vector2(218, 518)
		COMPONENT.OK_REGULATOR:
			return Vector2(152, 288)
		COMPONENT.BLOWN_REGULATOR:
			return Vector2(156, 288)
		COMPONENT.CMOS:
			return Vector2(364, 338)
			
func swap_component(old, new_type, subtype):
	var old_id = -1
	var new_id = -1
	
	# Find old and new IDs
	for i in range(0, 16):
		var node = component_nodes[i]
		var id = -1
		if typeof(node) == TYPE_OBJECT:
			id = node.id
			if old.id == id:
				old_id = id
	
	component_grid.remove_child(component_nodes[old_id])
	component_nodes[old_id].queue_free()
	#component_nodes.remove(old_id)
	
	#components[old_id] = new_type
	
	var x = (old_id % 4) * width
	var y = floor(old_id / 4) * height
	
	var new_sprite = get_sprite(new_type).instance()
	new_sprite.id = old_id
	var dims = get_dims(new_type)
	var comp_scale_x = (comp_width / dims.x)
	var comp_scale_y = (comp_height / dims.y)
	var comp_scale = comp_scale_x
	if comp_scale_x > comp_scale_y:
		comp_scale = comp_scale_y
	new_sprite.position.x = x
	new_sprite.position.y = y
	new_sprite.scale.x = comp_scale
	new_sprite.scale.y = comp_scale
	component_nodes[old_id] = new_sprite
	
	new_sprite.get_node("TextureButton").connect("button_down", self, "_comp_btn_down", [old_id, new_type])
	component_grid.add_child(new_sprite)
	
	if new_type == COMPONENT.OK_RESISTOR:
		match subtype:
			RESISTOR_VALUE.R10K:
				component_nodes[old_id].get_node("RichTextLabel").text = "10K ohm"
			RESISTOR_VALUE.R1K:
				component_nodes[old_id].get_node("RichTextLabel").text = "1K ohm"
			RESISTOR_VALUE.R500:
				component_nodes[old_id].get_node("RichTextLabel").text = "500 ohm"
	elif new_type == COMPONENT.OK_REGULATOR:
		match subtype:
			REGULATOR._3_3V:
				component_nodes[old_id].get_node("RichTextLabel").text = "3.3V"
				pass
			REGULATOR._5V:
				component_nodes[old_id].get_node("RichTextLabel").text = "5V"
				pass
	elif new_type ==  COMPONENT.OK_FUSE:
		match subtype:
			FUSE._1A:
				component_nodes[old_id].get_node("RichTextLabel").text = "1A"
				pass
			FUSE._5A:
				component_nodes[old_id].get_node("RichTextLabel").text = "5A"
				pass
	elif new_type == COMPONENT.CPU:
		match subtype:
			CPU.AVR:
				component_nodes[old_id].get_node("RichTextLabel").text = "AVR"
			CPU.STM32:
				component_nodes[old_id].get_node("RichTextLabel").text = "STM32"
	elif new_type == COMPONENT.CMOS:
		match subtype:
			CMOS.AVRAlpha:
				component_nodes[old_id].get_node("RichTextLabel").text = "AVR Alpha"
			CMOS.AVRBeta:
				component_nodes[old_id].get_node("RichTextLabel").text = "AVR Beta"
			CMOS.PIC_2:
				component_nodes[old_id].get_node("RichTextLabel").text = "PIC 2"
			CMOS.STM32_2:
				component_nodes[old_id].get_node("RichTextLabel").text = "STM32 2"

# When a component on the board is clicked	
func _comp_btn_down(number, component):
	print("A component was pressed! " + str(number) + ", " + str(component))
	match component:
		COMPONENT.BLOWN_FUSE:
			if selected_component == COMPONENT.OK_FUSE:
				if selected_fuse > -1:
					replaced_components[number] = COMPONENT.OK_FUSE
					replaced_components_types[number] = selected_fuse
					swap_component(component_nodes[number], COMPONENT.OK_FUSE, selected_fuse)
				else:
					print("Invalid fuse id")
			else:
				print("Not a fuse selected")
		COMPONENT.BLOWN_REGULATOR:
			if selected_component == COMPONENT.OK_REGULATOR:
				if selected_regulator > -1:
					replaced_components[number] = COMPONENT.OK_REGULATOR
					swap_component(component_nodes[number], COMPONENT.OK_REGULATOR, selected_regulator)
				else:
					print("Invalid regulator selected.")
			else:
				print("Not a regulator selected.")
		COMPONENT.BLOWN_RESISTOR:
			if selected_component == COMPONENT.OK_RESISTOR:
				if selected_resistor_value > -1:
					replaced_components[number] = COMPONENT.OK_RESISTOR
					replaced_components_types[number] = selected_resistor_value
					swap_component(component_nodes[number], COMPONENT.OK_RESISTOR, selected_resistor_value)
		COMPONENT.CPU:
			if wrong_cpu:
				if selected_component == COMPONENT.CPU:
					if selected_cpu > -1:
						replaced_components[number] = COMPONENT.CPU
						replaced_components_types[number] = selected_cpu
						swap_component(component_nodes[number], COMPONENT.CPU, selected_cpu)
		COMPONENT.CMOS:
			if wrong_cmos:
				if selected_component == COMPONENT.CMOS:
					if selected_cmos > -1:
						replaced_components[number] = COMPONENT.CMOS
						replaced_components_types[number] = selected_cmos
						print("REplaced CMOS id: " + str(replaced_components_types[number]))
						swap_component(component_nodes[number], COMPONENT.CMOS, selected_cmos)
		COMPONENT.OK_RESISTOR:
			if blown_components[number] == COMPONENT.BLOWN_RESISTOR:
				if selected_component == COMPONENT.OK_RESISTOR:
					if selected_resistor_value > -1:
						replaced_components[number] = COMPONENT.OK_RESISTOR
						replaced_components_types[number] = selected_resistor_value
						swap_component(component_nodes[number], COMPONENT.OK_RESISTOR, selected_resistor_value)
		COMPONENT.OK_FUSE:
			if blown_components[number] == COMPONENT.BLOWN_FUSE:
				if selected_component == COMPONENT.OK_FUSE:
					if selected_fuse > -1:
						replaced_components[number] = COMPONENT.OK_FUSE
						swap_component(component_nodes[number], COMPONENT.OK_FUSE, selected_fuse)
		COMPONENT.OK_REGULATOR:
			if blown_components[number] == COMPONENT.BLOWN_REGULATOR:
				if selected_component == COMPONENT.OK_REGULATOR:
					if selected_regulator > -1:
						replaced_components[number] = COMPONENT.OK_REGULATOR
						swap_component(component_nodes[number], COMPONENT.OK_REGULATOR, selected_regulator)

func get_new_component(cpu, cmos):
	randomize()
	var new_component = (randi() % 8)
	if cmos && new_component == COMPONENT.CMOS:
		new_component = get_new_component(cpu, cmos)
	elif cpu && new_component == COMPONENT.CPU:
		new_component = get_new_component(cpu, cmos)

	return new_component
	
func set_cmos_str(cmos, string):
	component_grid.get_node(cmos).text = string
	
func populate_components():
	var x = 0
	var y = 10
	
	if randi() % 2 == 1:
		cpu_blown = true
	if randi() % 2 == 1:
		wrong_cpu = 1
		print("Wrong CPU")
	if randi() % 2 == 1 and not wrong_cpu:
		wrong_cmos = 1
		print("Wrong CMOS")
	for i in range(0,16):
		randomize()
		var shown = (randi() % 10) > 3
		if shown:
			var new_component = get_new_component(cpu_placed, cmos_placed)
			if new_component == COMPONENT.CPU:
				new_component = get_new_component(true, cmos_placed)					
			elif new_component == COMPONENT.CMOS:
				cmos_placed = true
			#print("New component: " + str(new_component) + " at index " + str(i))
			components[i] = new_component
			var new_sprite = get_sprite(new_component).instance()
			new_sprite.id = i
			var dims = get_dims(new_component)
			var comp_scale_x = (comp_width / dims.x)
			var comp_scale_y = (comp_height / dims.y)
			var comp_scale = comp_scale_x
			if comp_scale_x > comp_scale_y:
				comp_scale = comp_scale_y
			new_sprite.position.x = x
			new_sprite.position.y = y
			new_sprite.scale.x = comp_scale
			new_sprite.scale.y = comp_scale
			component_nodes[i] = new_sprite
			
			new_sprite.get_node("TextureButton").connect("button_down", self, "_comp_btn_down", [i, new_component])
			component_grid.add_child(new_sprite)
			
			# Randomise fuse type
			if new_component == COMPONENT.BLOWN_FUSE:
				component_types[i] = randi() % 2
				blown_components[i] = COMPONENT.BLOWN_FUSE
			# Randomise resistor type
			if new_component == COMPONENT.BLOWN_RESISTOR:
				component_types[i] = randi() % 3
				blown_components[i] = COMPONENT.BLOWN_RESISTOR
				var solution_resistor = randi() % 3
				print("Solution " + str(i) + " resistor: " + str(solution_resistor))
				solution_component_types[i] = solution_resistor
			# Randomise regulator type
			if new_component == COMPONENT.BLOWN_REGULATOR:
				component_types[i] = randi() % 2
				blown_components[i] = COMPONENT.BLOWN_REGULATOR
			if new_component == COMPONENT.CPU:
				component_types[i] = randi() % 2
				if component_types[i] == CPU.AVR:
					new_sprite.get_node("RichTextLabel").text = "AVR"
				elif component_types[i] == CPU.STM32:
					new_sprite.get_node("RichTextLabel").text = "STM32"
		
		x += width
		if (i+1) % 4 == 0 && i != 0:
			y += height
			x = 0
		#print("Component nodes length: " + str(len(component_nodes)))
			
	if not cpu_placed:
		var cpu_place = randi() % 16
		
		var new_component = COMPONENT.CPU
		components[cpu_place] = new_component
		
		# Get component with id of cpu_place and remove
		for i in range(0, 16):
			#print("Getting node at index: " + str(i))
			if typeof(component_nodes[i]) == TYPE_OBJECT:
				#print(str(component_nodes[i]))
				var id = component_nodes[i].id
				#print("Component id: " + str(id))
				if id == cpu_place:
					blown_components[i] = -1
					#print("Removing node at id: " +str(id))
					component_grid.remove_child(component_nodes[i])
					component_nodes[i].queue_free()
					#component_nodes.remove(i)
			elif typeof(component_nodes[i]) == TYPE_INT:
				if i == cpu_place:
					print("Inserting CPU in empty space")
					
		cpu_placed = true
				
		x = (cpu_place % 4) * width
		y = floor(cpu_place / 4) * height
		
		var new_sprite = get_sprite(new_component).instance()
		var dims = get_dims(new_component)
		var comp_scale_x = (comp_width / dims.x)
		var comp_scale_y = (comp_height / dims.y)
		var comp_scale = comp_scale_x
		if comp_scale_x > comp_scale_y:
			comp_scale = comp_scale_y
		new_sprite.position.x = x
		new_sprite.position.y = y
		new_sprite.scale.x = comp_scale
		new_sprite.scale.y = comp_scale
		new_sprite.id = cpu_place
		
		component_nodes[cpu_place] = new_sprite
		new_sprite.get_node("TextureButton").connect("button_down", self, "_comp_btn_down", [cpu_place, new_component])
		component_grid.add_child(new_sprite)
		
		
		component_types[cpu_place] = randi() % 2
		
		if component_types[cpu_place] == CPU.AVR:
			new_sprite.get_node("RichTextLabel").text = "AVR"
		elif component_types[cpu_place] == CPU.STM32:
			new_sprite.get_node("RichTextLabel").text = "STM32"
			
		if wrong_cpu:
			if component_types[cpu_place] == CPU.AVR:
				solution_component_types[cpu_place] = CPU.STM32
			elif component_types[cpu_place] == CPU.STM32:
				solution_component_types[cpu_place] = CPU.AVR
		
	# Get CPU type to determine CMOS type
	var cpu_type = -1
	var cmos_id = -1
	var cpu_id = -1
	for i in range(0, 16):
		if components[i] == COMPONENT.CPU:
			cpu_type = component_types[i]
			cpu_id = i
		if components[i] == COMPONENT.CMOS:
			cmos_id = i
	
	# Set wrong cpu if suitable
	if (cpu_placed and not cmos_placed and wrong_cpu) or (cpu_placed and wrong_cpu and cmos_placed and not wrong_cmos):
		component_types[cpu_id] = CPU.STM32
		
	if cmos_placed:
		if typeof(component_nodes[cmos_id]) == TYPE_OBJECT:
			# Set wrong cmos if cpu not wrong
			if not wrong_cpu and wrong_cmos:
				if cpu_type == CPU.AVR:
					var type = randi() % 2
					if type == 0:
						component_types[cmos_id] = CMOS.PIC_2
						component_nodes[cmos_id].get_node("RichTextLabel").text = "PIC 2"
					else:
						component_types[cmos_id] = CMOS.STM32_2
						component_nodes[cmos_id].get_node("RichTextLabel").text = "STM32 2"
						
					type = randi() % 2
					if type == 0:
						solution_component_types[cmos_id] = CMOS.AVRAlpha
					else:
						solution_component_types[cmos_id] = CMOS.AVRBeta
					
				elif cpu_type == CPU.STM32:
					var type = randi() % 2
					if type == 0:
						component_types[cmos_id] = CMOS.AVRAlpha
						component_nodes[cmos_id].get_node("RichTextLabel").text = "AVR Alpha"
					else:
						component_types[cmos_id] = CMOS.AVRBeta
						component_nodes[cmos_id].get_node("RichTextLabel").text = "AVR Beta"
					solution_component_types[cmos_id] = CMOS.STM32_2
				print("Solution to cmos: " + str(solution_component_types[cmos_id]))
					
			# Set correct CMOS if cpu wrong and cmos not wrong
			else:
				if not wrong_cpu and not wrong_cmos:
					if cpu_type == CPU.AVR:
						var type = randi() % 2
						if type == 0:
							component_types[cmos_id] = CMOS.AVRAlpha
							component_nodes[cmos_id].get_node("RichTextLabel").text = "AVR Alpha"
						else:
							component_types[cmos_id] = CMOS.AVRBeta
							component_nodes[cmos_id].get_node("RichTextLabel").text = "AVR Beta"
					elif cpu_type == CPU.STM32:
						var type = randi() % 2
						if type == 0:
							component_types[cmos_id] = CMOS.PIC_2
							component_nodes[cmos_id].get_node("RichTextLabel").text = "PIC 2"
						else:
							component_types[cmos_id] = CMOS.STM32_2
							component_nodes[cmos_id].get_node("RichTextLabel").text = "STM32 2"
				
				# Wrong CPU, right CMOS
				elif wrong_cpu:
					if cpu_type == CPU.AVR:
						var type = randi() % 2
						if type == 0:
							component_types[cmos_id] = CMOS.PIC_2
							component_nodes[cmos_id].get_node("RichTextLabel").text = "PIC 2"
						else:
							component_types[cmos_id] = CMOS.STM32_2
							component_nodes[cmos_id].get_node("RichTextLabel").text = "STM32 2"
					elif cpu_type == CPU.STM32:
						var type = randi() % 2
						if type == 0:
							component_types[cmos_id] = CMOS.AVRAlpha
							component_nodes[cmos_id].get_node("RichTextLabel").text = "AVR Alpha"
						else:
							component_types[cmos_id] = CMOS.AVRBeta
							component_nodes[cmos_id].get_node("RichTextLabel").text = "AVR Beta"
		else:
			print("ERROR! component_nodes[" + str(cmos_id) + "] is invalid!")
func start_timer(function_name):
	box_hider_timer.disconnect("timeout", self, last_timer)
	box_hider_timer.connect("timeout", self, function_name)
	box_hider_timer.start()
	last_timer = function_name

func hide_resistor_box():
	resistor_dialog.hide()
	
func hide_cpu_box():
	cpu_dialog.hide()
	
func hide_cmos_box():
	cmos_dialog.hide()
	
func hide_regulator_box():
	regulator_dialog.hide()
	
func hide_fuse_box():
	fuse_dialog.hide()

func _on_10kResistorButton_button_down():
	selected_resistor_value = RESISTOR_VALUE.R10K
	selected_component = COMPONENT.OK_RESISTOR
	start_timer("hide_resistor_box")

func _on_1kResistorButton2_button_down():
	selected_resistor_value = RESISTOR_VALUE.R1K
	selected_component = COMPONENT.OK_RESISTOR
	start_timer("hide_resistor_box")

func _on_500ResistorButton3_button_down():
	selected_resistor_value = RESISTOR_VALUE.R500
	selected_component = COMPONENT.OK_RESISTOR
	start_timer("hide_resistor_box")

func _on_CPUButton1_button_down():
	selected_cpu = CPU.AVR
	selected_component = COMPONENT.CPU
	start_timer("hide_cpu_box")

func _on_CPUButton2_button_down():
	selected_cpu = CPU.STM32
	selected_component = COMPONENT.CPU
	start_timer("hide_cpu_box")

func _on_CMOS1_button_down():
	selected_cmos = CMOS.AVRAlpha
	selected_component = COMPONENT.CMOS
	start_timer("hide_cmos_box")

func _on_CMOS2_button_down():
	selected_cmos = CMOS.STM32_2
	selected_component = COMPONENT.CMOS
	start_timer("hide_cmos_box")

func _on_CMOS3_button_down():
	selected_cmos = CMOS.PIC_2
	selected_component = COMPONENT.CMOS
	start_timer("hide_cmos_box")

func _on_CMOS4_button_down():
	selected_cmos = CMOS.AVRBeta
	selected_component = COMPONENT.CMOS
	start_timer("hide_cmos_box")

func _on_Regulator33_button_down():
	selected_regulator = REGULATOR._3_3V
	selected_component = COMPONENT.OK_REGULATOR
	start_timer("hide_regulator_box")

func _on_Regulator5_button_down():
	selected_regulator = REGULATOR._5V
	selected_component = COMPONENT.OK_REGULATOR
	start_timer("hide_regulator_box")

func _on_Fuse1A_button_down():
	selected_fuse = FUSE._1A
	selected_component = COMPONENT.OK_FUSE
	start_timer("hide_fuse_box")

func _on_Fuse5A_button_down():
	selected_fuse = FUSE._5A
	selected_component = COMPONENT.OK_FUSE
	start_timer("hide_fuse_box")

func play_hello():
	$CanvasLayer/RobotSpeechHello.play()
	
func play_confused():
	$CanvasLayer/RobotSpeechConfused.play()

func overpower():
	$CanvasLayer.set_power_level(0)

func check_circuit():
	
	var error_code = "00"
	
	# Check fuses
	var fuses_ok = true
	for i in range(0, 16):
		if blown_components[i] == COMPONENT.BLOWN_FUSE:
			if not replaced_components[i] == COMPONENT.OK_FUSE:
				fuses_ok = false
				print("A fuse is not good")
	
	# Check regulators
	var regulator_ok = true
	for i in range(0, 16):
		if blown_components[i] == COMPONENT.BLOWN_REGULATOR:
			if not replaced_components[i] == COMPONENT.OK_REGULATOR:
				regulator_ok = false
				print("A regulator is not good")
				
	# check resistors
	var total_resistance = 0
	var total_solution_resistance = 0
	var resistors_ok = true
	for i in range(0, 16):
		if blown_components[i] == COMPONENT.BLOWN_RESISTOR:
			if not replaced_components[i] == COMPONENT.OK_RESISTOR:
				resistors_ok = false
				print("A resistor is not good")
			else:
				if solution_component_types[i] == RESISTOR_VALUE.R10K:
					print("Adding 10k")
					total_solution_resistance += 10000
				elif solution_component_types[i] == RESISTOR_VALUE.R1K:
					print("Adding 1k")
					total_solution_resistance += 1000
				elif solution_component_types[i] == RESISTOR_VALUE.R500:
					print("Adding 500h")
					total_solution_resistance += 500
				if replaced_components_types[i] > -1:
					if replaced_components_types[i] == RESISTOR_VALUE.R10K:
						total_resistance += 10000
					elif replaced_components_types[i] == RESISTOR_VALUE.R1K:
						total_resistance += 1000
					elif replaced_components_types[i] == RESISTOR_VALUE.R500:
						total_resistance += 500
					else:
						resistors_ok = false
						print("A resistor does not have a correct value: " + str(replaced_components_types[i]))
				else:
					resistors_ok = false
					print("A resistor does not have a value")
	print("Solution resistance: " + str(total_solution_resistance) + " selected resistance: " + str(total_resistance))
	if total_resistance < total_solution_resistance:
		$CanvasLayer.set_power_level(6)
		start_timer("overpower")
		resistors_ok = false
	elif total_resistance > total_solution_resistance:
		$CanvasLayer.set_power_level(1)
		resistors_ok = false
	elif total_resistance == total_solution_resistance:
		resistors_ok = true
					
	if fuses_ok and regulator_ok and resistors_ok:
		$CanvasLayer.set_power_level(6)
		
		# Check CMOS
		var correct_cmos = false
		for i in range (0, 16):
			if components[i] == COMPONENT.CMOS:
				print("replaced component type for i" + str(i) + ": " + str(replaced_components_types[i]))
				print("solution for i: " + str(solution_component_types[i]))
				if replaced_components_types[i] > -1:
					if replaced_components_types[i] == solution_component_types[i]:
						correct_cmos = true
		
		# Check CPU
		var correct_cpu = false
		for i in range(0, 16):
			if components[i] == COMPONENT.CPU:
				if replaced_components_types[i] > -1:
					if replaced_components_types[i] == solution_component_types[i]:
						correct_cpu = true
		
		var system_ok = true
		if correct_cmos:
			wrong_cmos = false
			print("CMOS fixed")
		if correct_cpu:
			print("CPU fixed")
			wrong_cpu = false

		if wrong_cpu:
			error_code = "01"
			system_ok = false
			start_timer("play_confused")
			$CanvasLayer.set_robot_frame(1)
			print("Incorrect CPU")
		if wrong_cmos and cmos_placed:
			error_code = "05"
			system_ok = false
			start_timer("play_confused")
			$CanvasLayer.set_robot_frame(1)
			print("Incorrect CMOS")
		if system_ok:
			error_code = "FF"
			$MusicPlayer.stop()
			$CanvasLayer.set_robot_frame(2)
			start_timer("play_hello")
		
		$CanvasLayer.set_error_code(error_code)
	else:
		$CanvasLayer/RobotCrunch.play()

func _on_PowerButton_button_down():
	check_circuit()


func clear_components():
	for i in range(0, 16):
		if components[i] > -1:
			component_grid.remove_child(component_nodes[i])

func reset_level():
	cpu_placed = false
	cmos_placed = false
	wrong_cpu = false
	wrong_cmos = false
	$CanvasLayer.set_robot_frame(0)
	$CanvasLayer.set_error_code("00")
	$CanvasLayer.set_power_level(0)
	clear_components()
	init_arrays()
	populate_components()
	$MusicPlayer.play()

func _on_ResetButton_button_down():
	reset_level()
