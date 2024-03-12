; spindle.g - Configure VFD control

; Set minimum and maximum spindle RPM.
; Minimum is achieved at 0% pulse width, Maximum is at 100% pulse width.

M950 R0 C"PB_0+!PB_9" L24000 Q100
