extends Node


var bass_player: AudioStreamPlayer
var energetic_player: AudioStreamPlayer
var quick_player: AudioStreamPlayer


func _ready() -> void:
	bass_player = AudioStreamPlayer.new()
	energetic_player = AudioStreamPlayer.new()
	quick_player = AudioStreamPlayer.new()
	
	bass_player.process_mode = PROCESS_MODE_ALWAYS
	energetic_player.process_mode = PROCESS_MODE_ALWAYS
	quick_player.process_mode = PROCESS_MODE_ALWAYS
	
	bass_player.stream = load("res://sounds/main_music/main_bass.wav")
	energetic_player.stream = load("res://sounds/main_music/main_energetic.wav")
	quick_player.stream = load("res://sounds/main_music/main_quick.wav")
	
	get_tree().root.add_child.call_deferred(bass_player)
	get_tree().root.add_child.call_deferred(energetic_player)
	get_tree().root.add_child.call_deferred(quick_player)
	
	play_music.call_deferred()


func play_music() -> void:
	bass_player.play()
	energetic_player.play()
	quick_player.play()
	
	await get_tree().create_timer(randf_range(25, 500)).timeout
