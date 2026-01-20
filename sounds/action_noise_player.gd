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
			play()
		Sound.DEFEND:
			stream = preload("res://sounds/action_noises/defend.wav")
			play()
		Sound.DESTROY:
			stream = preload("res://sounds/action_noises/destroy.wav")
			play()
		Sound.HEAL:
			stream = preload("res://sounds/action_noises/heal.wav")
			play()
		Sound.LOSE:
			stream = preload("res://sounds/action_noises/lose.wav")
			play()
		Sound.MOVE:
			stream = preload("res://sounds/action_noises/move.wav")
			play()
		Sound.POISON:
			stream = preload("res://sounds/action_noises/poison.wav")
			play()
		Sound.PUSH:
			stream = preload("res://sounds/action_noises/push.wav")
			play()
		Sound.SWAP:
			stream = preload("res://sounds/action_noises/swap.wav")
			play()
		Sound.WIN:
			stream = preload("res://sounds/action_noises/win.wav")
			play()
