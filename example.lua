-- require the music library
music = require("music.lua")

-- give it the audio chip
music.audioChip = gdt.AudioChip0
-- an instrument is just an AudioSample
instrument = gdt.ROM.User.AudioSamples["note.wav"]
-- create the track with all its notes
music.Track:new(instrument)
:bpm(180)
:note(music.c, music.quarter)
:note(music.d, music.quarter)
:note(music.e, music.quarter)
:note(music.f, music.quarter)
:pause(music.quarter)
:note(music.g, music.quarter)
:note(music.a, music.quarter)
:note(music.b, music.quarter)
:note(music.c2, music.quarter)
-- will play the clip in 1 second
:play(gdt.CPU0.Time, 1)

function update()
	-- must be called in the update function with the current cpu time
	
	music.update(gdt.CPU0.Time)
end