@tool
extends EditorPlugin

var import_plugin: EditorImportPlugin = null

const MainPanel = preload("res://addons/godot-openmpt/view/mpt_view.tscn")

var main_panel_instance

func _enter_tree() -> void:
	import_plugin = preload("mpt_importer.gd").new()
	add_import_plugin(import_plugin)
	main_panel_instance = MainPanel.instantiate()
	EditorInterface.get_editor_main_screen().add_child(main_panel_instance)
	_make_visible(false)
		
func _has_main_screen():
	return true

func _make_visible(visible):
	if main_panel_instance:
		main_panel_instance.visible = visible
		if visible:
			EditorInterface.set_main_screen_editor("OpenMPT")

func _exit_tree() -> void:
	remove_import_plugin(import_plugin)
	import_plugin = null
	if main_panel_instance:
		main_panel_instance.queue_free()

func _get_plugin_name():
	return "OpenMPT"

func _get_plugin_icon():
	return EditorInterface.get_editor_theme().get_icon("AudioStream", "EditorIcons")

func _handles(object: Object) -> bool:
	if object is ModTracker:
		main_panel_instance.activate(object)
		return true
	main_panel_instance.deactivate()
	return false
