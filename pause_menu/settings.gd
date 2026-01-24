extends Node

enum AudioSetting {
	LOSE_VOLUME,
	WIN_VOLUME,
	ACTION_VOLUME,
	ATTACK_VOLUME,
	DESTROY_VOLUME,
	HEAL_VOLUME,
	MOVE_VOLUME,
	POISON_VOLUME,
	PUSH_VOLUME,
	SHIELD_VOLUME,
	SWAP_VOLUME,
}

var audio_settings: Array[int]


func _ready() -> void:
	for audio_setting: AudioSetting in AudioSetting.values():
		audio_settings.append(100)
	
