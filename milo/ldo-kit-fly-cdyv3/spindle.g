; spindle.g - Configure VFD control

; Set minimum and maximum spindle RPM.
; Minimum is achieved at 0% pulse width, Maximum is at 100% pulse width.

; TODO: We need to work out a good value for Q.
M950 R0 C"Neopixel+!Laser" L24000 Q100
