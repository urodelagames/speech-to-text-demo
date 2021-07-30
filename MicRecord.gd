extends Control

export var host: String = ""
var effect
var recording

func _ready():
	var idx = AudioServer.get_bus_index("Record")
	effect = AudioServer.get_bus_effect(idx, 0)

	$HTTPRequest.connect("request_completed", self, "_on_request_completed")
func _on_request_completed(result, response_code, headers, body):
	if response_code == 200:
		var raw_text = body.get_string_from_utf8()
		print("### request completed ###")
		print(raw_text)
		$Status.text = "\"" + raw_text + "\""
	else:
		$Status.text = body.get_string_from_utf8()
		
func _on_RecordButton_pressed():
	if effect.is_recording_active():
		recording = effect.get_recording()
		$PlayButton.disabled = false
		$SaveButton.disabled = false
		effect.set_recording_active(false)
		$RecordButton.text = "Record"
		$Status.text = ""
		send_recording()
	else:
		$PlayButton.disabled = true
		$SaveButton.disabled = true
		effect.set_recording_active(true)
		$RecordButton.text = "Stop"
		$Status.text = "Recording..."

func send_recording() -> void:
	var data = recording.get_data().hex_encode()
	stt(data)

func stt(data):
	$HTTPRequest.request(host + "/stt", [], true, HTTPClient.METHOD_GET, data)
	
func _on_PlayButton_pressed():
	print(recording)
	print(recording.format)
	print(recording.mix_rate)
	print(recording.stereo)
	var data = recording.get_data()
	print(data)
	print(data.size())
	$AudioStreamPlayer.stream = recording
	$AudioStreamPlayer.play()


func _on_Play_Music_pressed():
	if $AudioStreamPlayer2.playing:
		$AudioStreamPlayer2.stop()
		$PlayMusic.text = "Play Music"
	else:
		$AudioStreamPlayer2.play()
		$PlayMusic.text = "Stop Music"


func _on_SaveButton_pressed():
	var save_path = $SaveButton/Filename.text
	recording.save_to_wav(save_path)
	$Status.text = "Saved WAV file to: %s\n(%s)" % [save_path, ProjectSettings.globalize_path(save_path)]
