extends Node2D

# Level node.
var level

# Initialization
func _ready():
	level = get_node("Level")
	global.set_editor(true)
	
	global.set_zoom(0.25)
	level.set_scale(Vector2(0.25, 0.25))

# Save button pressed.
func _on_SaveButton_pressed():
	var name = "user://" + get_node("NameEdit").get_text() + ".lvl"
	if !level.check_solved():
		print("The level has to be solved first!")
	else:
		level.save_level(name)

# Load button pressed.
func _on_LoadButton_pressed():
	var name = "user://" + get_node("NameEdit").get_text() + ".lvl"
	level.load_level(name)
	get_node("DescriptionEdit").set_text(get_node("Level/DescriptionLabel").get_text())

# Create button pressed.
func _on_SpawnPieceButton_pressed():
	var type = get_node("SpawnPieceSelection").get_selected() + 1
	level.add_piece(type)

# Resize button pressed.
func _on_ResizeButton_pressed():
	var x = get_node("BoardSizeXBox").get_value()
	var y = get_node("BoardSizeYBox").get_value()
	
	level.set_board_size(Vector2(x, y))

# Check Solution button pressed.
func _on_Button_pressed():
	if level.check_solved():
		print("Solved!")
	else:
		print("Not solved!")

# Description text edited.
func _on_DescriptionEdit_text_changed():
	var desc_edit = get_node("DescriptionEdit")
	if desc_edit.get_text().length() == 0:
		level.set_description(" ")
	else:
		level.set_description(desc_edit.get_text())

# Clear button pressed.
func _on_ClearButton_pressed():
	level.clear_pieces()
