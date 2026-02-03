@icon("AudioStreamPlayer.svg")
## A ModTracker Manager Node
@tool
class_name ModTracker
extends Node

## The player node for the ModTracker
@onready var player:AudioStreamPlayer

## The currently selected module file for the player
@onready var selected_module:AudioStreamMPT

## The module file resources
@export var modules:Array[AudioStreamMPT]

## Select a module from the modules array and load it into the player
func select_module(index:int) -> void:
	selected_module = modules[index]
	player.stream = selected_module

## Plays a pattern
func play_pattern(pattern:int, row:int = 0):
	var playback = player.get_stream_playback() if player.has_stream_playback() else get_playback_if_null()
	playback.set_current_order(pattern)
	playback.set_current_row(row)

func init_player() -> AudioStreamPlayer:
	if !player:
		player = AudioStreamPlayer.new()
	return player

func get_playback_if_null():		
	player.play()
	return player.get_stream_playback()
