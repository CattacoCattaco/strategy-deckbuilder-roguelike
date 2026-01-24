class_name ActionNoisePlayer
extends AudioStreamPlayer

enum Sound {
	DAMAGE,
	DEFEND,
	DESTROY,
	HEAL,
	LOSE,
	MOVE,
	POISON,
	PUSH,
	SWAP,
	WIN,
}


func play_sound(sound: Sound) -> void:
	match sound:
		Sound.DAMAGE:
			stream = preload("res://sounds/action_noises/damage.wav")
			
			# Volume multiplier
			var mult: float = .88
			mult *= Settings.audio_settings[Settings.AudioSetting.ACTION_VOLUME] / 100.0
			mult *= Settings.audio_settings[Settings.AudioSetting.ATTACK_VOLUME] / 100.0
			volume_db = mult_to_db(mult)
			
			play()
		Sound.DEFEND:
			stream = preload("res://sounds/action_noises/defend.wav")
			
			# Volume multiplier
			var mult: float = 15
			mult *= Settings.audio_settings[Settings.AudioSetting.ACTION_VOLUME] / 100.0
			mult *= Settings.audio_settings[Settings.AudioSetting.SHIELD_VOLUME] / 100.0
			volume_db = mult_to_db(mult)
			
			play()
		Sound.DESTROY:
			stream = preload("res://sounds/action_noises/destroy.wav")
			
			# Volume multiplier
			var mult: float = .71
			mult *= Settings.audio_settings[Settings.AudioSetting.ACTION_VOLUME] / 100.0
			mult *= Settings.audio_settings[Settings.AudioSetting.DESTROY_VOLUME] / 100.0
			volume_db = mult_to_db(mult)
			
			play()
		Sound.HEAL:
			stream = preload("res://sounds/action_noises/heal.wav")
			
			# Volume multiplier
			var mult: float = .80
			mult *= Settings.audio_settings[Settings.AudioSetting.ACTION_VOLUME] / 100.0
			mult *= Settings.audio_settings[Settings.AudioSetting.HEAL_VOLUME] / 100.0
			volume_db = mult_to_db(mult)
			
			play()
		Sound.LOSE:
			stream = preload("res://sounds/action_noises/lose.wav")
			
			# Volume multiplier
			var mult: float = .55
			mult *= Settings.audio_settings[Settings.AudioSetting.LOSE_VOLUME] / 100.0
			volume_db = mult_to_db(mult)
			
			play()
		Sound.MOVE:
			stream = preload("res://sounds/action_noises/move.wav")
			
			# Volume multiplier
			var mult: float = .18
			mult *= Settings.audio_settings[Settings.AudioSetting.ACTION_VOLUME] / 100.0
			mult *= Settings.audio_settings[Settings.AudioSetting.MOVE_VOLUME] / 100.0
			volume_db = mult_to_db(mult)
			
			play()
		Sound.POISON:
			stream = preload("res://sounds/action_noises/poison.wav")
			
			# Volume multiplier
			var mult: float = .44
			mult *= Settings.audio_settings[Settings.AudioSetting.ACTION_VOLUME] / 100.0
			mult *= Settings.audio_settings[Settings.AudioSetting.POISON_VOLUME] / 100.0
			volume_db = mult_to_db(mult)
			
			play()
		Sound.PUSH:
			stream = preload("res://sounds/action_noises/push.wav")
			
			# Volume multiplier
			var mult: float = 5
			mult *= Settings.audio_settings[Settings.AudioSetting.ACTION_VOLUME] / 100.0
			mult *= Settings.audio_settings[Settings.AudioSetting.PUSH_VOLUME] / 100.0
			volume_db = mult_to_db(mult)
			
			play()
		Sound.SWAP:
			stream = preload("res://sounds/action_noises/swap.wav")
			
			# Volume multiplier
			var mult: float = .14
			mult *= Settings.audio_settings[Settings.AudioSetting.ACTION_VOLUME] / 100.0
			mult *= Settings.audio_settings[Settings.AudioSetting.SWAP_VOLUME] / 100.0
			volume_db = mult_to_db(mult)
			
			play()
		Sound.WIN:
			stream = preload("res://sounds/action_noises/win.wav")
			
			# Volume multiplier
			var mult: float = 1.5
			mult *= Settings.audio_settings[Settings.AudioSetting.WIN_VOLUME] / 100.0
			volume_db = mult_to_db(mult)
			
			play()


func mult_to_db(mult: float) -> float:
	return log(mult) / log(10) * 10
