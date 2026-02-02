# [OpenMPT](https://openmpt.org) Controller Node and UI for Godot

## Who are you and why did you modify this?
This is a fork of the [excellent C++ binding framework from Godot to libopenmpt](https://github.com/Dudejoe870/godot-openmpt) to add some QoL things for folks who want to put mod-tracker music into their game projects.
If you want to know about the underlying framework then check the linked section in this paragraph which explains how it works.

## Features (once done)
On top of providing the low-level bindings, this plugin adds
- A new Node called ModTrackerController
- A Main Screen UI that can
  - Store multiple mod-tracker resources on the node
  - Play back Sequences and Patterns with individual channel pattern tracks, like with OpenMPT
  - Creation and visualisation of triggers that modify the current playing pattern or sequence
- Documented Helper methods on the node to easily control playback of the attached mod-tracker resources
