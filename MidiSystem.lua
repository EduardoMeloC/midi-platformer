MidiSystem = {}

MidiSystem.OnKeyPressed = {}
MidiSystem.OnKeyReleased = {}

function MidiSystem:init()
	self._inputports = midi.getinportcount()
	self._indevicenumber = 0
	self._in0 = nil

	self._outputports = midi.getoutportcount()
	self._outChannel = 1	-- (channels start with 0-15)
	self._outdevicenumber = 0
	self._out0 = midi.openout(self._outdevicenumber)
	self._outputdevicename = midi.getOutPortName(self._outdevicenumber)

	if self._inputports > 0 then
		print("Midi Input Ports: ", self._inputports)
		table.foreach(midi.enumerateinports(), print)
		print( 'Receiving on device: ', luamidi.getInPortName(self._indevicenumber))
		-- not needed for this demo
--		self._in0 = midi.openin(self._indevicenumber)
	else
		print("No Midi Input Ports found!")
	end
	print()

	if self._out0 and self._outputports > 0 then
		print("Midi Output Ports: ", self._outputports)
		table.foreach(midi.enumerateoutports(), print)
		print()
		print( 'Play on device: ', self._outputdevicename )

		-- change Program: 16 midi channels (192-207), program (0-127), - not used -
		self._out0:sendMessage( 192+self._outChannel, 1, 0 )	-- on midi channel 1, change program to 1
		self._out0:sendMessage( 192+self._outChannel+1, 90, 0 )	-- on midi channel 2, change program to 120
		-- change Control Mode: 16 midi channels (176-191), control (0-127), control value (0-127)
		self._out0:sendMessage( 176+self._outChannel, 7, 125)	-- on midi channel 1, change volume, to 125

	else
		print("No Midi Output Ports found!")
	end
	print()
end

-- current input nodes
local a,b,c,d = nil, 60, 100, nil

function MidiSystem:update()
	if self._out0 and self._inputports > 0 and self._outputports > 0 then
		-- command, note, velocity, delta-time-to-last-event (just ignore)
		a,b,c,d = midi.getMessage(self._indevicenumber)

		if a ~= nil then
			if a == 144 then	-- listen for Note On on First Midi Channel
				print('Note turned ON:	', a, b, c, d)
				self._out0:noteOn( b, c, self._outChannel )
				print(#g_piano.keys)
				if b >= 36 and b < 36 + g_piano.keys_amount then
					for _, func in ipairs(MidiSystem.OnKeyPressed) do
						func(b, c)
					end
				end

			elseif a == 128 then	-- listen for Note Off on First Midi Channel
				--print('Note turned OFF:', a, b, c, d)
				self._out0:noteOff( b, c, outChannel )
				if b >= 36 and b < 36 + g_piano.keys_amount then
					for _, func in ipairs(MidiSystem.OnKeyReleased) do
						func(b, c)
					end
				end
			elseif a == 176 then	-- if channel volume is changed
				--print('Channel Volume changed (Ch/Vol):', b, c)
				self._out0:sendMessage( 176+self._outChannel, 7, c)
			else
				-- other messages
				print('SYSTEM:', a,b,c,d)
			end
		end
	end
end

return MidiSystem
