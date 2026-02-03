@tool
extends Control

signal mute_channel(index:int, toggle:bool)

var index:int
@onready var mute:CheckButton = $Mute
@onready var list:ItemList = $List

func init(index):
	self.index = index

func _ready():
	mute.text = "Channel %s" % [index+1]

func pop_row(current_row, row_length):
	if list.item_count == (row_length-current_row) and list.item_count > 0:
		list.remove_item(0)
	else:
		return
	if list.item_count > 0:
		list.select(0)

func count():
	return list.item_count

func clear():
	list.clear()

func add(data):
	list.add_item(data)

func _on_mute_toggled(toggled_on: bool) -> void:
	mute_channel.emit(index, !toggled_on)
