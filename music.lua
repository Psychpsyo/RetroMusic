local typeNote = 0
local typePause = 1
local typeBpm = 2

local currentSong = {}
local currentChannel = 0

music = {
	audioChip = nil,
	
	c   =    1,
	cS  = 15/14,
	d   =  8/7,
	dS  = 17/14,
	e   =  9/7,
	f   = 10/7,
	fS  = 21/14,
	g   = 11/7,
	gS  = 23/14,
	a   = 12/7,
	aS  = 25/14,
	b   = 13/7,
	c2  =   2,
	cS2  = 29/14,
	d2  = 15/7,
	dS2  = 31/14,
	e2  = 16/7,
	f2  = 17/7,
	cS2  = 35/14,
	g2  = 18/7,
	cS2  = 37/14,
	a2  = 19/7,
	cS2  = 39/14,
	b2  = 20/7,
	
	doubleWhole = 8,
	whole = 4,
	half = 2,
	quarter = 1,
	eighth = 0.5,
	sixteenth = 0.25,
	thirtySecond = 0.125,
	sixtyFourth = 0.0625,
	
	Track = {
		new = function(self, instrument:AudioSample)
			newTrack = {
				instrument = instrument,
				notes = {}
			}
			setmetatable(newTrack, self)
			self.__index = self
			return newTrack
		end,
		play = function(self, cpuTime:number, delay:number)
			delay = delay or 0
			local bpm = 0.5 -- (60sec / 120bpm)
			local time = cpuTime + delay
			local newNotes = {}
			for i,note in self.notes do
				if note.type == typeNote then
					table.insert(newNotes, {
						time = time,
						pitch = note.pitch
					})
					time += note.value * bpm
				elseif note.type == typePause then
					time += note.length * bpm
				elseif note.type == typeBpm then
					bpm = 60 / note.value
				end
			end
			self.notes = newNotes
			table.insert(currentSong, self)
		end,
		note = function(self, pitch:number, value:number)
			table.insert(self.notes, {
				type = typeNote,
				pitch = pitch,
				value = value
			})
			return self
		end,
		pause = function(self, length:number)
			table.insert(self.notes, {
				type = typePause,
				length = length
			})
			return self
		end,
		bpm = function(self, value:number)
			table.insert(self.notes, {
				type = typeBpm,
				value = value
			})
			return self
		end
	}
}

music.update = function(cpuTime:number)
	for i,track in currentSong do
		while #track.notes > 0 and track.notes[1].time < cpuTime do
			local note = table.remove(track.notes, 1)
			music.audioChip:SetChannelPitch(note.pitch, currentChannel)
			music.audioChip:Play(track.instrument, currentChannel)
			currentChannel += 1
			currentChannel %= music.audioChip.ChannelsCount
		end
		if #track.notes == 0 then
			currentSong[i] = nil
		end
	end
end

music.stopAll = function()
	currentSong = {}
end

return music