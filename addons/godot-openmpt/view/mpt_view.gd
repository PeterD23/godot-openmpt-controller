@tool
extends Control

@onready var module_list = $ActiveWindow/LeftPanel/ModuleList
@onready var metadata_list = $ActiveWindow/LeftPanel/Metadata
@onready var subsong_list = $ActiveWindow/LeftPanel/GridContainer/SubsongContainer/Subsongs
@onready var pattern_list = $ActiveWindow/LeftPanel/GridContainer/PatternContainer/Patterns
@onready var song_title = $ActiveWindow/RightPanel/SongTitle
@onready var playback = $ActiveWindow/RightPanel/Playback
@onready var channel_grid = $ActiveWindow/RightPanel/ChannelGrid

var mod_tracker: ModTracker
var mpt_player: AudioStreamPlayer = AudioStreamPlayer.new()
var modules:Array[AudioStreamMPT]
var selected_module: AudioStreamMPT
var current_order_playing = -1

var channel_scene = preload("./mpt_channel.tscn")
var channel_boxes:Array[Control]

func flip_active(active):
	$ActiveWindow.set_visible(active)
	$InactiveLabel.set_visible(!active)
	
func activate(tracker:ModTracker) -> void:
	mod_tracker = tracker
	modules = mod_tracker.modules
	populate_modules()
	if !mpt_player.is_inside_tree():
		add_child(mpt_player)
	if len(modules) > 0:
		select_song(modules[0])
		flip_active(true)

func select_song(module:AudioStreamMPT):
	selected_module = module
	mpt_player.stream = selected_module
	populate_subsongs()
	populate_sequence()
	populate_metadata()
	build_channels()

func build_channels():
	# Delete existing channels if there are any
	for channel in channel_boxes:
		channel_grid.remove_child(channel)
		channel.queue_free()
	channel_boxes.clear()
	# Instantiate each channel then child them to the channel_grid
	for index in selected_module.get_num_channels():
		var channel = channel_scene.instantiate()
		channel.init(index)
		channel.mute_channel.connect(on_channel_muted)
		channel_grid.add_child(channel)
		channel_boxes.append(channel)

func deactivate():
	flip_active(false)
	if mpt_player.is_inside_tree():
		remove_child(mpt_player)

func populate_modules():
	module_list.clear()
	for module in modules:
		var metadata = module.get_all_metadata()
		module_list.add_item(metadata["title"] if metadata["title"] else module.resource_path.get_file())

func populate_subsongs():
	var sub_songs = selected_module.get_subsong_names()
	subsong_list.clear()
	for index in range(len(sub_songs)):
		subsong_list.add_item("Song %s" % [index])
	subsong_list.select(0)
		
func populate_sequence():
	var order_list = selected_module.get_order_names()
	pattern_list.clear()
	for order in range(len(order_list)):
		pattern_list.add_item("[%s] Pattern %s" % [str("%02d" % order), selected_module.get_order_pattern(order)])

func populate_metadata():
	var metadata = selected_module.get_all_metadata()
	song_title.set_text(metadata["title"] if metadata["title"] else selected_module.resource_path.get_file())
	metadata_list.set_text(
		"Tracker: %s\n" % [metadata["tracker"] or "unknown"] +
		"Module Type: %s (%s)\n" % [metadata["type_long"], metadata["type"]] +
		"Container: %s (%s)" % [metadata["container_long"], metadata["container"]]
	)

func _process(delta: float) -> void:
	if mpt_player == null:
		return
	if mpt_player.has_stream_playback():
		var stream_playback = mpt_player.get_stream_playback()
		var current_pattern = stream_playback.get_current_pattern()
		pattern_list.select(stream_playback.get_current_order())
		populate_current_pattern(stream_playback, current_pattern)
		playback.text = "Tempo: %d Row: %d/%d Order: %d/%d Pattern: %d/%d" % [
			stream_playback.get_current_tempo(),
			stream_playback.get_current_row(), 
			mpt_player.stream.get_pattern_num_rows(current_pattern),
			stream_playback.get_current_order(), 
			mpt_player.stream.get_num_orders(), 
			current_pattern, 
			mpt_player.stream.get_num_patterns()]
	else:
		playback.text = ""
		
func populate_current_pattern(playback, pattern):
	var current_order = playback.get_current_order()
	var current_row = playback.get_current_row()
	var row_length = mpt_player.stream.get_pattern_num_rows(pattern)
	if current_order != current_order_playing:
		clear_channels()
		current_order_playing = current_order 
		for row in range(current_row, row_length):
			add_row_to_list(pattern, row)
	else:
		pop_row_from_channels(current_row, row_length)

func clear_channels():
	for channel in channel_boxes:
		channel.clear()

func pop_row_from_channels(current_row, row_length):
	for channel in channel_boxes:
		channel.pop_row(current_row, row_length)

func add_row_to_list(pattern, row):
	for index in range(len(channel_boxes)):
		var note_data = selected_module.format_pattern_row_channel(pattern, row, index, 0, false).replace(".","-")
		channel_boxes[index].add(note_data)

func _on_play_button_pressed() -> void:
	var selected = subsong_list.get_selected_items()
	if !selected.is_empty():
		print("Playing song %s" % selected)
		mpt_player.play()
		if mpt_player.has_stream_playback():
			var stream_playback: AudioStreamPlaybackMPT = mpt_player.get_stream_playback()
			stream_playback.select_subsong(selected[0])

func _on_patterns_item_clicked(index: int, at_position: Vector2, mouse_button_index: int) -> void:
	if mouse_button_index != MOUSE_BUTTON_LEFT:
		return
	if mpt_player.has_stream_playback():
		var stream_playback = mpt_player.get_stream_playback()
		current_order_playing = -1
		stream_playback.set_current_order(index)

func _on_stop_button_pressed() -> void:
	mpt_player.stop()
	current_order_playing = -1
	clear_channels()

func _on_module_list_item_selected(index: int) -> void:
	select_song(modules[index])

func on_channel_muted(index: int, muted: bool) -> void:
	if mpt_player.has_stream_playback():
		var stream_playback = mpt_player.get_stream_playback()
		stream_playback.set_channel_mute_status(index, muted)
